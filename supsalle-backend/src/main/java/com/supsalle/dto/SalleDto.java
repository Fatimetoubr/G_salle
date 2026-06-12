package com.supsalle.dto;

import com.supsalle.entity.Salle;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class SalleDto {

    public static class Request {
        @NotBlank(message = "Le nom de la salle est obligatoire")
        private String nom;
        @NotBlank(message = "Le type de salle est obligatoire")
        private String type;
        @NotNull(message = "La capacité est obligatoire")
        @Min(value = 1, message = "La capacité doit être d'au moins 1")
        private Integer capacite;
        private String equipements;
        private Salle.MaintenanceStatus maintenance = Salle.MaintenanceStatus.hors_maintenance;

        public String getNom() { return nom; }
        public void setNom(String nom) { this.nom = nom; }
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        public Integer getCapacite() { return capacite; }
        public void setCapacite(Integer capacite) { this.capacite = capacite; }
        public String getEquipements() { return equipements; }
        public void setEquipements(String equipements) { this.equipements = equipements; }
        public Salle.MaintenanceStatus getMaintenance() { return maintenance; }
        public void setMaintenance(Salle.MaintenanceStatus maintenance) { this.maintenance = maintenance; }
    }

    public static class Response {
        private Integer id;
        private String nom;
        private String type;
        private Integer capacite;
        private String equipements;
        private String maintenance;

        public static Response fromEntity(Salle salle) {
            Response r = new Response();
            r.setId(salle.getId());
            r.setNom(salle.getNom());
            r.setType(salle.getType());
            r.setCapacite(salle.getCapacite());
            r.setEquipements(salle.getEquipements());
            r.setMaintenance(salle.getMaintenance() != null ? salle.getMaintenance().name() : null);
            return r;
        }

        public Integer getId() { return id; }
        public void setId(Integer id) { this.id = id; }
        public String getNom() { return nom; }
        public void setNom(String nom) { this.nom = nom; }
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        public Integer getCapacite() { return capacite; }
        public void setCapacite(Integer capacite) { this.capacite = capacite; }
        public String getEquipements() { return equipements; }
        public void setEquipements(String equipements) { this.equipements = equipements; }
        public String getMaintenance() { return maintenance; }
        public void setMaintenance(String maintenance) { this.maintenance = maintenance; }
    }
}
