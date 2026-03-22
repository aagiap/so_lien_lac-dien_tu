import { api, setAuthData } from '../api/config.js';
import { showToast } from '../utils/toast.js';

const LoginPage = {
    render: async () => {
        return `
            <div style="min-height: 100vh; display: flex; align-items: center; justify-content: center; background-color: var(--background);">
                <div class="card" style="width: 100%; max-width: 420px; padding: 2.5rem;">
                    <div style="text-align: center; margin-bottom: 2rem;">
                        <div style="width: 60px; height: 60px; background-color: var(--primary); border-radius: 16px; display: inline-flex; align-items: center; justify-content: center; margin-bottom: 1rem;">
                            <i class="fas fa-graduation-cap" style="color: white; font-size: 24px;"></i>
                        </div>
                        <h2 style="color: var(--primary); font-weight: 700; margin-bottom: 0.5rem;">SchoolApp Portal</h2>
                        <p style="color: var(--text-light); font-size: 0.9rem;">Hệ thống quản lý dành cho Giáo viên & Admin</p>
                    </div>

                    <form id="login-form">
                        <div class="form-group">
                            <label class="form-label" for="phone">Số điện thoại</label>
                            <div style="position: relative;">
                                <i class="fas fa-phone" style="position: absolute; left: 1rem; top: 1rem; color: var(--text-light);"></i>
                                <input type="tel" id="phone" class="form-control w-full" style="padding-left: 2.5rem;" placeholder="Nhập số điện thoại" required />
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label" for="password">Mật khẩu</label>
                            <div style="position: relative;">
                                <i class="fas fa-lock" style="position: absolute; left: 1rem; top: 1rem; color: var(--text-light);"></i>
                                <input type="password" id="password" class="form-control w-full" style="padding-left: 2.5rem;" placeholder="Nhập mật khẩu" required />
                            </div>
                        </div>

                        <div class="flex justify-between items-center" style="margin-bottom: 1.5rem; font-size: 0.875rem;">
                            <label style="display: flex; align-items: center; gap: 0.5rem; cursor: pointer;">
                                <input type="checkbox" id="remember" /> Ghi nhớ
                            </label>
                            <a href="#" style="color: var(--primary); font-weight: 600;">Quên mật khẩu?</a>
                        </div>

                        <button type="submit" class="btn btn-primary w-full" id="login-btn">
                            Đăng nhập
                        </button>
                    </form>

                    <!-- OTP Form for 2FA (Hidden initially) -->
                    <form id="otp-form" style="display: none; margin-top: -2rem;">
                         <div style="text-align: center; margin-bottom: 1.5rem;">
                            <h3 style="color: var(--text-dark); margin-bottom: 0.5rem;">Xác thực 2 lớp</h3>
                            <p style="color: var(--text-light); font-size: 0.875rem;">Vui lòng nhập mã gồm 6 chữ số từ ứng dụng Authenticator của bạn.</p>
                        </div>
                        <div class="form-group" style="text-align: center;">
                            <input type="text" id="otp-code" class="form-control" style="text-align: center; letter-spacing: 0.5rem; font-size: 1.5rem; font-weight: bold;" maxlength="6" placeholder="000000" required />
                        </div>
                         <button type="submit" class="btn btn-primary w-full" id="otp-submit-btn">
                            Xác thực
                        </button>
                        <div style="text-align: center; margin-top: 1rem;">
                           <a href="#" id="back-to-login" style="color: var(--text-light); font-size: 0.875rem;"><i class="fas fa-arrow-left"></i> Quay lại</a>
                        </div>
                    </form>
                </div>
            </div>
        `;
    },

    afterRender: async () => {
        const loginForm = document.getElementById('login-form');
        const otpForm = document.getElementById('otp-form');
        const loginBtn = document.getElementById('login-btn');
        const phoneInput = document.getElementById('phone');
        const passwordInput = document.getElementById('password');

        loginForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const phone = phoneInput.value.trim();
            const password = passwordInput.value;

            if (!phone || !password) return;

            try {
                loginBtn.innerHTML = '<div class="loader"></div>';
                loginBtn.disabled = true;

                const data = await api.post('/auth/login', { phone, password });

                if (data.requiresOtp) {
                    // Set temporary token needed for verify-otp call
                    setAuthData({ temporaryToken: data.temporaryToken });
                    
                    // Show OTP form
                    loginForm.style.display = 'none';
                    otpForm.style.display = 'block';
                    document.getElementById('otp-code').focus();
                } else {
                    handleLoginSuccess(data);
                }
            } catch (err) {
                showToast(err.message, 'error');
            } finally {
                loginBtn.innerHTML = 'Đăng nhập';
                loginBtn.disabled = false;
            }
        });

        // 2FA OTP Logic
        otpForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const otpCode = document.getElementById('otp-code').value.trim();
            const otpBtn = document.getElementById('otp-submit-btn');

            if (otpCode.length !== 6) {
                showToast('Mã OTP phải gồm 6 chữ số', 'error');
                return;
            }

            try {
                otpBtn.innerHTML = '<div class="loader"></div>';
                otpBtn.disabled = true;

                // useTempToken = true
                const data = await api.post('/auth/verify-otp', {
                    temporaryToken: localStorage.getItem('temporaryToken'),
                    otp: otpCode
                }, true);

                handleLoginSuccess(data);
            } catch (err) {
                showToast(err.message, 'error');
            } finally {
                otpBtn.innerHTML = 'Xác thực';
                otpBtn.disabled = false;
            }
        });

        document.getElementById('back-to-login').addEventListener('click', (e) => {
            e.preventDefault();
            otpForm.style.display = 'none';
            loginForm.style.display = 'block';
            localStorage.removeItem('temporaryToken');
        });
    }
};

function handleLoginSuccess(data) {
    if (!data.user.roles.includes('ADMIN') && !data.user.roles.includes('TEACHER')) {
        showToast('Tài khoản không có quyền truy cập Admin/Teacher Panel', 'error');
        return;
    }
    setAuthData(data);
    showToast('Đăng nhập thành công', 'success');
    setTimeout(() => window.location.hash = '#/dashboard', 500);
}

export default LoginPage;
