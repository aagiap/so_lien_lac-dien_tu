package com.he186581.school_app.service;

import com.he186581.school_app.dto.leave.LeaveRequestCreateRequest;
import com.he186581.school_app.dto.leave.LeaveRequestResponse;
import com.he186581.school_app.dto.leave.LeaveRequestReviewRequest;
import java.util.List;

public interface LeaveRequestService {

    LeaveRequestResponse createLeaveRequest(String studentUsername, LeaveRequestCreateRequest request);

    LeaveRequestResponse reviewLeaveRequest(Long requestId, String teacherUsername, LeaveRequestReviewRequest request);

    List<LeaveRequestResponse> getMyRequests(String studentUsername);

    List<LeaveRequestResponse> getAllRequests();
}
