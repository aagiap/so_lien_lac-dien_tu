package com.he186581.school_app.dto.tuition;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VnPayUrlResponse {

    private String paymentUrl;
    private String txnRef;
}
