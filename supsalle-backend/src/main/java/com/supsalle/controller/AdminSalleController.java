package com.supsalle.controller;

import com.supsalle.dto.SalleDto;
import com.supsalle.service.SalleService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/admin/salles")
@PreAuthorize("hasRole('ADMIN')")
public class AdminSalleController {

    @Autowired
    private SalleService salleService;

    @PostMapping
    public ResponseEntity<SalleDto.Response> createSalle(@Valid @RequestBody SalleDto.Request request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(salleService.createSalle(request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<SalleDto.Response> updateSalle(@PathVariable Integer id, @Valid @RequestBody SalleDto.Request request) {
        return ResponseEntity.ok(salleService.updateSalle(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> deleteSalle(@PathVariable Integer id) {
        salleService.deleteSalle(id);
        return ResponseEntity.ok(Map.of("message", "Salle supprimee avec succes."));
    }
}
