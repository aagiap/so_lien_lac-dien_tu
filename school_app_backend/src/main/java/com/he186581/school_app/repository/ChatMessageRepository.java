package com.he186581.school_app.repository;

import com.he186581.school_app.entity.ChatMessage;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import org.springframework.data.repository.query.Param;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {

    @Query("""
            SELECT m
            FROM ChatMessage m
            WHERE (m.sender.id = :currentUserId AND m.receiver.id = :otherUserId)
               OR (m.sender.id = :otherUserId AND m.receiver.id = :currentUserId)
            ORDER BY m.createdAt ASC
            """)
    List<ChatMessage> findConversation(@Param("currentUserId") Long currentUserId, @Param("otherUserId") Long otherUserId);
}
