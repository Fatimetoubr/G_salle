package com.supsalle.controller;

import com.supsalle.dto.NotificationDto;
import com.supsalle.repository.UserRepository;
import com.supsalle.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;
    @Autowired
    private UserRepository userRepository;

    @GetMapping
    public ResponseEntity<List<NotificationDto.Response>> getMyNotifications(
            @AuthenticationPrincipal UserDetails userDetails) {
        Integer userId = getUserId(userDetails);
        return ResponseEntity.ok(notificationService.getNotificationsForUser(userId));
    }

    @PutMapping("/mark-read")
    public ResponseEntity<Map<String, String>> markAllAsRead(
            @AuthenticationPrincipal UserDetails userDetails) {
        notificationService.markAllAsRead(getUserId(userDetails));
        return ResponseEntity.ok(Map.of("message", "Toutes les notifications ont ete marquees comme lues."));
    }

    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Long>> getUnreadCount(
            @AuthenticationPrincipal UserDetails userDetails) {
        long count = notificationService.countUnread(getUserId(userDetails));
        return ResponseEntity.ok(Map.of("unreadCount", count));
    }

    private Integer getUserId(UserDetails userDetails) {
        return userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouve"))
                .getId();
    }
}
