package com.supsalle.controller;

import com.supsalle.dto.ReservationDto;
import com.supsalle.repository.UserRepository;
import com.supsalle.service.ReservationService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reservations")
public class ReservationController {

    @Autowired
    private ReservationService reservationService;
    @Autowired
    private UserRepository userRepository;

    @PostMapping
    public ResponseEntity<ReservationDto.Response> createReservation(
            @Valid @RequestBody ReservationDto.Request request,
            @AuthenticationPrincipal UserDetails userDetails) {
        Integer userId = getUserId(userDetails);
        return ResponseEntity.status(HttpStatus.CREATED).body(reservationService.createReservation(userId, request));
    }

    @GetMapping("/mes-reservations")
    public ResponseEntity<List<ReservationDto.Response>> getMyReservations(
            @AuthenticationPrincipal UserDetails userDetails) {
        Integer userId = getUserId(userDetails);
        return ResponseEntity.ok(reservationService.getMyReservations(userId));
    }

    private Integer getUserId(UserDetails userDetails) {
        return userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouve"))
                .getId();
    }
}
