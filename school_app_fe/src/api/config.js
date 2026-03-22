const BASE_URL = 'http://192.168.0.103:8080/api';

export const getAuthToken = () => localStorage.getItem('accessToken');
export const getTemporaryToken = () => localStorage.getItem('temporaryToken');
export const setAuthData = (data) => {
    if (data.accessToken) localStorage.setItem('accessToken', data.accessToken);
    if (data.refreshToken) localStorage.setItem('refreshToken', data.refreshToken);
    if (data.user) localStorage.setItem('user', JSON.stringify(data.user));
    if (data.temporaryToken) localStorage.setItem('temporaryToken', data.temporaryToken);
};
export const clearAuth = () => {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('user');
    localStorage.removeItem('temporaryToken');
};
export const getUser = () => {
    const userStr = localStorage.getItem('user');
    return userStr ? JSON.parse(userStr) : null;
};

// Generic Fetch Wrapper
async function fetchApi(endpoint, options = {}, useTempToken = false) {
    const token = useTempToken ? getTemporaryToken() : getAuthToken();
    const headers = {
        'Content-Type': 'application/json',
        ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
        ...options.headers,
    };

    try {
        const response = await fetch(`${BASE_URL}${endpoint}`, {
            ...options,
            headers,
        });

        if (response.status === 401 || response.status === 403) {
            clearAuth();
            window.location.hash = '#/login';
            throw new Error('Phiên đăng nhập hết hạn hoặc không có quyền truy cập');
        }

        const data = await response.json();
        
        if (!response.ok || !data.success) {
            throw new Error(data.message || `Lỗi server: ${response.status}`);
        }

        return data.data;
    } catch (error) {
        throw error;
    }
}

export const api = {
    get: (endpoint) => fetchApi(endpoint, { method: 'GET' }),
    post: (endpoint, body, useTempToken = false) => fetchApi(endpoint, {
        method: 'POST',
        body: JSON.stringify(body),
    }, useTempToken),
    put: (endpoint, body) => fetchApi(endpoint, {
        method: 'PUT',
        body: JSON.stringify(body),
    }),
    delete: (endpoint) => fetchApi(endpoint, { method: 'DELETE' }),
};
