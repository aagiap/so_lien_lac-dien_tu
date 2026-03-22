import { api } from '../api/config.js';
import { showToast } from '../utils/toast.js';

const ResetPasswordPage = {
    render: async () => {
        return `
            <div class="flex items-center justify-center min-h-screen" style="background-color: var(--background);">
                <div class="card" style="width: 100%; max-width: 400px; padding: 2rem;">
                    <div class="text-center" style="margin-bottom: 2rem;">
                        <div style="width: 60px; height: 60px; background-color: var(--primary-light); color: var(--primary); border-radius: 30px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; margin: 0 auto 1rem auto;">
                            <i class="fas fa-key"></i>
                        </div>
                        <h2 style="font-size: 1.5rem; font-weight: 700; color: var(--text-dark);">Đặt lại mật khẩu</h2>
                        <p style="color: var(--text-light); font-size: 0.875rem; margin-top: 0.5rem;">Vui lòng nhập mật khẩu mới của bạn</p>
                    </div>

                    <form id="reset-password-form" class="flex-col gap-4">
                        <div class="form-group">
                            <label class="form-label">Mật khẩu mới</label>
                            <input type="password" id="new-password" class="form-control" placeholder="Nhập mật khẩu mới" required minlength="6"/>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Xác nhận mật khẩu</label>
                            <input type="password" id="confirm-password" class="form-control" placeholder="Nhập lại mật khẩu mới" required minlength="6"/>
                        </div>
                        <button type="submit" id="btn-reset" class="btn btn-primary w-full" style="margin-top: 1rem;">
                            Đổi mật khẩu
                        </button>
                    </form>
                    
                    <div style="text-align: center; margin-top: 1.5rem;">
                        <a href="#/login" style="color: var(--primary); text-decoration: none; font-size: 0.875rem; font-weight: 500;">
                            <i class="fas fa-arrow-left" style="margin-right: 4px;"></i> Quay lại đăng nhập
                        </a>
                    </div>
                </div>
            </div>
        `;
    },

    afterRender: async () => {
        const urlParams = new URLSearchParams(window.location.search);
        // The token might be in the hash if the URL is like /#/reset-password?token=...
        // Let's parse from hash as well
        let token = urlParams.get('token');
        if (!token) {
            const hashParts = window.location.hash.split('?');
            if (hashParts.length > 1) {
                const hashParams = new URLSearchParams(hashParts[1]);
                token = hashParams.get('token');
            }
        }

        if (!token) {
            showToast('Đường dẫn không hợp lệ hoặc đã hết hạn (thiếu token).', 'error');
            document.getElementById('reset-password-form').style.display = 'none';
            return;
        }

        const form = document.getElementById('reset-password-form');
        const newPasswordInput = document.getElementById('new-password');
        const confirmPasswordInput = document.getElementById('confirm-password');
        const btnReset = document.getElementById('btn-reset');

        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            const newPassword = newPasswordInput.value;
            const confirmPassword = confirmPasswordInput.value;

            if (newPassword !== confirmPassword) {
                showToast('Mật khẩu xác nhận không khớp.', 'error');
                return;
            }

            btnReset.innerHTML = '<div class="loader" style="width: 16px; height: 16px;"></div>';
            btnReset.disabled = true;

            try {
                // Require auth is false for this endpoint via the web api util if it doesn't have token,
                // but the endpoint is public anyway.
                await api.post('/auth/reset-password', {
                    token: token,
                    newPassword: newPassword,
                    confirmPassword: confirmPassword
                }, false);

                showToast('Đặt lại mật khẩu thành công. Vui lòng đăng nhập.', 'success');
                setTimeout(() => {
                    window.location.hash = '#/login';
                }, 1500);
            } catch (err) {
                showToast(err.message || 'Lỗi đặt lại mật khẩu.', 'error');
            } finally {
                btnReset.innerHTML = 'Đổi mật khẩu';
                btnReset.disabled = false;
            }
        });
    }
};

export default ResetPasswordPage;
