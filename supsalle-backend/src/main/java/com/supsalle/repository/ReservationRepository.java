package com.supsalle.repository;

import com.supsalle.entity.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Integer> {

    List<Reservation> findByUserIdOrderByDateDesc(Integer userId);

    List<Reservation> findBySalleIdAndDate(Integer salleId, LocalDate date);

    @Query("SELECT r FROM Reservation r JOIN FETCH r.salle JOIN FETCH r.user ORDER BY r.date DESC")
    List<Reservation> findAllWithDetails();

    /**
     * Vérifie si un créneau se chevauche avec des réservations existantes (peu importe le statut).
     * Un créneau [debut, fin[ chevauche [debR, finR[ si debut < finR AND fin > debR
     */
    @Query("SELECT COUNT(r) > 0 FROM Reservation r WHERE r.salle.id = :salleId AND r.date = :date " +
           "AND r.heureDebut < :heureFin AND r.heureFin > :heureDebut")
    boolean existsOverlappingReservation(@Param("salleId") Integer salleId,
                                          @Param("date") LocalDate date,
                                          @Param("heureDebut") LocalTime heureDebut,
                                          @Param("heureFin") LocalTime heureFin);

    /**
     * Même vérification mais en excluant une réservation spécifique (utile pour modifier).
     */
    @Query("SELECT COUNT(r) > 0 FROM Reservation r WHERE r.salle.id = :salleId AND r.date = :date " +
           "AND r.heureDebut < :heureFin AND r.heureFin > :heureDebut AND r.id != :excludeId")
    boolean existsOverlappingReservationExcluding(@Param("salleId") Integer salleId,
                                                   @Param("date") LocalDate date,
                                                   @Param("heureDebut") LocalTime heureDebut,
                                                   @Param("heureFin") LocalTime heureFin,
                                                   @Param("excludeId") Integer excludeId);
}
