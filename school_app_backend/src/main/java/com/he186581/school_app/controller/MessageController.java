package com.he186581.school_app.controller;

import com.he186581.school_app.dto.common.ApiResponse;
import com.he186581.school_app.dto.message.MessageRequest;
import com.he186581.school_app.dto.message.MessageResponse;
import com.he186581.school_app.service.MessageService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/messages")
@RequiredArgsConstructor
public class MessageController {

    private final MessageService messageService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<MessageResponse>>> getConversation(
            Authentication authentication,
            @RequestParam("otherUserId") Long otherUserId
    ) {
        return ResponseEntity.ok(ApiResponse.<List<MessageResponse>>builder()
                .success(true)
                .message("Lấy hội thoại thành công")
                .data(messageService.getConversation(authentication.getName(), otherUserId))
                .build());
    }

    @PostMapping
    public ResponseEntity<ApiResponse<MessageResponse>> sendMessage(
            Authentication authentication,
            @Valid @RequestBody MessageRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.<MessageResponse>builder()
                .success(true)
                .message("Gửi tin nhắn thành công")
                .data(messageService.sendMessage(authentication.getName(), request))
                .build());
    }
}
