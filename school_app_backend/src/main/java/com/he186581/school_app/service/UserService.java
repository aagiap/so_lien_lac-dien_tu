package com.he186581.school_app.service;

import com.he186581.school_app.dto.user.ChangePasswordRequest;
import com.he186581.school_app.dto.user.UpdateUserRequest;
import com.he186581.school_app.dto.user.UserResponse;
import com.he186581.school_app.entity.User;

public interface UserService {

    UserResponse getCurrentUser(String username);

    java.util.List<UserResponse> getAllUsers();

    UserResponse updateCurrentUser(String username, UpdateUserRequest request);

    void changePassword(String username, ChangePasswordRequest request);

    User getEntityByUsername(String username);
}
