package com.supsalle.service;

import com.supsalle.dto.SalleDto;
import com.supsalle.entity.Salle;
import com.supsalle.exception.GlobalExceptionHandler.ResourceNotFoundException;
import com.supsalle.repository.SalleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class SalleService {

    @Autowired
    private SalleRepository salleRepository;

    public List<SalleDto.Response> getAllSalles() {
        return salleRepository.findAll()
                .stream()
                .map(SalleDto.Response::fromEntity)
                .collect(Collectors.toList());
    }

    public SalleDto.Response getSalleById(Integer id) {
        return SalleDto.Response.fromEntity(findSalleOrThrow(id));
    }

    @Transactional
    public SalleDto.Response createSalle(SalleDto.Request request) {
        Salle salle = new Salle();
        mapRequestToEntity(request, salle);
        salle.setMaintenance(Salle.MaintenanceStatus.hors_maintenance);
        return SalleDto.Response.fromEntity(salleRepository.save(salle));
    }

    @Transactional
    public SalleDto.Response updateSalle(Integer id, SalleDto.Request request) {
        Salle salle = findSalleOrThrow(id);
        mapRequestToEntity(request, salle);
        return SalleDto.Response.fromEntity(salleRepository.save(salle));
    }

    @Transactional
    public void deleteSalle(Integer id) {
        if (!salleRepository.existsById(id)) {
            throw new ResourceNotFoundException("Salle non trouvee avec l'id : " + id);
        }
        salleRepository.deleteById(id);
    }

    private Salle findSalleOrThrow(Integer id) {
        return salleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Salle non trouvee avec l'id : " + id));
    }

    private void mapRequestToEntity(SalleDto.Request request, Salle salle) {
        salle.setNom(request.getNom());
        salle.setType(request.getType());
        salle.setCapacite(request.getCapacite());
        salle.setEquipements(request.getEquipements());
        if (request.getMaintenance() != null) {
            salle.setMaintenance(request.getMaintenance());
        }
    }
}
