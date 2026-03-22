package com.he186581.school_app.websocket;

import com.he186581.school_app.dto.message.MessageRequest;
import com.he186581.school_app.exception.UnauthorizedException;
import com.he186581.school_app.service.MessageService;
import java.security.Principal;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.stereotype.Controller;

/**
 * Nhận tin nhắn từ STOMP client và lưu vào DB.
 * Client gửi tới: /app/chat.send
 */
@Controller
@RequiredArgsConstructor
public class ChatSocketController {

    private final MessageService messageService;

    @MessageMapping("/chat.send")
    public void send(MessageRequest request, Principal principal) {
        if (principal == null) {
            throw new UnauthorizedException("WebSocket chưa xác thực");
        }

        messageService.sendMessage(principal.getName(), request);
    }
}
