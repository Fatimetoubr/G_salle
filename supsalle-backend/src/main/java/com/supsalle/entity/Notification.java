package com.supsalle.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "message", columnDefinition = "TEXT")
    private String message;

    @Column(name = "is_read")
    private Boolean isRead = false;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    public Notification() {}

    // ---- Getters ----
    public Integer getId() { return id; }
    public User getUser() { return user; }
    public String getMessage() { return message; }
    public Boolean getIsRead() { return isRead; }
    public LocalDateTime getCreatedAt() { return createdAt; }

    // ---- Setters ----
    public void setId(Integer id) { this.id = id; }
    public void setUser(User user) { this.user = user; }
    public void setMessage(String message) { this.message = message; }
    public void setIsRead(Boolean isRead) { this.isRead = isRead; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
