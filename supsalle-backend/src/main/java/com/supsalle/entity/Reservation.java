package com.supsalle.entity;

import jakarta.persistence.*;

import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Table(name = "reservations")
public class Reservation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_salle")
    private Salle salle;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_user")
    private User user;

    @Column(name = "date")
    private LocalDate date;

    @Column(name = "heure_debut")
    private LocalTime heureDebut;

    @Column(name = "heure_fin")
    private LocalTime heureFin;

    @Column(name = "statut", length = 50)
    private String statut = "en attente";

    public Reservation() {}

    // ---- Getters ----
    public Integer getId() { return id; }
    public Salle getSalle() { return salle; }
    public User getUser() { return user; }
    public LocalDate getDate() { return date; }
    public LocalTime getHeureDebut() { return heureDebut; }
    public LocalTime getHeureFin() { return heureFin; }
    public String getStatut() { return statut; }

    // ---- Setters ----
    public void setId(Integer id) { this.id = id; }
    public void setSalle(Salle salle) { this.salle = salle; }
    public void setUser(User user) { this.user = user; }
    public void setDate(LocalDate date) { this.date = date; }
    public void setHeureDebut(LocalTime heureDebut) { this.heureDebut = heureDebut; }
    public void setHeureFin(LocalTime heureFin) { this.heureFin = heureFin; }
    public void setStatut(String statut) { this.statut = statut; }
}
