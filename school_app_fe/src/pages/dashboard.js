import { getUser } from '../api/config.js';

const DashboardPage = {
    render: async () => {
        const user = getUser();
        return `
            <div class="flex-col gap-6">
                <!-- Welcome Banner -->
                <div class="card" style="background: linear-gradient(135deg, var(--primary) 0%, #0d47a1 100%); color: white; border: none;">
                    <h2 style="margin-bottom: 0.5rem; font-size: 1.5rem;">Xin chào, ${user?.fullName}! 👋</h2>
                    <p style="opacity: 0.9;">Chào mừng bạn quay lại hệ thống quản lý SchoolApp Portal.</p>
                </div>

                <!-- Quick Stats / Shortcuts -->
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 1.5rem;">
                    <a href="#/leave-requests" class="card flex items-center justify-between" style="cursor: pointer; transition: transform 0.2s;">
                        <div>
                            <h3 style="color: var(--text-light); font-size: 0.875rem; margin-bottom: 0.5rem; font-weight: 600;">QUẢN LÝ</h3>
                            <div style="font-size: 1.25rem; font-weight: 700; color: var(--text-dark);">Đơn Xin Nghỉ</div>
                        </div>
                        <div style="width: 48px; height: 48px; background-color: rgba(25, 118, 210, 0.1); border-radius: 12px; display: flex; align-items: center; justify-content: center;">
                            <i class="fas fa-envelope-open-text" style="color: var(--primary); font-size: 20px;"></i>
                        </div>
                    </a>

                    <a href="#/tuitions" class="card flex items-center justify-between" style="cursor: pointer; transition: transform 0.2s;">
                        <div>
                            <h3 style="color: var(--text-light); font-size: 0.875rem; margin-bottom: 0.5rem; font-weight: 600;">QUẢN LÝ</h3>
                            <div style="font-size: 1.25rem; font-weight: 700; color: var(--text-dark);">Học Phí</div>
                        </div>
                        <div style="width: 48px; height: 48px; background-color: rgba(67, 160, 71, 0.1); border-radius: 12px; display: flex; align-items: center; justify-content: center;">
                            <i class="fas fa-file-invoice-dollar" style="color: var(--success); font-size: 20px;"></i>
                        </div>
                    </a>

                    <a href="#/profile" class="card flex items-center justify-between" style="cursor: pointer; transition: transform 0.2s;">
                        <div>
                            <h3 style="color: var(--text-light); font-size: 0.875rem; margin-bottom: 0.5rem; font-weight: 600;">CÁ NHÂN</h3>
                            <div style="font-size: 1.25rem; font-weight: 700; color: var(--text-dark);">Bảo Mật & 2FA</div>
                        </div>
                        <div style="width: 48px; height: 48px; background-color: rgba(251, 140, 0, 0.1); border-radius: 12px; display: flex; align-items: center; justify-content: center;">
                            <i class="fas fa-shield-alt" style="color: var(--warning); font-size: 20px;"></i>
                        </div>
                    </a>
                </div>
            </div>
        `;
    },

    afterRender: async () => {
        // Add hover effects for cards
        document.querySelectorAll('.card[href]').forEach(card => {
            card.addEventListener('mouseenter', () => card.style.transform = 'translateY(-4px)');
            card.addEventListener('mouseleave', () => card.style.transform = 'translateY(0)');
        });
    }
};

export default DashboardPage;
