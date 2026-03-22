const PaymentResultPage = {
    render: async () => {
        return `
            <div class="flex items-center justify-center min-h-screen" style="background-color: var(--background);">
                <div class="card" style="width: 100%; max-width: 450px; padding: 2rem; text-align: center;">
                    <div id="payment-icon" style="width: 80px; height: 80px; border-radius: 40px; display: flex; align-items: center; justify-content: center; font-size: 2.5rem; margin: 0 auto 1.5rem auto;">
                        <div class="loader" style="width: 30px; height: 30px; border-top-color: var(--primary);"></div>
                    </div>
                    
                    <h2 id="payment-title" style="font-size: 1.5rem; font-weight: 700; color: var(--text-dark); margin-bottom: 0.5rem;">Đang xử lý...</h2>
                    <p id="payment-message" style="color: var(--text-light); font-size: 0.95rem; margin-bottom: 2rem;">Vui lòng chờ trong giây lát.</p>
                    
                    <div style="background-color: var(--primary-light); padding: 1rem; border-radius: 12px; margin-bottom: 2rem; display: none;" id="payment-details">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 0.5rem;">
                            <span style="color: var(--text-light); font-size: 0.875rem;">Mã giao dịch:</span>
                            <span id="payment-txn" style="font-weight: 600; color: var(--text-dark); font-size: 0.875rem;">---</span>
                        </div>
                        <div style="display: flex; justify-content: space-between;">
                            <span style="color: var(--text-light); font-size: 0.875rem;">Trạng thái:</span>
                            <span id="payment-status" style="font-weight: 600; font-size: 0.875rem;">---</span>
                        </div>
                    </div>
                    
                    <a href="#/tuitions" class="btn btn-primary w-full" style="display: inline-block; text-decoration: none;">
                        Quay lại danh sách học phí
                    </a>
                </div>
            </div>
        `;
    },

    afterRender: async () => {
        const urlParams = new URLSearchParams(window.location.search);
        let status = urlParams.get('status');
        let txnRef = urlParams.get('txnRef');
        
        if (!status) {
            const hashParts = window.location.hash.split('?');
            if (hashParts.length > 1) {
                const hashParams = new URLSearchParams(hashParts[1]);
                status = hashParams.get('status');
                txnRef = hashParams.get('txnRef');
            }
        }

        const iconEl = document.getElementById('payment-icon');
        const titleEl = document.getElementById('payment-title');
        const messageEl = document.getElementById('payment-message');
        const detailsEl = document.getElementById('payment-details');
        const txnEl = document.getElementById('payment-txn');
        const statusEl = document.getElementById('payment-status');

        if (status === 'PAID') {
            iconEl.style.backgroundColor = 'rgba(22, 163, 74, 0.1)';
            iconEl.style.color = 'var(--success)';
            iconEl.innerHTML = '<i class="fas fa-check"></i>';
            titleEl.textContent = 'Thanh toán thành công!';
            messageEl.textContent = 'Giao dịch qua VNPay đã được xử lý thành công. Cảm ơn bạn.';
            
            detailsEl.style.display = 'block';
            txnEl.textContent = txnRef || '---';
            statusEl.textContent = 'Đã thanh toán (PAID)';
            statusEl.style.color = 'var(--success)';
        } else {
            iconEl.style.backgroundColor = 'rgba(220, 38, 38, 0.1)';
            iconEl.style.color = 'var(--error)';
            iconEl.innerHTML = '<i class="fas fa-times"></i>';
            titleEl.textContent = 'Thanh toán thất bại';
            messageEl.textContent = 'Giao dịch qua VNPay đã bị hủy hoặc xảy ra lỗi. Vui lòng thử lại sau.';
            
            detailsEl.style.display = 'block';
            txnEl.textContent = txnRef || '---';
            statusEl.textContent = 'Chưa thanh toán (UNPAID)';
            statusEl.style.color = 'var(--error)';
        }
    }
};

export default PaymentResultPage;
