import { api } from '../api/config.js';
import { showToast } from '../utils/toast.js';

const LeaveRequestsPage = {
    render: async () => {
        return `
            <div class="flex-col gap-6">
                <!-- Header Actions -->
                <div class="flex items-center justify-between">
                    <h2 style="font-size: 1.5rem; font-weight: 700; color: var(--text-dark);">Quản lý phần xin nghỉ học</h2>
                </div>

                <!-- Table Card -->
                <div class="card" style="padding: 0;">
                    <div style="padding: 1.5rem; border-bottom: 1px solid var(--border);" class="flex items-center justify-between">
                        <h3 style="font-size: 1rem; font-weight: 600;">Danh sách Đơn xin nghỉ</h3>
                    </div>
                    <div class="table-container">
                        <table id="leave-requests-table">
                            <thead style="background-color: var(--background);">
                                <tr>
                                    <th>HỌC SINH</th>
                                    <th>LỚP</th>
                                    <th>THỜI GIAN NGHỈ</th>
                                    <th>LÝ DO</th>
                                    <th>TRẠNG THÁI</th>
                                    <th style="text-align: right;">HÀNH ĐỘNG</th>
                                </tr>
                            </thead>
                            <tbody id="leave-requests-body">
                                <tr><td colspan="6" style="text-align: center; padding: 2rem;"><div class="loader"></div></td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;
    },

    afterRender: async () => {
        await fetchAndRenderRequests();

        // Delegate event listener for Accept/Reject buttons
        document.getElementById('leave-requests-body').addEventListener('click', async (e) => {
            const btn = e.target.closest('button[data-action]');
            if (!btn) return;

            const id = btn.getAttribute('data-id');
            const action = btn.getAttribute('data-action');
            if (!id || !action) return;

            try {
                btn.innerHTML = '<div class="loader" style="width: 14px; height: 14px; border-width: 2px;"></div>';
                btn.disabled = true;

                await api.put(`/leave-requests/${id}/review`, {
                    status: action,
                    responseNote: action === 'APPROVED' ? 'Đã duyệt bởi Giáo viên/Admin.' : 'Yêu cầu không hợp lệ.'
                });

                showToast(`Đã ${action === 'APPROVED' ? 'duyệt' : 'từ chối'} đơn thành công`, 'success');
                await fetchAndRenderRequests();
            } catch (err) {
                showToast(err.message, 'error');
                btn.innerHTML = action === 'APPROVED' ? 'Duyệt' : 'Từ chối';
                btn.disabled = false;
            }
        });
    }
};

async function fetchAndRenderRequests() {
    const tbody = document.getElementById('leave-requests-body');
    try {
        const requests = await api.get('/leave-requests/all');
        
        if (!requests || requests.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 2rem; color: var(--text-light);">Không có đơn xin nghỉ nào.</td></tr>';
            return;
        }

        tbody.innerHTML = requests.map(r => {
            const from = new Date(r.fromDate).toLocaleDateString('vi-VN');
            const to = new Date(r.toDate).toLocaleDateString('vi-VN');
            const dateStr = from === to ? from : `${from} - ${to}`;

            let statusBadge = '';
            let actionButtons = '';
            
            if (r.status === 'PENDING') {
                statusBadge = '<span class="badge badge-warning">Chờ duyệt</span>';
                actionButtons = `
                    <div class="flex items-center gap-2" style="justify-content: flex-end;">
                        <button class="btn btn-outline" style="padding: 0.4rem 0.8rem; font-size: 0.8rem;" data-id="${r.id}" data-action="REJECTED">Từ chối</button>
                        <button class="btn btn-primary" style="padding: 0.4rem 0.8rem; font-size: 0.8rem;" data-id="${r.id}" data-action="APPROVED">Duyệt</button>
                    </div>
                `;
            } else if (r.status === 'APPROVED') {
                statusBadge = '<span class="badge badge-success">Đã duyệt</span>';
                actionButtons = `<span style="color: var(--text-light); font-size: 0.875rem;">Đã duyệt</span>`;
            } else {
                statusBadge = '<span class="badge badge-danger">Từ chối</span>';
                actionButtons = `<span style="color: var(--text-light); font-size: 0.875rem;">Đã từ chối</span>`;
            }

            return `
                <tr>
                    <td>
                        <div style="font-weight: 600; color: var(--text-dark);">${r.studentName}</div>
                    </td>
                    <td>${r.className}</td>
                    <td style="font-size: 0.875rem;">
                        <i class="fas fa-calendar-alt" style="color: var(--text-light); margin-right: 4px;"></i> ${dateStr}
                    </td>
                    <td style="max-width: 250px;">
                        <p style="margin: 0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="${r.reason}">
                            ${r.reason}
                        </p>
                    </td>
                    <td>${statusBadge}</td>
                    <td style="text-align: right;">${actionButtons}</td>
                </tr>
            `;
        }).join('');
    } catch (err) {
        tbody.innerHTML = `<tr><td colspan="6" style="text-align: center; padding: 2rem; color: var(--error);">Lỗi kết nối Backend: ${err.message}</td></tr>`;
    }
}

export default LeaveRequestsPage;
