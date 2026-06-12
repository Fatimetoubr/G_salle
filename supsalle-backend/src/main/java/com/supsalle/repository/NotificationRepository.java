package com.supsalle.repository;

import com.supsalle.entity.Notification;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Integer> {

    
    List<Notification> findByUser_IdOrderByCreatedAtDesc(Integer userId);

    long countByUser_IdAndIsReadFalse(Integer userId);

    List<Notification> findByUser_IdAndIsReadFalse(Integer userId);

    
    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true WHERE n.user.id = :userId")
    void markAllAsReadByUserId(@Param("userId") Integer userId);
}