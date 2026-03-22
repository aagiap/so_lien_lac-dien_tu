import { api, getUser } from '../api/config.js';
import { showToast } from '../utils/toast.js';

const AnnouncementsPage = {
    render: async () => {
        return `
            <div class="flex-col gap-6">
                <!-- Header -->
                <div class="flex items-center justify-between">
                    <h2 style="font-size: 1.5rem; font-weight: 700; color: var(--text-dark);">Quản lý Thông báo Lớp</h2>
                </div>

                <div class="card" style="max-width: 800px;">
                    <h3 style="font-size: 1.125rem; font-weight: 600; margin-bottom: 1.5rem;">Tạo Thông Báo Mới</h3>
                    
                    <form id="announcement-form" class="flex-col gap-4">
                        <div>
                            <label class="form-label">Gửi đến Lớp</label>
                            <select id="select-class" class="form-control" required style="width: 100%;">
                                <option value="">-- Đang tải danh sách lớp... --</option>
                            </select>
                        </div>

                        <div>
                            <label class="form-label">Tiêu đề thông báo</label>
                            <input type="text" id="input-title" class="form-control" placeholder="Ví dụ: Nhắc nhở lịch thi Học kỳ..." required style="width: 100%;" />
                        </div>

                        <div>
                            <label class="form-label">Nội dung chi tiết</label>
                            <textarea id="input-content" class="form-control" rows="5" placeholder="Nhập chi tiết nội dung thông báo. Hệ thống sẽ tự động gửi Email và thông báo đẩy (Push Notification) đến toàn bộ học sinh trong lớp." required style="width: 100%;"></textarea>
                        </div>

                        <div style="margin-top: 1rem; text-align: right;">
                            <button type="submit" id="btn-submit" class="btn btn-primary">
                                <i class="fas fa-paper-plane" style="margin-right: 8px;"></i> Gửi Thông Báo
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        `;
    },

    afterRender: async () => {
        const selectClass = document.getElementById('select-class');
        const form = document.getElementById('announcement-form');
        const btnSubmit = document.getElementById('btn-submit');

        try {
            const classes = await api.get('/classes');
            selectClass.innerHTML = '<option value="">-- Chọn Lớp --</option>' + 
                classes.map(c => `<option value="${c.id}">${c.name}</option>`).join('');
        } catch (err) {
            showToast('Lỗi tải danh sách lớp', 'error');
        }

        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            const classId = selectClass.value;
            const title = document.getElementById('input-title').value.trim();
            const content = document.getElementById('input-content').value.trim();

            if (!classId || !title || !content) {
                showToast('Vui lòng điền đầy đủ thông tin', 'warning');
                return;
            }

            try {
                btnSubmit.disabled = true;
                btnSubmit.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang gửi...';

                await api.post('/announcements', {
                    classId: Number(classId),
                    title: title,
                    content: content
                });

                showToast('Gửi thông báo thành công!', 'success');
                form.reset();

            } catch (err) {
                showToast(err.message || 'Lỗi gửi thông báo', 'error');
            } finally {
                btnSubmit.disabled = false;
                btnSubmit.innerHTML = '<i class="fas fa-paper-plane" style="margin-right: 8px;"></i> Gửi Thông Báo';
            }
        });
    }
};

export default AnnouncementsPage;
