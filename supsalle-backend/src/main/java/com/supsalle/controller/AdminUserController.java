package com.supsalle.controller;

import com.supsalle.dto.UserDto;
import com.supsalle.service.ExportService;
import com.supsalle.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/users")
@PreAuthorize("hasRole('ADMIN')")
public class AdminUserController {

    @Autowired
    private UserService userService;

    @Autowired
    private ExportService exportService;

    // ================= USERS =================

    // ✅ GET ALL USERS
    @GetMapping
    public ResponseEntity<List<UserDto.Response>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    // ✅ GET USER BY ID
    @GetMapping("/{id}")
    public ResponseEntity<UserDto.Response> getUserById(@PathVariable Integer id) {
        return ResponseEntity.ok(userService.getUserById(id));
    }

    // ✅ UPDATE USER
    @PutMapping("/{id}")
    public ResponseEntity<UserDto.Response> updateUser(
            @PathVariable Integer id,
            @Valid @RequestBody UserDto.UpdateRequest request) {
        return ResponseEntity.ok(userService.updateUser(id, request));
    }

    // ✅ ACTIVER / DÉSACTIVER USER
    @PutMapping("/{id}/desactiver")
    public ResponseEntity<Map<String, String>> deactivateUser(@PathVariable Integer id) {
        userService.deactivateUser(id);
        return ResponseEntity.ok(Map.of("message", "Utilisateur désactivé avec succès."));
    }

    // ✅ DELETE USER
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> deleteUser(@PathVariable Integer id) {
        userService.deleteUser(id);
        return ResponseEntity.ok(Map.of("message", "Utilisateur supprimé avec succès"));
    }

    // ================= EXPORT =================

    @GetMapping("/export-csv")
    public ResponseEntity<byte[]> exportCsv() throws IOException {
        byte[] csv = exportService.exportUsersCsv();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType("text/csv; charset=UTF-8"));
        headers.setContentDispositionFormData("attachment", "utilisateurs_export.csv");
        headers.setContentLength(csv.length);

        return ResponseEntity.ok().headers(headers).body(csv);
    }
}