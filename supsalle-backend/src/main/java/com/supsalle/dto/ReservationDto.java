package com.supsalle.dto;

import com.supsalle.entity.Reservation;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

public class ReservationDto {

    public static class Request {
        @NotNull(message = "L'identifiant de la salle est obligatoire")
        private Integer salleId;
        @NotNull(message = "La date est obligatoire")
        @FutureOrPresent(message = "La date ne peut pas être dans le passé")
        private LocalDate date;
        @NotNull(message = "L'heure de début est obligatoire")
        private LocalTime heureDebut;
        @NotNull(message = "L'heure de fin est obligatoire")
        private LocalTime heureFin;

        public Integer getSalleId() { return salleId; }
        public void setSalleId(Integer salleId) { this.salleId = salleId; }
        public LocalDate getDate() { return date; }
        public void setDate(LocalDate date) { this.date = date; }
        public LocalTime getHeureDebut() { return heureDebut; }
        public void setHeureDebut(LocalTime heureDebut) { this.heureDebut = heureDebut; }
        public LocalTime getHeureFin() { return heureFin; }
        public void setHeureFin(LocalTime heureFin) { this.heureFin = heureFin; }
    }

    public static class Response {
        private Integer id;
        private Integer salleId;
        private String salleNom;
        private Integer userId;
        private String userFullname;
        private String userEmail;
        private LocalDate date;
        private LocalTime heureDebut;
        private LocalTime heureFin;
        private String statut;

        public static Response fromEntity(Reservation r) {
            Response res = new Response();
            res.setId(r.getId());
            if (r.getSalle() != null) {
                res.setSalleId(r.getSalle().getId());
                res.setSalleNom(r.getSalle().getNom());
            }
            if (r.getUser() != null) {
                res.setUserId(r.getUser().getId());
                res.setUserFullname(r.getUser().getFullname());
                res.setUserEmail(r.getUser().getEmail());
            }
            res.setDate(r.getDate());
            res.setHeureDebut(r.getHeureDebut());
            res.setHeureFin(r.getHeureFin());
            res.setStatut(r.getStatut());
            return res;
        }

        public Integer getId() { return id; }
        public void setId(Integer id) { this.id = id; }
        public Integer getSalleId() { return salleId; }
        public void setSalleId(Integer salleId) { this.salleId = salleId; }
        public String getSalleNom() { return salleNom; }
        public void setSalleNom(String salleNom) { this.salleNom = salleNom; }
        public Integer getUserId() { return userId; }
        public void setUserId(Integer userId) { this.userId = userId; }
        public String getUserFullname() { return userFullname; }
        public void setUserFullname(String userFullname) { this.userFullname = userFullname; }
        public String getUserEmail() { return userEmail; }
        public void setUserEmail(String userEmail) { this.userEmail = userEmail; }
        public LocalDate getDate() { return date; }
        public void setDate(LocalDate date) { this.date = date; }
        public LocalTime getHeureDebut() { return heureDebut; }
        public void setHeureDebut(LocalTime heureDebut) { this.heureDebut = heureDebut; }
        public LocalTime getHeureFin() { return heureFin; }
        public void setHeureFin(LocalTime heureFin) { this.heureFin = heureFin; }
        public String getStatut() { return statut; }
        public void setStatut(String statut) { this.statut = statut; }
    }

    public static class DisponibiliteResponse {
        private LocalDate date;
        private Integer salleId;
        private String salleNom;
        private List<CreneauDto> creneaux;

        public LocalDate getDate() { return date; }
        public void setDate(LocalDate date) { this.date = date; }
        public Integer getSalleId() { return salleId; }
        public void setSalleId(Integer salleId) { this.salleId = salleId; }
        public String getSalleNom() { return salleNom; }
        public void setSalleNom(String salleNom) { this.salleNom = salleNom; }
        public List<CreneauDto> getCreneaux() { return creneaux; }
        public void setCreneaux(List<CreneauDto> creneaux) { this.creneaux = creneaux; }
    }

    public static class CreneauDto {
        private String heureDebut;
        private String heureFin;
        private boolean disponible;

        public String getHeureDebut() { return heureDebut; }
        public void setHeureDebut(String heureDebut) { this.heureDebut = heureDebut; }
        public String getHeureFin() { return heureFin; }
        public void setHeureFin(String heureFin) { this.heureFin = heureFin; }
        public boolean isDisponible() { return disponible; }
        public void setDisponible(boolean disponible) { this.disponible = disponible; }
    }
}
