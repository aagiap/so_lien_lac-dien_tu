import { api, getUser, setAuthData } from '../api/config.js';
import { showToast } from '../utils/toast.js';
import QRCode from 'qrcode'; // Make sure npm install qrcode is done

const ProfilePage = {
    render: async () => {
        const user = getUser();
        const dob = user?.dateOfBirth ? new Date(user.dateOfBirth).toLocaleDateString('vi-VN') : 'Không có';
        const gender = user?.gender === 'MALE' ? 'Nam' : user?.gender === 'FEMALE' ? 'Nữ' : 'Khác';
        
        return `
            <div class="flex-col gap-6">
                <div class="card flex-col gap-4">
                    <h2 style="font-size: 1.25rem; font-weight: 700; border-bottom: 1px solid var(--border); padding-bottom: 1rem;">Thông tin cá nhân</h2>
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                        <div>
                            <p class="form-label" style="color: var(--text-light); margin-bottom: 0.25rem;">Họ và tên</p>
                            <p style="font-weight: 500;">${user?.fullName || 'N/A'}</p>
                        </div>
                        <div>
                            <p class="form-label" style="color: var(--text-light); margin-bottom: 0.25rem;">Số điện thoại</p>
                            <p style="font-weight: 500;">${user?.phone || 'N/A'}</p>
                        </div>
                        <div>
                            <p class="form-label" style="color: var(--text-light); margin-bottom: 0.25rem;">Email</p>
                            <p style="font-weight: 500;">${user?.email || 'N/A'}</p>
                        </div>
                        <div>
                            <p class="form-label" style="color: var(--text-light); margin-bottom: 0.25rem;">Giới tính</p>
                            <p style="font-weight: 500;">${gender}</p>
                        </div>
                        <div>
                            <p class="form-label" style="color: var(--text-light); margin-bottom: 0.25rem;">Ngày sinh</p>
                            <p style="font-weight: 500;">${dob}</p>
                        </div>
                        <div>
                            <p class="form-label" style="color: var(--text-light); margin-bottom: 0.25rem;">Địa chỉ</p>
                            <p style="font-weight: 500;">${user?.address || 'N/A'}</p>
                        </div>
                    </div>
                </div>

                <div class="card flex-col gap-4">
                    <h2 style="font-size: 1.25rem; font-weight: 700; border-bottom: 1px solid var(--border); padding-bottom: 1rem;">Cài đặt bảo mật (2FA)</h2>
                    
                    <div class="flex items-center justify-between" style="padding: 1rem; background-color: var(--background); border-radius: 12px;">
                        <div>
                            <h4 style="font-weight: 600; margin-bottom: 0.25rem;">Xác thực 2 yếu tố (2FA)</h4>
                            <p style="font-size: 0.875rem; color: var(--text-light);">Bảo vệ tài khoản bằng mã OTP từ ứng dụng Google Authenticator</p>
                        </div>
                        <div>
                            ${user?.twoFactorEnabled 
                                ? '<button id="btn-disable-2fa" class="btn" style="background-color: var(--error); color: white; border: none;"><i class="fas fa-shield-alt"></i> Tắt 2FA</button>' 
                                : '<button id="btn-setup-2fa" class="btn btn-primary">Bật 2FA ngay</button>'}
                        </div>
                    </div>
                </div>
            </div>

            <!-- Modal Setup 2FA -->
            <div id="modal-2fa" style="display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center;">
                <div class="card" style="width: 400px; max-width: 90%; animation: slideDown 0.3s ease;">
                    <div class="flex justify-between items-center" style="margin-bottom: 1.5rem;">
                        <h3 style="font-size: 1.25rem; font-weight: 700;">Cấu hình 2FA</h3>
                        <button id="close-modal" style="background: none; border: none; font-size: 1.25rem; cursor: pointer; color: var(--text-light);"><i class="fas fa-times"></i></button>
                    </div>
                    
                    <div id="qr-loading" style="text-align: center; padding: 2rem;">
                        <div class="loader"></div>
                        <p style="margin-top: 1rem; color: var(--text-light);">Đang tạo mã QR...</p>
                    </div>

                    <div id="qr-content" style="display: none; text-align: center;">
                        <p style="font-size: 0.875rem; color: var(--text-dark); margin-bottom: 1rem;">1. Quét mã QR dưới đây bằng ứng dụng Google Authenticator (hoặc Authy)</p>
                        <canvas id="qr-canvas" style="margin-bottom: 1rem; border: 1px solid var(--border); border-radius: 8px; padding: 0.5rem;"></canvas>
                        
                        <p style="font-size: 0.875rem; color: var(--text-dark); margin-bottom: 0.5rem;">2. Nhập mã OTP 6 số hiện trên app để xác nhận</p>
                        <form id="form-enable-2fa" class="flex gap-2">
                            <input type="text" id="setup-otp" class="form-control" style="flex: 1; letter-spacing: 2px; text-align: center; font-weight: bold;" maxlength="6" placeholder="000000" required />
                            <button type="submit" id="btn-confirm-2fa" class="btn btn-primary">Xác nhận</button>
                        </form>
                    </div>
                </div>
            </div>

            <style>
                @keyframes slideDown {
                    from { transform: translateY(-20px); opacity: 0; }
                    to { transform: translateY(0); opacity: 1; }
                }
            </style>
        `;
    },

    afterRender: async () => {
        const btnSetup = document.getElementById('btn-setup-2fa');
        const modal = document.getElementById('modal-2fa');
        const btnClose = document.getElementById('close-modal');
        const formEnable = document.getElementById('form-enable-2fa');
        
        if (btnSetup) {
            btnSetup.addEventListener('click', async () => {
                modal.style.display = 'flex';
                document.getElementById('qr-loading').style.display = 'block';
                document.getElementById('qr-content').style.display = 'none';

                try {
                    const data = await api.post('/auth/setup-2fa', {});
                    // Set QR canvas
                    const canvas = document.getElementById('qr-canvas');
                    await QRCode.toCanvas(canvas, data.otpAuthUrl, { width: 200, margin: 2 });
                    
                    document.getElementById('qr-loading').style.display = 'none';
                    document.getElementById('qr-content').style.display = 'block';
                } catch (err) {
                    modal.style.display = 'none';
                    showToast(err.message, 'error');
                }
            });
        }

        // Disable 2FA handler
        const btnDisable = document.getElementById('btn-disable-2fa');
        if (btnDisable) {
            btnDisable.addEventListener('click', async () => {
                if (!confirm('Bạn có chắc muốn tắt xác thực 2 yếu tố? Tài khoản sẽ kém bảo mật hơn.')) return;
                
                btnDisable.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang tắt...';
                btnDisable.disabled = true;

                try {
                    await api.post('/auth/disable-2fa', {});
                    const user = getUser();
                    user.twoFactorEnabled = false;
                    setAuthData({ user });
                    showToast('Đã tắt 2FA thành công', 'success');
                    setTimeout(() => window.location.reload(), 1000);
                } catch (err) {
                    showToast(err.message, 'error');
                    btnDisable.innerHTML = '<i class="fas fa-shield-alt"></i> Tắt 2FA';
                    btnDisable.disabled = false;
                }
            });
        }

        if (btnClose) {
            btnClose.addEventListener('click', () => {
                modal.style.display = 'none';
            });
        }

        if (formEnable) {
            formEnable.addEventListener('submit', async (e) => {
                e.preventDefault();
                const otp = document.getElementById('setup-otp').value.trim();
                const btnConfirm = document.getElementById('btn-confirm-2fa');
                
                if (otp.length !== 6) return;

                btnConfirm.innerHTML = '<div class="loader" style="width: 16px; height: 16px;"></div>';
                btnConfirm.disabled = true;

                try {
                    await api.post('/auth/enable-2fa', { otp });
                    
                    // Update local storage user state to reflect 2FA enabled
                    const user = getUser();
                    user.twoFactorEnabled = true;
                    setAuthData({ user });

                    showToast('Đã Bật 2FA thành công!', 'success');
                    modal.style.display = 'none';
                    setTimeout(() => window.location.reload(), 1000);
                } catch (err) {
                    showToast(err.message, 'error');
                } finally {
                    btnConfirm.innerHTML = 'Xác nhận';
                    btnConfirm.disabled = false;
                }
            });
        }
    }
};

export default ProfilePage;
