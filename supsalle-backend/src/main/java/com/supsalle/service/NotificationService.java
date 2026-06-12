package com.supsalle.service;

import com.supsalle.dto.NotificationDto;
import com.supsalle.entity.Notification;
import com.supsalle.entity.User;
import com.supsalle.exception.GlobalExceptionHandler.ResourceNotFoundException;
import com.supsalle.repository.NotificationRepository;
import com.supsalle.repository.UserRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class NotificationService {

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private UserRepository userRepository;

    @Transactional
    public List<NotificationDto.Response> getNotificationsForUser(Integer userId) {

        // ✅ marquer comme lues
        notificationRepository.markAllAsReadByUserId(userId);

        return notificationRepository.findByUser_IdOrderByCreatedAtDesc(userId)
                .stream()
                .map(NotificationDto.Response::fromEntity)
                .collect(Collectors.toList());
    }

    public long countUnread(Integer userId) {
        return notificationRepository.countByUser_IdAndIsReadFalse(userId);
    }

    @Transactional
    public void markAllAsRead(Integer userId) {
        notificationRepository.markAllAsReadByUserId(userId);
    }

    @Transactional
    public void createNotification(Integer userId, String message) {

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur non trouvé."));

        Notification notification = new Notification();
        notification.setUser(user);
        notification.setMessage(message);
        notification.setIsRead(false);

        notificationRepository.save(notification);
    }
}