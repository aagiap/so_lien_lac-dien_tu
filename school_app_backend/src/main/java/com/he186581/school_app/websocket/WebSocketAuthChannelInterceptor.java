package com.he186581.school_app.websocket;

import com.he186581.school_app.security.CustomUserDetailsService;
import com.he186581.school_app.util.JwtUtil;
import io.jsonwebtoken.JwtException;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

/**
 * Xác thực JWT cho kết nối WebSocket STOMP.
 */
@Component
@RequiredArgsConstructor
public class WebSocketAuthChannelInterceptor implements ChannelInterceptor {

    private final JwtUtil jwtUtil;
    private final CustomUserDetailsService customUserDetailsService;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        if (accessor != null && StompCommand.CONNECT.equals(accessor.getCommand())) {
            String authHeader = null;

            if (accessor.getNativeHeader("Authorization") != null && !accessor.getNativeHeader("Authorization").isEmpty()) {
                authHeader = accessor.getNativeHeader("Authorization").get(0);
            } else if (accessor.getNativeHeader("token") != null && !accessor.getNativeHeader("token").isEmpty()) {
                authHeader = accessor.getNativeHeader("token").get(0);
            }

            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String jwt = authHeader.substring(7);

                try {
                    if (jwtUtil.isAccessToken(jwt)) {
                        String username = jwtUtil.extractUsername(jwt);
                        UserDetails userDetails = customUserDetailsService.loadUserByUsername(username);

                        if (jwtUtil.validateToken(jwt, userDetails.getUsername())) {
                            UsernamePasswordAuthenticationToken authentication =
                                    new UsernamePasswordAuthenticationToken(
                                            userDetails,
                                            null,
                                            userDetails.getAuthorities()
                                    );
                            accessor.setUser(authentication);
                        }
                    }
                } catch (JwtException | IllegalArgumentException ex) {
                    // Bỏ qua token lỗi, client sẽ không được set Principal.
                }
            }
        }

        return message;
    }
}
