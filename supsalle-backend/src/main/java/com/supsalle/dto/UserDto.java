package com.supsalle.dto;

import com.supsalle.entity.User;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public class UserDto {

    public static class Response {
        private Integer id;
        private String fullname;
        private String email;
        private String role;
        private Boolean isActive;

        public static Response fromEntity(User u) {
            Response r = new Response();
            r.setId(u.getId());
            r.setFullname(u.getFullname());
            r.setEmail(u.getEmail());
            r.setRole(u.getRole() != null ? u.getRole().name() : null);
            r.setIsActive(u.getIsActive());
            return r;
        }

        public Integer getId() { return id; }
        public void setId(Integer id) { this.id = id; }
        public String getFullname() { return fullname; }
        public void setFullname(String fullname) { this.fullname = fullname; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getRole() { return role; }
        public void setRole(String role) { this.role = role; }
        public Boolean getIsActive() { return isActive; }
        public void setIsActive(Boolean isActive) { this.isActive = isActive; }
    }

    public static class UpdateRequest {
        @NotBlank(message = "Le nom complet est obligatoire")
        private String fullname;

        @NotBlank(message = "L'email est obligatoire")
        @Email(message = "Format d'email invalide")
        private String email;

        private Boolean isActive;
        private String role;

        public String getFullname() { return fullname; }
        public void setFullname(String fullname) { this.fullname = fullname; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public Boolean getIsActive() { return isActive; }
        public void setIsActive(Boolean isActive) { this.isActive = isActive; }
        public String getRole() { return role; }
        public void setRole(String role) { this.role = role; }
    }
}
