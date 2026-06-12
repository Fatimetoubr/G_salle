package com.supsalle.repository;

import com.supsalle.entity.Salle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SalleRepository extends JpaRepository<Salle, Integer> {

    List<Salle> findByMaintenance(Salle.MaintenanceStatus maintenance);
}
