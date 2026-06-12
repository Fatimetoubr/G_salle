package com.supsalle.dto;

import com.supsalle.entity.Notification;
import java.time.LocalDateTime;

public class NotificationDto {

    public static class Response {
        private Integer id;
        private String message;
        private Boolean isRead;
        private LocalDateTime createdAt;

        public static Response fromEntity(Notification n) {
            Response r = new Response();
            r.setId(n.getId());
            r.setMessage(n.getMessage());
            r.setIsRead(n.getIsRead());
            r.setCreatedAt(n.getCreatedAt());
            return r;
        }

        public Integer getId() { return id; }
        public void setId(Integer id) { this.id = id; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        public Boolean getIsRead() { return isRead; }
        public void setIsRead(Boolean isRead) { this.isRead = isRead; }
        public LocalDateTime getCreatedAt() { return createdAt; }
        public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    }
}
