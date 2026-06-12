package com.supsalle.entity;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "fullname", length = 100)
    private String fullname;

    @Column(name = "email", length = 100, unique = true)
    private String email;

    @Column(name = "password", length = 255)
    private String password;

    @Enumerated(EnumType.STRING)
    @Column(name = "role")
    private Role role = Role.user;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<Reservation> reservations;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<Notification> notifications;

    public enum Role { user, admin }

    public User() {}

    // Getters
    public Integer getId() { return id; }
    public String getFullname() { return fullname; }
    public String getEmail() { return email; }
    public String getPassword() { return password; }
    public Role getRole() { return role; }
    public Boolean getIsActive() { return isActive; }
    public List<Reservation> getReservations() { return reservations; }
    public List<Notification> getNotifications() { return notifications; }

    // Setters
    public void setId(Integer id) { this.id = id; }
    public void setFullname(String fullname) { this.fullname = fullname; }
    public void setEmail(String email) { this.email = email; }
    public void setPassword(String password) { this.password = password; }
    public void setRole(Role role) { this.role = role; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }
    public void setReservations(List<Reservation> reservations) { this.reservations = reservations; }
    public void setNotifications(List<Notification> notifications) { this.notifications = notifications; }
}
