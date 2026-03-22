import { api, getUser } from '../api/config.js';
import { showToast } from '../utils/toast.js';

const GradesPage = {
    render: async () => {
        return `
            <div class="flex-col gap-6">
                <!-- Header Actions -->
                <div class="flex items-center justify-between">
                    <h2 style="font-size: 1.5rem; font-weight: 700; color: var(--text-dark);">Sổ Điểm Giáo Viên</h2>
                </div>

                <!-- Filters Card -->
                <div class="card flex items-center gap-4">
                    <div style="flex: 1;">
                        <label class="form-label">Chọn Lớp học</label>
                        <select id="select-class" class="form-control w-full">
                            <option value="">-- Đang tải lớp... --</option>
                        </select>
                    </div>
                    <div style="flex: 1;">
                        <label class="form-label">Chọn Môn học</label>
                        <select id="select-subject" class="form-control w-full" disabled>
                            <option value="">-- Đang tải môn... --</option>
                        </select>
                    </div>
                    <div style="flex: 1;">
                        <label class="form-label">Học kỳ</label>
                        <select id="select-semester" class="form-control w-full" disabled>
                            <option value="SEMESTER_1">Học Kỳ 1</option>
                            <option value="SEMESTER_2">Học Kỳ 2</option>
                        </select>
                    </div>
                </div>

                <!-- Table Card -->
                <div class="card" style="padding: 0; min-height: 400px;">
                    <div style="padding: 1.5rem; border-bottom: 1px solid var(--border);">
                        <h3 style="font-size: 1rem; font-weight: 600;">Danh sách Học sinh nhập điểm</h3>
                        <p style="font-size: 0.875rem; color: var(--text-light); margin-top: 4px;">Vui lòng chọn Lớp và Môn học để bắt đầu nhập điểm.</p>
                    </div>
                    <div class="table-container">
                        <table id="grades-table">
                            <thead style="background-color: var(--background);">
                                <tr>
                                    <th style="width: 200px;">HỌC SINH</th>
                                    <th>CỘT ĐIỂM (HỆ SỐ)</th>
                                    <th>ĐIỂM SỐ</th>
                                    <th>NHẬN XÉT (TUỲ CHỌN)</th>
                                    <th style="width: 100px;">HÀNH ĐỘNG</th>
                                </tr>
                            </thead>
                            <tbody id="grades-body">
                                <tr><td colspan="5" style="text-align: center; padding: 2rem; color: var(--text-light);">Chưa chọn lớp</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;
    },

    afterRender: async () => {
        const selectClass = document.getElementById('select-class');
        const selectSubject = document.getElementById('select-subject');
        const selectSemester = document.getElementById('select-semester');
        
        // 1. Load initial metadata
        try {
            const [classes, subjects] = await Promise.all([
                api.get('/classes'),
                api.get('/subjects')
            ]);
            
            selectClass.innerHTML = '<option value="">-- Chọn Lớp --</option>' + 
                classes.map(c => `<option value="${c.id}">${c.name} - Sĩ số: ${c.studentCount}</option>`).join('');
            
            selectSubject.innerHTML = '<option value="">-- Chọn Môn --</option>' + 
                subjects.map(s => `<option value="${s.id}">${s.name}</option>`).join('');
            
            selectSubject.disabled = false;
        } catch (err) {
            showToast('Lỗi tải danh mục: ' + err.message, 'error');
        }

        // 2. Class Selection Change -> Load Students
        selectClass.addEventListener('change', async (e) => {
            const classId = e.target.value;
            if (!classId) {
                document.getElementById('grades-body').innerHTML = '<tr><td colspan="5" style="text-align: center; padding: 2rem; color: var(--text-light);">Chưa chọn lớp</td></tr>';
                selectSemester.disabled = true;
                return;
            }

            try {
                const members = await api.get(`/classes/${classId}/members`);
                const students = members.filter(m => m.memberRole === 'STUDENT');
                renderStudentRows(students);
                selectSemester.disabled = false;
            } catch (err) {
                showToast('Lỗi tải danh sách học sinh', 'error');
            }
        });

        // 3. Delegate Save Button Click
        document.getElementById('grades-body').addEventListener('click', async (e) => {
            const btn = e.target.closest('.btn-save-score');
            if (!btn) return;

            const studentId = btn.getAttribute('data-studentid');
            const rowInfo = btn.closest('tr');
            
            const classId = selectClass.value;
            const subjectId = selectSubject.value;
            const semester = selectSemester.value;
            
            if (!classId || !subjectId) {
                showToast('Vui lòng chọn Môn học và Lớp trước khi lưu điểm', 'warning');
                return;
            }

            const scoreType = rowInfo.querySelector('.input-score-type').value;
            const scoreValue = rowInfo.querySelector('.input-score-value').value;
            const comment = rowInfo.querySelector('.input-comment').value;

            if (!scoreValue || isNaN(scoreValue) || scoreValue < 0 || scoreValue > 10) {
                showToast('Điểm số phải từ 0 đến 10', 'error');
                return;
            }

            try {
                btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
                btn.disabled = true;

                await api.post('/scores', {
                    studentId: Number(studentId),
                    classId: Number(classId),
                    subjectId: Number(subjectId),
                    semester: semester,
                    scoreType: scoreType,
                    scoreValue: Number(scoreValue),
                    comment: comment
                });

                showToast('Lưu điểm thành công!', 'success');
                // Flash green background briefly to indicate success
                rowInfo.style.backgroundColor = 'rgba(67, 160, 71, 0.1)';
                setTimeout(() => rowInfo.style.backgroundColor = '', 1000);
                
                // Reset inputs for next entry
                rowInfo.querySelector('.input-score-value').value = '';
                rowInfo.querySelector('.input-comment').value = '';

            } catch (err) {
                showToast(err.message, 'error');
            } finally {
                btn.innerHTML = '<i class="fas fa-save"></i> Lưu';
                btn.disabled = false;
            }
        });
    }
};

function renderStudentRows(students) {
    const tbody = document.getElementById('grades-body');
    if (students.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; padding: 2rem; color: var(--text-light);">Lớp chưa có học sinh nào.</td></tr>';
        return;
    }

    const typeOptions = `
        <option value="REGULAR">Kiểm tra Thường xuyên (Hệ số 1)</option>
        <option value="MIDTERM">Kiểm tra Giữa kỳ (Hệ số 2)</option>
        <option value="FINAL">Kiểm tra Cuối kỳ (Hệ số 3)</option>
    `;

    tbody.innerHTML = students.map(s => {
        return `
            <tr style="transition: background-color 0.3s;">
                <td>
                    <div style="font-weight: 600; color: var(--text-dark);">${s.fullName}</div>
                    <div style="font-size: 0.75rem; color: var(--text-light);">MSHS: ${s.username}</div>
                </td>
                <td>
                    <select class="form-control input-score-type" style="padding: 0.5rem; display: inline-block; width: auto;">
                        ${typeOptions}
                    </select>
                </td>
                <td>
                    <input type="number" class="form-control input-score-value" style="padding: 0.5rem; width: 80px;" min="0" max="10" step="0.25" placeholder="8.5" />
                </td>
                <td>
                    <input type="text" class="form-control input-comment" style="padding: 0.5rem; width: 100%;" placeholder="Nhận xét..." />
                </td>
                <td>
                    <button class="btn btn-primary btn-save-score" data-studentid="${s.userId}" style="padding: 0.5rem 1rem;">
                        <i class="fas fa-save"></i> Lưu
                    </button>
                </td>
            </tr>
        `;
    }).join('');
}

export default GradesPage;
