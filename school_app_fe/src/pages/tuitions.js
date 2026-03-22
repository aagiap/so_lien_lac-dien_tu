import { api } from '../api/config.js';
import { showToast } from '../utils/toast.js';

const TuitionsPage = {
    render: async () => {
        return `
            <div class="flex-col gap-6">
                <!-- Header Actions -->
                <div class="flex items-center justify-between">
                    <h2 style="font-size: 1.5rem; font-weight: 700; color: var(--text-dark);">Theo dõi giao dịch học phí</h2>
                </div>

                <!-- Table Card -->
                <div class="card" style="padding: 0;">
                    <div style="padding: 1.5rem; border-bottom: 1px solid var(--border);" class="flex items-center justify-between">
                        <h3 style="font-size: 1rem; font-weight: 600;">Danh sách Đóng học phí</h3>
                    </div>
                    <div class="table-container">
                        <table id="tuitions-table">
                            <thead style="background-color: var(--background);">
                                <tr>
                                    <th>HỌC SINH</th>
                                    <th>LỚP</th>
                                    <th>SỐ TIỀN</th>
                                    <th>HẠN NỘP / NGÀY NỘP</th>
                                    <th>HÌNH THỨC</th>
                                    <th>TRẠNG THÁI</th>
                                </tr>
                            </thead>
                            <tbody id="tuitions-body">
                                <tr><td colspan="6" style="text-align: center; padding: 2rem;"><div class="loader"></div></td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;
    },

    afterRender: async () => {
        await fetchAndRenderTuitions();
    }
};

async function fetchAndRenderTuitions() {
    const tbody = document.getElementById('tuitions-body');
    try {
        const payments = await api.get('/tuition-payments/all');
        
        if (!payments || payments.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 2rem; color: var(--text-light);">Không có khoản thu nào.</td></tr>';
            return;
        }

        tbody.innerHTML = payments.map(p => {
            const amountFormat = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(p.amount);
            const due = p.dueDate ? new Date(p.dueDate).toLocaleDateString('vi-VN') : '-';
            const paid = p.paidDate ? new Date(p.paidDate).toLocaleDateString('vi-VN') : '-';
            
            let statusBadge = '';
            if (p.status === 'PAID') statusBadge = '<span class="badge badge-success">Đã nộp</span>';
            else if (p.status === 'OVERDUE') statusBadge = '<span class="badge badge-danger">Quá hạn</span>';
            else if (p.status === 'PENDING') statusBadge = '<span class="badge badge-warning">Đang xử lý</span>';
            else statusBadge = '<span class="badge" style="background: var(--border); color: var(--text-dark);">Chưa nộp</span>';
            
            let methodDisplay = '-';
            if (p.paymentMethod === 'VNPAY') methodDisplay = '<span style="color: #0b6bb2; font-weight: 600;">VNPay</span>';
            else if (p.paymentMethod === 'CASH') methodDisplay = 'Tiền mặt';
            else if (p.paymentMethod === 'BANK_TRANSFER') methodDisplay = 'Chuyển khoản';
            else if (p.paymentMethod) methodDisplay = p.paymentMethod;

            return `
                <tr>
                    <td>
                        <div style="font-weight: 600; color: var(--text-dark);">${p.studentName}</div>
                    </td>
                    <td>${p.className}</td>
                    <td style="font-weight: 600; color: var(--primary);">${amountFormat}</td>
                    <td style="font-size: 0.875rem;">
                        <div style="color: var(--text-light);"><i class="fas fa-calendar-times"></i> Hạn: ${due}</div>
                        <div style="color: var(--text-dark); margin-top: 4px;"><i class="fas fa-check-circle" style="color: var(--success);"></i> Nộp: ${paid}</div>
                    </td>
                    <td>${methodDisplay}</td>
                    <td>${statusBadge}</td>
                </tr>
            `;
        }).join('');
    } catch (err) {
        tbody.innerHTML = `<tr><td colspan="6" style="text-align: center; padding: 2rem; color: var(--error);">Lỗi kết nối Backend: ${err.message}</td></tr>`;
    }
}

export default TuitionsPage;
