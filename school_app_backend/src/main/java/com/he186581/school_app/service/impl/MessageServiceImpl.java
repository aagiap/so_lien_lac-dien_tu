package com.he186581.school_app.service.impl;

import com.he186581.school_app.dto.message.MessageRequest;
import com.he186581.school_app.dto.message.MessageResponse;
import com.he186581.school_app.entity.ChatMessage;
import com.he186581.school_app.entity.User;
import com.he186581.school_app.exception.ResourceNotFoundException;
import com.he186581.school_app.repository.ChatMessageRepository;
import com.he186581.school_app.repository.UserRepository;
import com.he186581.school_app.service.MessageService;
import com.he186581.school_app.service.UserService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class MessageServiceImpl implements MessageService {

    private final ChatMessageRepository chatMessageRepository;
    private final UserRepository userRepository;
    private final UserService userService;
    private final SimpMessagingTemplate messagingTemplate;

    @Override
    public MessageResponse sendMessage(String senderUsername, MessageRequest request) {
        User sender = userService.getEntityByUsername(senderUsername);
        User receiver = userRepository.findById(request.getReceiverId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người nhận"));

        ChatMessage message = new ChatMessage();
        message.setSender(sender);
        message.setReceiver(receiver);
        message.setContent(request.getContent());
        message.setRead(false);

        ChatMessage saved = chatMessageRepository.save(message);
        MessageResponse response = mapToResponse(saved);

        // Broadcast room chung để các client theo dõi realtime
        messagingTemplate.convertAndSend("/topic/messages", response);

        // Gửi riêng cho người nhận nếu client subscribe /user/queue/messages
        messagingTemplate.convertAndSendToUser(receiver.getUsername(), "/queue/messages", response);

        return response;
    }

    @Override
    public List<MessageResponse> getConversation(String currentUsername, Long otherUserId) {
        User currentUser = userService.getEntityByUsername(currentUsername);
        return chatMessageRepository.findConversation(currentUser.getId(), otherUserId)
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    private MessageResponse mapToResponse(ChatMessage message) {
        return MessageResponse.builder()
                .id(message.getId())
                .senderId(message.getSender().getId())
                .senderName(message.getSender().getFullName())
                .receiverId(message.getReceiver().getId())
                .receiverName(message.getReceiver().getFullName())
                .content(message.getContent())
                .read(message.getRead())
                .sentAt(message.getCreatedAt())
                .build();
    }
}
