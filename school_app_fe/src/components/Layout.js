import { getUser, clearAuth } from '../api/config.js';

export function renderLayout(contentHTML) {
    const user = getUser();
    const roleMatch = user?.roles?.[0] || 'GUEST';
    let roleDisplay = roleMatch;
    if (roleDisplay === 'TEACHER') roleDisplay = 'Giáo viên';
    if (roleDisplay === 'ADMIN') roleDisplay = 'Admin';

    return `
        <div class="app-layout">
            <aside class="sidebar">
                <div style="padding: 2rem; border-bottom: 1px solid var(--border);">
                    <h2 style="color: var(--primary); font-weight: 700; display: flex; align-items: center; gap: 10px;">
                        <i class="fas fa-school"></i> SchoolApp
                    </h2>
                </div>
                <ul style="padding: 1rem 0; flex: 1; display: flex; flex-direction: column; gap: 0.5rem;">
                    <li>
                        <a href="#/dashboard" class="sidebar-link" data-path="/dashboard">
                            <i class="fas fa-home"></i> Tổng quan
                        </a>
                    </li>
                    <li>
                        <a href="#/leave-requests" class="sidebar-link" data-path="/leave-requests">
                            <i class="fas fa-envelope-open-text"></i> Đơn xin nghỉ
                        </a>
                    </li>
                    <li>
                        <a href="#/announcements" class="sidebar-link" data-path="/announcements">
                            <i class="fas fa-bullhorn"></i> Gửi thông báo
                        </a>
                    </li>
                    <li>
                        <a href="#/grades" class="sidebar-link" data-path="/grades">
                            <i class="fas fa-marker"></i> Nhập điểm
                        </a>
                    </li>
                    <li>
                        <a href="#/tuitions" class="sidebar-link" data-path="/tuitions">
                            <i class="fas fa-file-invoice-dollar"></i> Học phí
                        </a>
                    </li>
                    <li>
                        <a href="#/chat" class="sidebar-link" data-path="/chat">
                            <i class="fas fa-comments"></i> Trò chuyện
                        </a>
                    </li>
                </ul>
                <div style="padding: 1.5rem; border-top: 1px solid var(--border);">
                    <a href="#/profile" class="sidebar-link" data-path="/profile">
                        <i class="fas fa-user-circle"></i> Cá nhân
                    </a>
                    <button id="logout-btn" class="btn btn-outline" style="width: 100%; margin-top: 0.5rem;">
                        <i class="fas fa-sign-out-alt"></i> Đăng xuất
                    </button>
                </div>
            </aside>
            <main class="main-content">
                <header class="topbar">
                    <h3 id="page-title" style="font-weight: 600; color: var(--text-dark);">Dashboard</h3>
                    <div class="flex items-center gap-4">
                        <div style="text-align: right;">
                            <div style="font-weight: 600; font-size: 0.9rem;">${user?.fullName || 'User'}</div>
                            <div style="font-size: 0.75rem; color: var(--text-light);">${roleDisplay}</div>
                        </div>
                        <div style="width: 40px; height: 40px; border-radius: 20px; background-color: var(--primary); color: white; display: flex; align-items: center; justify-content: center; font-weight: bold;">
                            ${user?.fullName?.charAt(0) || 'U'}
                        </div>
                    </div>
                </header>
                <div class="content-area">
                    ${contentHTML}
                </div>
            </main>
        </div>
        <style>
            .sidebar-link {
                display: flex;
                align-items: center;
                gap: 12px;
                padding: 0.875rem 2rem;
                color: var(--text-light);
                font-weight: 500;
                transition: all 0.2s;
            }
            .sidebar-link:hover {
                background-color: var(--secondary);
                color: var(--primary);
            }
            .sidebar-link.active {
                background-color: var(--secondary);
                color: var(--primary);
                border-right: 3px solid var(--primary);
            }
        </style>
    `;
}

export function bindLayoutEvents() {
    const logoutBtn = document.getElementById('logout-btn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', () => {
            clearAuth();
            window.location.hash = '#/login';
        });
    }

    // Highlight active link
    const currentHash = window.location.hash.replace('#', '') || '/dashboard';
    document.querySelectorAll('.sidebar-link').forEach(link => {
        if (link.getAttribute('data-path') === currentHash) {
            link.classList.add('active');
            const pageTitle = document.getElementById('page-title');
            if (pageTitle) pageTitle.textContent = link.textContent.trim();
        } else {
            link.classList.remove('active');
        }
    });
}
