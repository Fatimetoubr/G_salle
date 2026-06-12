package com.supsalle.entity;

import jakarta.persistence.*;

import java.util.List;

@Entity
@Table(name = "salles")
public class Salle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "nom", length = 100)
    private String nom;

    @Column(name = "type", length = 100)
    private String type;

    @Column(name = "capacité")
    private Integer capacite;

    @Column(name = "équipements", columnDefinition = "TEXT")
    private String equipements;

    @Enumerated(EnumType.STRING)
    @Column(name = "maintenance")
    private MaintenanceStatus maintenance = MaintenanceStatus.hors_maintenance;

    @OneToMany(mappedBy = "salle", cascade = CascadeType.ALL)
    private List<Reservation> reservations;

    public enum MaintenanceStatus {
        en_maintenance,
        hors_maintenance
    }

    public Salle() {}

    // ---- Getters ----
    public Integer getId() { return id; }
    public String getNom() { return nom; }
    public String getType() { return type; }
    public Integer getCapacite() { return capacite; }
    public String getEquipements() { return equipements; }
    public MaintenanceStatus getMaintenance() { return maintenance; }
    public List<Reservation> getReservations() { return reservations; }

    // ---- Setters ----
    public void setId(Integer id) { this.id = id; }
    public void setNom(String nom) { this.nom = nom; }
    public void setType(String type) { this.type = type; }
    public void setCapacite(Integer capacite) { this.capacite = capacite; }
    public void setEquipements(String equipements) { this.equipements = equipements; }
    public void setMaintenance(MaintenanceStatus maintenance) { this.maintenance = maintenance; }
    public void setReservations(List<Reservation> reservations) { this.reservations = reservations; }
}
