import { api, getUser, getAuthToken } from '../api/config.js';
import { showToast } from '../utils/toast.js';

const ChatPage = {
    _stompClient: null,

    render: async () => {
        return `
            <div class="card" style="padding: 0; min-height: 600px; display: flex; overflow: hidden; height: calc(100vh - 120px);">
                <!-- Left Sidebar: Contacts Menu -->
                <div style="width: 300px; border-right: 1px solid var(--border); background-color: #fafbfc; display: flex; flex-direction: column;">
                    <div style="padding: 1rem; border-bottom: 1px solid var(--border); background-color: var(--white);">
                        <h3 style="font-size: 1.1rem; font-weight: 700; margin-bottom: 0.5rem;">Chat Liên Lạc</h3>
                        <div style="position: relative;">
                            <i class="fas fa-search" style="position: absolute; left: 1rem; top: 50%; transform: translateY(-50%); color: var(--text-light); font-size: 0.875rem;"></i>
                            <input type="text" id="search-contacts" class="form-control w-full" style="padding-left: 2.25rem; font-size: 0.875rem; padding-top: 0.6rem; padding-bottom: 0.6rem; border-radius: 20px;" placeholder="Tìm kiếm tài khoản..." />
                        </div>
                    </div>
                    
                    <div id="contacts-list" style="flex: 1; overflow-y: auto; display: flex; flex-direction: column;">
                        <div style="text-align: center; padding: 2rem;"><div class="loader"></div></div>
                    </div>
                </div>

                <!-- Right Pane: Chat History -->
                <div style="flex: 1; display: flex; flex-direction: column; background-color: var(--white);">
                    <!-- Chat Header -->
                    <div id="chat-header" style="height: 65px; border-bottom: 1px solid var(--border); display: flex; align-items: center; padding: 0 1.5rem; background-color: var(--white);">
                        <div id="chat-header-info" style="display: none; align-items: center; gap: 1rem;">
                            <div style="width: 40px; height: 40px; border-radius: 20px; background-color: var(--primary); color: white; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 1.2rem;" id="chat-header-avatar"></div>
                            <div>
                                <h4 id="chat-header-name" style="font-weight: 600; font-size: 1rem; margin: 0;"></h4>
                                <span id="chat-header-role" style="font-size: 0.75rem; color: var(--text-light);"></span>
                            </div>
                        </div>
                        <div id="chat-placeholder" style="color: var(--text-light); font-weight: 500; text-align: center; width: 100%;">
                            Vui lòng chọn một người để bắt đầu trò chuyện.
                        </div>
                    </div>

                    <!-- Chat Messages Area -->
                    <div id="chat-messages" style="flex: 1; padding: 1.5rem; overflow-y: auto; background-color: #f0f2f5; display: flex; flex-direction: column; gap: 1rem;">
                        <!-- Messages go here -->
                    </div>

                    <!-- Chat Input Area -->
                    <div style="padding: 1rem 1.5rem; border-top: 1px solid var(--border); background-color: var(--white);">
                        <form id="chat-form" style="display: flex; gap: 1rem;">
                            <input type="text" id="chat-input" class="form-control" style="flex: 1; border-radius: 24px;" placeholder="Nhập tin nhắn..." disabled required />
                            <button type="submit" id="chat-send" class="btn btn-primary" style="border-radius: 24px; padding: 0.5rem 1.5rem;" disabled>
                                <i class="fas fa-paper-plane"></i>
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <style>
                .contact-item {
                    display: flex;
                    align-items: center;
                    gap: 1rem;
                    padding: 1rem 1.25rem;
                    cursor: pointer;
                    border-bottom: 1px solid var(--border);
                    transition: background-color 0.2s;
                }
                .contact-item:hover { background-color: var(--secondary); }
                .contact-item.active { background-color: var(--secondary); border-left: 3px solid var(--primary); padding-left: calc(1.25rem - 3px); }
                
                .msg-bubble {
                    max-width: 60%;
                    padding: 0.75rem 1rem;
                    border-radius: 16px;
                    font-size: 0.95rem;
                    line-height: 1.4;
                    position: relative;
                }
                .msg-bubble .time {
                    font-size: 0.65rem;
                    opacity: 0.7;
                    display: block;
                    margin-top: 0.25rem;
                    text-align: right;
                }
                .msg-own {
                    align-self: flex-end;
                    background-color: var(--primary);
                    color: white;
                    border-bottom-right-radius: 4px;
                }
                .msg-other {
                    align-self: flex-start;
                    background-color: var(--white);
                    border: 1px solid var(--border);
                    color: var(--text-dark);
                    border-bottom-left-radius: 4px;
                }
            </style>
        `;
    },

    afterRender: async () => {
        const currentUser = getUser();
        let selectedUserId = null;
        let allContacts = [];

        const contactsList = document.getElementById('contacts-list');
        const chatHeaderInfo = document.getElementById('chat-header-info');
        const chatPlaceholder = document.getElementById('chat-placeholder');
        const chatMessages = document.getElementById('chat-messages');
        const chatInput = document.getElementById('chat-input');
        const chatSendBtn = document.getElementById('chat-send');
        const chatForm = document.getElementById('chat-form');
        const searchInput = document.getElementById('search-contacts');

        // ─── Connect STOMP for real-time messages ───
        connectStomp();

        function connectStomp() {
            try {
                const token = getAuthToken();
                if (!token || typeof SockJS === 'undefined' || typeof StompJs === 'undefined') return;

                const socket = new SockJS('http://192.168.0.100:8080/ws');
                const client = new StompJs.Client({
                    webSocketFactory: () => socket,
                    connectHeaders: { 'Authorization': `Bearer ${token}` },
                    reconnectDelay: 5000,
                    onConnect: () => {
                        console.log('STOMP Connected (chat page)');
                        client.subscribe('/user/queue/messages', (message) => {
                            const msg = JSON.parse(message.body);
                            // If this message belongs to the active conversation, append it
                            if (selectedUserId && (String(msg.senderId) === String(selectedUserId))) {
                                appendMessage(msg);
                            }
                        });
                    },
                    onStompError: (frame) => {
                        console.error('STOMP Error:', frame.headers['message']);
                    }
                });
                client.activate();
                ChatPage._stompClient = client;
            } catch (err) {
                console.warn('STOMP connect failed:', err);
            }
        }

        function appendMessage(m) {
            const isOwn = m.senderId === currentUser.id;
            let date;
            if (Array.isArray(m.createdAt)) {
                date = new Date(m.createdAt[0], m.createdAt[1] - 1, m.createdAt[2], m.createdAt[3], m.createdAt[4], m.createdAt[5] || 0);
            } else if (m.sentAt) {
                if (Array.isArray(m.sentAt)) {
                    date = new Date(m.sentAt[0], m.sentAt[1] - 1, m.sentAt[2], m.sentAt[3], m.sentAt[4], m.sentAt[5] || 0);
                } else {
                    date = new Date(m.sentAt);
                }
            } else if (m.createdAt) {
                date = new Date(m.createdAt);
            } else {
                date = new Date();
            }
            const timeStr = date.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' }) + ' ' + date.toLocaleDateString('vi-VN');
            
            const html = `
                <div class="msg-bubble ${isOwn ? 'msg-own' : 'msg-other'}">
                    <div>${m.content}</div>
                    <span class="time" style="color: ${isOwn ? 'rgba(255,255,255,0.7)' : 'var(--text-light)'};">${timeStr}</span>
                </div>
            `;
            chatMessages.insertAdjacentHTML('beforeend', html);
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }

        // Fetch contacts
        try {
            const rawUsers = await api.get('/users/directory');
            // Remove self from list
            allContacts = rawUsers.filter(u => u.id !== currentUser.id);
            renderContacts(allContacts);
        } catch (err) {
            contactsList.innerHTML = `<div style="text-align:center; padding: 1rem; color: var(--error);">Lỗi kết nối Backend</div>`;
        }

        function renderContacts(users) {
            if (users.length === 0) {
                contactsList.innerHTML = `<div style="text-align:center; padding: 1.5rem; color: var(--text-light); font-size: 0.875rem;">Không tìm thấy kết quả.</div>`;
                return;
            }

            contactsList.innerHTML = users.map(u => {
                const roleDisplay = u.roles.includes('ADMIN') ? 'Admin' 
                                  : u.roles.includes('TEACHER') ? 'Giáo viên' 
                                  : u.roles.includes('PARENT') ? 'Phụ huynh' : 'Học sinh';
                const initial = u.fullName ? u.fullName.charAt(0).toUpperCase() : '?';
                
                return `
                    <div class="contact-item" data-id="${u.id}" data-name="${u.fullName}" data-role="${roleDisplay}" data-initial="${initial}">
                        <div style="width: 40px; height: 40px; border-radius: 20px; background-color: #ebf0f8; color: var(--primary); display: flex; align-items: center; justify-content: center; font-weight: bold; flex-shrink: 0;">
                            ${initial}
                        </div>
                        <div style="flex: 1; overflow: hidden;">
                            <div style="font-weight: 600; font-size: 0.9rem; color: var(--text-dark); white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">${u.fullName}</div>
                            <div style="font-size: 0.75rem; color: var(--text-light); margin-top: 2px;">${roleDisplay}</div>
                        </div>
                    </div>
                `;
            }).join('');
        }

        // Search contacts
        searchInput.addEventListener('input', (e) => {
            const term = e.target.value.toLowerCase();
            const filtered = allContacts.filter(u => 
                (u.fullName || '').toLowerCase().includes(term) || 
                (u.phone || '').includes(term)
            );
            renderContacts(filtered);
            if (selectedUserId) { // Re-apply active class if selected user is still in list
                const activeEl = contactsList.querySelector(`[data-id="${selectedUserId}"]`);
                if (activeEl) activeEl.classList.add('active');
            }
        });

        // Click on contact
        contactsList.addEventListener('click', async (e) => {
            const item = e.target.closest('.contact-item');
            if (!item) return;

            // Update UI state
            document.querySelectorAll('.contact-item').forEach(c => c.classList.remove('active'));
            item.classList.add('active');

            selectedUserId = item.getAttribute('data-id');
            const name = item.getAttribute('data-name');
            const role = item.getAttribute('data-role');
            const initial = item.getAttribute('data-initial');

            chatPlaceholder.style.display = 'none';
            chatHeaderInfo.style.display = 'flex';
            document.getElementById('chat-header-name').textContent = name;
            document.getElementById('chat-header-role').textContent = role;
            document.getElementById('chat-header-avatar').textContent = initial;

            chatInput.disabled = false;
            chatSendBtn.disabled = false;
            chatInput.focus();

            await fetchChatHistory(selectedUserId);
        });

        async function fetchChatHistory(otherId) {
            chatMessages.innerHTML = '<div style="text-align:center; padding: 2rem;"><div class="loader"></div></div>';
            try {
                const msgs = await api.get(`/messages?otherUserId=${otherId}`);
                
                if (!msgs || msgs.length === 0) {
                    chatMessages.innerHTML = `<div style="text-align:center; padding: 2rem; color: var(--text-light); font-size: 0.9rem;">Chưa có tin nhắn nào. Bắt đầu trò chuyện!</div>`;
                    return;
                }

                chatMessages.innerHTML = msgs.map(m => {
                    const isOwn = m.senderId === currentUser.id;
                    let date;
                    if (Array.isArray(m.sentAt)) {
                        date = new Date(m.sentAt[0], m.sentAt[1] - 1, m.sentAt[2], m.sentAt[3], m.sentAt[4], m.sentAt[5] || 0);
                    } else if (m.sentAt) {
                        date = new Date(m.sentAt);
                    } else if (Array.isArray(m.createdAt)) {
                        date = new Date(m.createdAt[0], m.createdAt[1] - 1, m.createdAt[2], m.createdAt[3], m.createdAt[4], m.createdAt[5] || 0);
                    } else if (m.createdAt) {
                        date = new Date(m.createdAt);
                    } else {
                        date = new Date();
                    }
                    const timeStr = date.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' }) + ' ' + date.toLocaleDateString('vi-VN');
                    
                    return `
                        <div class="msg-bubble ${isOwn ? 'msg-own' : 'msg-other'}">
                            <div>${m.content}</div>
                            <span class="time" style="color: ${isOwn ? 'rgba(255,255,255,0.7)' : 'var(--text-light)'};">${timeStr}</span>
                        </div>
                    `;
                }).join('');

                // Scroll to bottom
                chatMessages.scrollTop = chatMessages.scrollHeight;

            } catch (err) {
                chatMessages.innerHTML = `<div style="text-align:center; padding: 2rem; color: var(--error);">Lỗi tải tin nhắn: ${err.message}</div>`;
            }
        }

        // Send message form
        chatForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const text = chatInput.value.trim();
            if (!text || !selectedUserId) return;

            try {
                // Optimistic UI update could be added here, but let's wait for API to ensure it's saved
                chatInput.disabled = true;
                chatSendBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';

                const msg = await api.post('/messages', {
                    receiverId: Number(selectedUserId),
                    content: text
                });

                chatInput.value = '';
                // Append own message inline instead of refetching entire history
                appendMessage(msg);

            } catch (err) {
                showToast(err.message, 'error');
            } finally {
                chatInput.disabled = false;
                chatSendBtn.innerHTML = '<i class="fas fa-paper-plane"></i>';
                chatInput.focus();
            }
        });
    },

    // Called when navigating away from the page
    destroy: () => {
        if (ChatPage._stompClient) {
            ChatPage._stompClient.deactivate();
            ChatPage._stompClient = null;
        }
    }
};

export default ChatPage;
