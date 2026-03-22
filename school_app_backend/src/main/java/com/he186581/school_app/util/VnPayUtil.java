package com.he186581.school_app.util;

import com.he186581.school_app.entity.TuitionPayment;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Map;
import java.util.TimeZone;
import java.util.TreeMap;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Utility tạo URL thanh toán VNPay sandbox.
 * Dùng mức skeleton đơn giản cho đồ án sinh viên.
 */
@Component
public class VnPayUtil {

    @Value("${vnpay.tmn-code}")
    private String tmnCode;

    @Value("${vnpay.hash-secret}")
    private String hashSecret;

    @Value("${vnpay.pay-url}")
    private String payUrl;

    @Value("${vnpay.return-url}")
    private String returnUrl;

    public String createPaymentUrl(TuitionPayment payment, String clientIp) {
        try {
            Map<String, String> params = new TreeMap<>();
            params.put("vnp_Version", "2.1.0");
            params.put("vnp_Command", "pay");
            params.put("vnp_TmnCode", tmnCode);
            params.put("vnp_Amount", payment.getAmount().multiply(java.math.BigDecimal.valueOf(100)).toBigInteger().toString());
            params.put("vnp_CurrCode", "VND");
            params.put("vnp_TxnRef", payment.getVnpTxnRef());
            params.put("vnp_OrderInfo", payment.getOrderInfo() == null ? "Thanh toan hoc phi" : payment.getOrderInfo());
            params.put("vnp_OrderType", "other");
            params.put("vnp_Locale", "vn");
            params.put("vnp_ReturnUrl", returnUrl);
            params.put("vnp_IpAddr", clientIp == null ? "127.0.0.1" : clientIp);

            Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
            Date createDate = calendar.getTime();
            SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
            formatter.setTimeZone(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
            params.put("vnp_CreateDate", formatter.format(createDate));

            calendar.add(Calendar.MINUTE, 15);
            params.put("vnp_ExpireDate", formatter.format(calendar.getTime()));

            String queryUrl = buildQuery(params, true);
            String secureHash = hmacSHA512(hashSecret, queryUrl);

            return payUrl + "?" + queryUrl + "&vnp_SecureHashType=HmacSHA512" + "&vnp_SecureHash=" + secureHash;
        } catch (Exception ex) {
            throw new IllegalStateException("Không thể tạo URL thanh toán VNPay", ex);
        }
    }

    public boolean validateReturnData(Map<String, String> fields) {
        try {
            Map<String, String> sorted = new TreeMap<>(fields);
            String receivedHash = sorted.remove("vnp_SecureHash");
            sorted.remove("vnp_SecureHashType");

            String signData = buildQuery(sorted, true);
            String calculatedHash = hmacSHA512(hashSecret, signData);

            return calculatedHash.equalsIgnoreCase(receivedHash);
        } catch (Exception ex) {
            return false;
        }
    }

    private String buildQuery(Map<String, String> params, boolean encodeValue) {
        StringBuilder builder = new StringBuilder();

        for (Map.Entry<String, String> entry : params.entrySet()) {
            if (entry.getValue() == null || entry.getValue().isBlank()) {
                continue;
            }

            if (builder.length() > 0) {
                builder.append("&");
            }

            builder.append(entry.getKey()).append("=");
            builder.append(encodeValue
                    ? URLEncoder.encode(entry.getValue(), StandardCharsets.UTF_8)
                    : entry.getValue());
        }

        return builder.toString();
    }

    private String hmacSHA512(String key, String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA512");
            SecretKeySpec secretKeySpec = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
            mac.init(secretKeySpec);
            byte[] bytes = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));

            StringBuilder hash = new StringBuilder();
            for (byte b : bytes) {
                hash.append(String.format("%02x", b));
            }
            return hash.toString();
        } catch (Exception ex) {
            throw new IllegalStateException("Không thể mã hóa chữ ký VNPay", ex);
        }
    }
}
