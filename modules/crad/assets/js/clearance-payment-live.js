(function () {
    var root = document.querySelector('[data-rcp-live]');
    if (!root) return;
    var role = root.getAttribute('data-rcp-role') || '';
    var endpoint = root.getAttribute('data-rcp-endpoint') || '';
    var csrf = root.getAttribute('data-rcp-csrf') || '';
    var statusEl = root.querySelector('[data-rcp-status]');
    var syncEl = root.querySelector('[data-rcp-sync]');
    var preview = root.querySelector('[data-rcp-preview]');
    var fileNameEl = root.querySelector('[data-rcp-file-name]');
    var uploadBtn = document.getElementById('rcpUploadBtn');
    var uploadLabel = root.querySelector('[data-rcp-upload-label]');
    var fileInput = document.getElementById('rcpFile');
    var orInput = document.getElementById('rcpOr');
    var listBody = root.querySelector('[data-rcp-list]');
    var detail = root.querySelector('[data-rcp-detail]');
    var adminOr = root.querySelector('[data-rcp-or]');
    var adminRemarks = root.querySelector('[data-rcp-remarks]');
    var approveBtn = root.querySelector('[data-rcp-approve]');
    var rejectBtn = root.querySelector('[data-rcp-reject]');
    var current = null;
    var uploading = false;

    function post(action, extra, file) {
        var fd = extra instanceof FormData ? extra : new FormData();
        if (!(extra instanceof FormData)) {
            Object.keys(extra || {}).forEach(function (key) { fd.append(key, extra[key]); });
        }
        fd.append('action', action);
        fd.append('csrf_token', csrf);
        if (file) fd.append('payment_file', file);
        return fetch(endpoint, { method: 'POST', credentials: 'same-origin', body: fd })
            .then(function (r) { return r.json(); });
    }

    function applyStudent(row) {
        current = row;
        if (statusEl) statusEl.textContent = row ? (row.status_label || row.status) : 'No college payment uploaded yet';
        if (fileNameEl) fileNameEl.textContent = row && row.uploaded_original ? row.uploaded_original : '';
        if (uploadLabel) uploadLabel.textContent = row && row.has_upload ? 'Re-upload' : 'Upload';
        if (uploadBtn) uploadBtn.disabled = !!(row && row.status === 'approved');
        if (orInput && row && row.or_number && !orInput.value) orInput.value = row.or_number;
        if (preview) {
            if (row && row.uploaded_url) {
                preview.hidden = false;
                preview.innerHTML = '<img class="rsc-upload-img" alt="College payment" src="' + row.uploaded_url + '">';
            } else {
                preview.hidden = true;
                preview.innerHTML = '';
            }
        }
    }

    function applyAdmin(row) {
        current = row;
        if (!detail) return;
        if (!row) {
            detail.hidden = true;
            return;
        }
        detail.hidden = false;
        if (statusEl) statusEl.textContent = row.status_label || row.status;
        if (adminOr) adminOr.value = row.or_number || '';
        if (adminRemarks) adminRemarks.value = row.remarks || 'HMA';
        if (preview) {
            preview.innerHTML = row.uploaded_url
                ? '<img class="rsc-upload-img" alt="College payment" src="' + row.uploaded_url + '">'
                : '';
        }
        if (approveBtn) approveBtn.disabled = row.status === 'approved';
        if (rejectBtn) rejectBtn.disabled = row.status === 'approved';
    }

    function renderList(rows) {
        if (!listBody) return;
        if (!rows || !rows.length) {
            listBody.innerHTML = '<tr><td colspan="5" class="text-muted">No college payment uploads yet.</td></tr>';
            return;
        }
        listBody.innerHTML = rows.map(function (row) {
            var active = current && String(current.id) === String(row.id) ? ' class="table-active"' : '';
            return '<tr' + active + ' data-rcp-open="' + row.id + '">'
                + '<td>' + (row.group_number || '') + '</td>'
                + '<td>' + (row.research_title || '') + '</td>'
                + '<td>' + (row.or_number || '') + '</td>'
                + '<td>' + (row.status_label || row.status) + '</td>'
                + '<td><button type="button" class="btn btn-sm btn-outline-primary" data-rcp-open="' + row.id + '">Open</button></td>'
                + '</tr>';
        }).join('');
    }

    function refresh() {
        if (uploading) return;
        fetch(endpoint, { credentials: 'same-origin', cache: 'no-store', headers: { Accept: 'application/json' } })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (!data || !data.ok) return;
                if (syncEl) syncEl.textContent = data.last_sync || '';
                if (role === 'student') {
                    applyStudent(data.payment);
                } else {
                    renderList(data.rows || []);
                    if (current && data.rows) {
                        var next = data.rows.filter(function (row) { return String(row.id) === String(current.id); })[0];
                        if (next) applyAdmin(next);
                    } else if (!current && data.rows && data.rows.length) {
                        applyAdmin(data.rows[0]);
                    }
                }
            })
            .catch(function () {});
    }

    if (uploadBtn && fileInput) {
        uploadBtn.addEventListener('click', function () {
            if (!fileInput.files || !fileInput.files[0]) {
                alert('Choose the college payment PNG or JPG first.');
                return;
            }
            uploading = true;
            uploadBtn.disabled = true;
            post('student_upload', { or_number: orInput ? orInput.value : '' }, fileInput.files[0])
                .then(function (data) {
                    if (data && data.ok && data.payment) applyStudent(data.payment);
                    else if (data && data.error) alert(data.error);
                })
                .finally(function () {
                    uploading = false;
                    fileInput.value = '';
                    refresh();
                });
        });
    }

    if (listBody) {
        listBody.addEventListener('click', function (ev) {
            var btn = ev.target.closest('[data-rcp-open]');
            if (!btn) return;
            var id = btn.getAttribute('data-rcp-open');
            fetch(endpoint, { credentials: 'same-origin', cache: 'no-store' })
                .then(function (r) { return r.json(); })
                .then(function (data) {
                    var row = ((data && data.rows) || []).filter(function (item) { return String(item.id) === String(id); })[0];
                    if (row) applyAdmin(row);
                });
        });
    }

    if (approveBtn) {
        approveBtn.addEventListener('click', function () {
            if (!current) return;
            approveBtn.disabled = true;
            post('admin_approve', {
                id: current.id,
                or_number: adminOr ? adminOr.value : '',
                remarks: adminRemarks ? adminRemarks.value : 'HMA'
            }).then(function (data) {
                if (data && data.ok && data.payment) applyAdmin(data.payment);
                else if (data && data.error) alert(data.error);
                refresh();
            }).finally(function () { approveBtn.disabled = false; });
        });
    }

    if (rejectBtn) {
        rejectBtn.addEventListener('click', function () {
            if (!current) return;
            rejectBtn.disabled = true;
            post('admin_reject', { id: current.id }).then(function (data) {
                if (data && data.ok && data.payment) applyAdmin(data.payment);
                else if (data && data.error) alert(data.error);
                refresh();
            }).finally(function () { rejectBtn.disabled = false; });
        });
    }

    refresh();
    window.setInterval(refresh, 2000);
})();
