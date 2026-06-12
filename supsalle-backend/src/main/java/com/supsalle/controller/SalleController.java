package com.supsalle.controller;

import com.supsalle.dto.ReservationDto;
import com.supsalle.dto.SalleDto;
import com.supsalle.service.ReservationService;
import com.supsalle.service.SalleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/salles")
public class SalleController {

    @Autowired
    private SalleService salleService;
    @Autowired
    private ReservationService reservationService;

    @GetMapping
    public ResponseEntity<List<SalleDto.Response>> getAllSalles() {
        return ResponseEntity.ok(salleService.getAllSalles());
    }

    @GetMapping("/{id}")
    public ResponseEntity<SalleDto.Response> getSalleById(@PathVariable Integer id) {
        return ResponseEntity.ok(salleService.getSalleById(id));
    }

    @GetMapping("/{id}/disponibilite")
    public ResponseEntity<ReservationDto.DisponibiliteResponse> getDisponibilite(
            @PathVariable Integer id,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        LocalDate targetDate = (date != null) ? date : LocalDate.now();
        return ResponseEntity.ok(reservationService.getDisponibilite(id, targetDate));
    }
}
