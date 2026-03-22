package com.he186581.school_app.dto.message;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class MessageRequest {

    @NotNull(message = "Receiver id không được để trống")
    private Long receiverId;

    @NotBlank(message = "Nội dung tin nhắn không được để trống")
    private String content;
}
