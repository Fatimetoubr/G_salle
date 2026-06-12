package com.supsalle.service;

import com.supsalle.dto.ReservationDto;
import com.supsalle.entity.Reservation;
import com.supsalle.entity.Salle;
import com.supsalle.entity.User;
import com.supsalle.exception.GlobalExceptionHandler.BadRequestException;
import com.supsalle.exception.GlobalExceptionHandler.ConflictException;
import com.supsalle.exception.GlobalExceptionHandler.ResourceNotFoundException;
import com.supsalle.repository.ReservationRepository;
import com.supsalle.repository.SalleRepository;
import com.supsalle.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ReservationService {

    @Autowired
    private ReservationRepository reservationRepository;
    @Autowired
    private SalleRepository salleRepository;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private NotificationService notificationService;

    private static final LocalTime OPENING_TIME = LocalTime.of(8, 0);
    private static final LocalTime CLOSING_TIME = LocalTime.of(20, 0);
    private static final int SLOT_MINUTES = 30;

    @Transactional
    public ReservationDto.Response createReservation(Integer userId, ReservationDto.Request request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur non trouve."));
        if (!user.getIsActive()) {
            throw new BadRequestException("Votre compte est desactive. Vous ne pouvez pas effectuer de reservation.");
        }
        Salle salle = salleRepository.findById(request.getSalleId())
                .orElseThrow(() -> new ResourceNotFoundException("Salle non trouvee."));
        if (salle.getMaintenance() == Salle.MaintenanceStatus.en_maintenance) {
            throw new BadRequestException("Cette salle est actuellement en maintenance.");
        }
        validateTimeSlot(request.getHeureDebut(), request.getHeureFin());
        boolean overlap = reservationRepository.existsOverlappingReservation(
                salle.getId(), request.getDate(), request.getHeureDebut(), request.getHeureFin());
        if (overlap) {
            throw new ConflictException("Le creneau choisi est deja reserve.");
        }
        Reservation reservation = new Reservation();
        reservation.setSalle(salle);
        reservation.setUser(user);
        reservation.setDate(request.getDate());
        reservation.setHeureDebut(request.getHeureDebut());
        reservation.setHeureFin(request.getHeureFin());
        reservation.setStatut("en attente");
        return ReservationDto.Response.fromEntity(reservationRepository.save(reservation));
    }

    public List<ReservationDto.Response> getMyReservations(Integer userId) {
        return reservationRepository.findByUserIdOrderByDateDesc(userId)
                .stream()
                .map(ReservationDto.Response::fromEntity)
                .collect(Collectors.toList());
    }

    public ReservationDto.DisponibiliteResponse getDisponibilite(Integer salleId, LocalDate date) {
        Salle salle = salleRepository.findById(salleId)
                .orElseThrow(() -> new ResourceNotFoundException("Salle non trouvee."));
        List<Reservation> existing = reservationRepository.findBySalleIdAndDate(salleId, date);
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("HH:mm");
        List<ReservationDto.CreneauDto> creneaux = new ArrayList<>();
        LocalTime cursor = OPENING_TIME;
        while (cursor.plusMinutes(SLOT_MINUTES).compareTo(CLOSING_TIME) <= 0) {
            LocalTime slotEnd = cursor.plusMinutes(SLOT_MINUTES);
            boolean isReserved = isSlotTaken(cursor, slotEnd, existing);
            ReservationDto.CreneauDto creneau = new ReservationDto.CreneauDto();
            creneau.setHeureDebut(cursor.format(fmt));
            creneau.setHeureFin(slotEnd.format(fmt));
            creneau.setDisponible(!isReserved);
            creneaux.add(creneau);
            cursor = cursor.plusMinutes(SLOT_MINUTES);
        }
        ReservationDto.DisponibiliteResponse response = new ReservationDto.DisponibiliteResponse();
        response.setDate(date);
        response.setSalleId(salleId);
        response.setSalleNom(salle.getNom());
        response.setCreneaux(creneaux);
        return response;
    }

    public List<ReservationDto.Response> getAllReservations() {
        return reservationRepository.findAllWithDetails()
                .stream()
                .map(ReservationDto.Response::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public ReservationDto.Response acceptReservation(Integer reservationId) {
        Reservation reservation = findReservationOrThrow(reservationId);
        reservation.setStatut("accepte");
        reservationRepository.save(reservation);
        String nomSalle = reservation.getSalle().getNom();
        String message = "Votre reservation pour la salle '" + nomSalle + "' a ete acceptee.";
        notificationService.createNotification(reservation.getUser().getId(), message);
        return ReservationDto.Response.fromEntity(reservation);
    }

    @Transactional
    public ReservationDto.Response refuseReservation(Integer reservationId) {
        Reservation reservation = findReservationOrThrow(reservationId);
        reservation.setStatut("refuse");
        reservationRepository.save(reservation);
        String nomSalle = reservation.getSalle().getNom();
        String message = "Votre reservation pour la salle '" + nomSalle + "' a ete refusee. Consultez vos reservations.";
        notificationService.createNotification(reservation.getUser().getId(), message);
        return ReservationDto.Response.fromEntity(reservation);
    }

    private void validateTimeSlot(LocalTime debut, LocalTime fin) {
        if (!debut.isBefore(fin)) {
            throw new BadRequestException("L'heure de fin doit etre apres l'heure de debut.");
        }
        long durationMinutes = java.time.Duration.between(debut, fin).toMinutes();
        if (durationMinutes < SLOT_MINUTES) {
            throw new BadRequestException("La duree minimale est de 30 minutes.");
        }
        if (debut.isBefore(OPENING_TIME) || fin.isAfter(CLOSING_TIME)) {
            throw new BadRequestException("Les reservations sont possibles entre 08:00 et 20:00.");
        }
    }

    private boolean isSlotTaken(LocalTime slotStart, LocalTime slotEnd, List<Reservation> reservations) {
        for (Reservation r : reservations) {
            if (slotStart.isBefore(r.getHeureFin()) && slotEnd.isAfter(r.getHeureDebut())) {
                return true;
            }
        }
        return false;
    }

    private Reservation findReservationOrThrow(Integer id) {
        return reservationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reservation non trouvee avec l'id : " + id));
    }
}
