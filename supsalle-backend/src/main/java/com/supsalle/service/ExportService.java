package com.supsalle.service;

import com.supsalle.entity.User;
import com.supsalle.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.List;

@Service
public class ExportService {

    @Autowired
    private UserRepository userRepository;

    public byte[] exportUsersCsv() throws IOException {
        List<User> users = userRepository.findByRole(User.Role.user);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        baos.write(new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF}); // BOM UTF-8
        try (PrintWriter writer = new PrintWriter(new OutputStreamWriter(baos, StandardCharsets.UTF_8))) {
            writer.println("ID;Nom complet;Email;Role;Statut");
            for (User user : users) {
                writer.printf("%d;%s;%s;%s;%s%n",
                        user.getId(),
                        escapeCsv(user.getFullname()),
                        escapeCsv(user.getEmail()),
                        user.getRole() != null ? user.getRole().name() : "user",
                        Boolean.TRUE.equals(user.getIsActive()) ? "Actif" : "Inactif");
            }
        }
        return baos.toByteArray();
    }

    private String escapeCsv(String value) {
        if (value == null) return "";
        if (value.contains(";") || value.contains("\"") || value.contains("\n")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
    }
}
