import './styles/global.css';
import { getAuthToken } from './api/config.js';
import { renderLayout, bindLayoutEvents } from './components/Layout.js';
import LoginPage from './pages/login.js';
import DashboardPage from './pages/dashboard.js';
import LeaveRequestsPage from './pages/leave_requests.js';
import TuitionsPage from './pages/tuitions.js';
import ProfilePage from './pages/profile.js';
import GradesPage from './pages/grades.js';
import ChatPage from './pages/chat.js';
import AnnouncementsPage from './pages/announcements.js';
import ResetPasswordPage from './pages/reset_password.js';
import PaymentResultPage from './pages/payment_result.js';

// npm run dev -- --host
const routes = {
    '/login': LoginPage,
    '/dashboard': DashboardPage,
    '/leave-requests': LeaveRequestsPage,
    '/tuitions': TuitionsPage,
    '/profile': ProfilePage,
    '/grades': GradesPage,
    '/chat': ChatPage,
    '/announcements': AnnouncementsPage,
    '/reset-password': ResetPasswordPage,
    '/payment-result': PaymentResultPage,
};

async function router() {
    const defaultRoute = '/dashboard';
    let path = window.location.hash.replace('#', '') || defaultRoute;

    // Check auth
    const isAuthenticated = !!getAuthToken();
    
    // Ignore params when matching route
    const basePath = path.split('?')[0];

    // Allowed public routes
    const publicRoutes = ['/login', '/reset-password', '/payment-result'];
    
    if (!isAuthenticated && !publicRoutes.includes(basePath)) {
        window.location.hash = '/login';
        return;
    }
    
    if (isAuthenticated && basePath === '/login') {
        window.location.hash = '/dashboard';
        return;
    }

    const pageConfig = routes[basePath];
    const appDiv = document.getElementById('app');

    if (pageConfig) {
        // Render raw HTML for auth pages
        if (publicRoutes.includes(basePath)) {
            appDiv.innerHTML = await pageConfig.render();
        } else {
            appDiv.innerHTML = renderLayout(await pageConfig.render());
            bindLayoutEvents();
        }

        // Bind DOM events after render
        if (pageConfig.afterRender) {
            await pageConfig.afterRender();
        }
    } else {
        appDiv.innerHTML = '<div style="padding: 2rem;text-align:center;"><h2>404 - Not Found</h2></div>';
    }
}

window.addEventListener('hashchange', router);
window.addEventListener('load', router);
