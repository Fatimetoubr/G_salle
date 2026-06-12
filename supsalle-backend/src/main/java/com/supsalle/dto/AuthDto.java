package com.supsalle.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class AuthDto {

    // Inscription simple : nom + email + mot de passe
    public static class RegisterRequest {
        @NotBlank(message = "Le nom complet est obligatoire")
        private String fullname;

        @NotBlank(message = "L'email est obligatoire")
        @Email(message = "Format d'email invalide")
        private String email;

        @NotBlank(message = "Le mot de passe est obligatoire")
        @Size(min = 6, message = "Le mot de passe doit contenir au moins 6 caractères")
        private String password;

        public String getFullname() { return fullname; }
        public void setFullname(String fullname) { this.fullname = fullname; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
    }

    // Connexion directe
    public static class LoginRequest {
        @NotBlank(message = "L'email est obligatoire")
        @Email(message = "Format d'email invalide")
        private String email;

        @NotBlank(message = "Le mot de passe est obligatoire")
        private String password;

        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
    }

    // Réponse après connexion
    public static class LoginResponse {
        private String token;
        private String role;
        private Integer userId;
        private String email;
        private String fullname;

        public LoginResponse(String token, String role, Integer userId, String email, String fullname) {
            this.token = token;
            this.role = role;
            this.userId = userId;
            this.email = email;
            this.fullname = fullname;
        }

        public String getToken() { return token; }
        public String getRole() { return role; }
        public Integer getUserId() { return userId; }
        public String getEmail() { return email; }
        public String getFullname() { return fullname; }
    }
}
