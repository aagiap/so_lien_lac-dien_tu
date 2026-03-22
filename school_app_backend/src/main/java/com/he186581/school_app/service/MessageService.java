package com.he186581.school_app.service;

import com.he186581.school_app.dto.message.MessageRequest;
import com.he186581.school_app.dto.message.MessageResponse;
import java.util.List;

public interface MessageService {

    MessageResponse sendMessage(String senderUsername, MessageRequest request);

    List<MessageResponse> getConversation(String currentUsername, Long otherUserId);
}
