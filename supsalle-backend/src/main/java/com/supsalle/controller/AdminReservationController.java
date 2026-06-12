package com.supsalle.controller;

import com.supsalle.dto.ReservationDto;
import com.supsalle.service.ReservationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/reservations")
@PreAuthorize("hasRole('ADMIN')")
public class AdminReservationController {

    @Autowired
    private ReservationService reservationService;

    @GetMapping
    public ResponseEntity<List<ReservationDto.Response>> getAllReservations() {
        return ResponseEntity.ok(reservationService.getAllReservations());
    }

    @PutMapping("/{id}/accepter")
    public ResponseEntity<ReservationDto.Response> acceptReservation(@PathVariable Integer id) {
        return ResponseEntity.ok(reservationService.acceptReservation(id));
    }

    @PutMapping("/{id}/refuser")
    public ResponseEntity<ReservationDto.Response> refuseReservation(@PathVariable Integer id) {
        return ResponseEntity.ok(reservationService.refuseReservation(id));
    }
}
