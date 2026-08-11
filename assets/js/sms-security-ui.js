/**
 * SMS 2 – Security UI behaviors
 * - Show/hide password (eye) via one global click handler
 * - Segmented OTP boxes sync to hidden field
 * - Confirm modals + CSV export helpers
 */
(function () {
    'use strict';

    function eyeIcon(show) {
        return show
            ? '<i class="fas fa-eye-slash" aria-hidden="true"></i>'
            : '<i class="fas fa-eye" aria-hidden="true"></i>';
    }

    function findPasswordInput(btn) {
        var targetId = btn.getAttribute('data-pw-target');
        if (targetId) {
            var byId = document.getElementById(targetId);
            if (byId) return byId;
        }
        var group = btn.closest('.sms-pw-group, .password-group, .input-group');
        if (group) {
            return group.querySelector('input[type="password"], input[type="text"].sms-pw-input, input.sms-pw-input, input.form-control');
        }
        return null;
    }

    function togglePasswordVisibility(btn) {
        var input = findPasswordInput(btn);
        if (!input) return;
        var show = input.type === 'password';
        input.type = show ? 'text' : 'password';
        input.classList.add('sms-pw-input');
        btn.innerHTML = eyeIcon(show);
        btn.setAttribute('aria-label', show ? 'Hide password' : 'Show password');
        btn.setAttribute('title', show ? 'Hide password' : 'Show password');
        btn.setAttribute('aria-pressed', show ? 'true' : 'false');
        try { input.focus({ preventScroll: true }); } catch (e) { input.focus(); }
    }

    // One delegated handler — avoids double-bind bugs (login + global both attaching)
    document.addEventListener('click', function (ev) {
        var btn = ev.target && ev.target.closest
            ? ev.target.closest('.password-toggle, .sms-pw-toggle')
            : null;
        if (!btn) return;
        ev.preventDefault();
        ev.stopPropagation();
        togglePasswordVisibility(btn);
    });

    function ensurePasswordToggle(input) {
        if (!input || input.dataset.smsPwSkip === '1') return;
        if (input.type !== 'password' && !(input.classList.contains('sms-pw-input') && input.type === 'text')) {
            if (input.type !== 'password') return;
        }
        if (input.type !== 'password') return;
        if (input.closest('.sms-otp')) return;

        var group = input.closest('.sms-pw-group, .password-group');
        if (!group) {
            group = document.createElement('div');
            group.className = 'sms-pw-group password-group';
            if (input.parentNode) {
                input.parentNode.insertBefore(group, input);
                group.appendChild(input);
            }
            input.classList.add('sms-pw-input');
        }

        var btn = group.querySelector('.password-toggle, .sms-pw-toggle');
        if (!btn) {
            btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'password-toggle sms-pw-toggle';
            btn.setAttribute('aria-label', 'Show password');
            btn.setAttribute('title', 'Show password');
            btn.setAttribute('aria-pressed', 'false');
            if (input.id) btn.setAttribute('data-pw-target', input.id);
            btn.innerHTML = eyeIcon(false);
            group.appendChild(btn);
        } else {
            btn.type = 'button';
            if (input.id && !btn.getAttribute('data-pw-target')) {
                btn.setAttribute('data-pw-target', input.id);
            }
            if (!btn.innerHTML.trim()) btn.innerHTML = eyeIcon(false);
        }
    }

    function enhancePasswords(root) {
        (root || document).querySelectorAll('input[type="password"]').forEach(ensurePasswordToggle);
    }

    function syncOtp(wrap) {
        var boxes = wrap.querySelectorAll('.sms-otp-box');
        var hidden = wrap.querySelector('.sms-otp-value');
        if (!hidden) return;
        var value = '';
        boxes.forEach(function (box) {
            var d = (box.value || '').replace(/\D/g, '').slice(0, 1);
            box.value = d;
            box.classList.toggle('is-filled', d !== '');
            value += d;
        });
        hidden.value = value;
    }

    function focusBox(boxes, index) {
        if (index < 0 || index >= boxes.length) return;
        boxes[index].focus();
        try { boxes[index].select(); } catch (e) { /* ignore */ }
    }

    function wireOtp(wrap) {
        if (!wrap || wrap.dataset.smsOtpBound === '1') return;
        wrap.dataset.smsOtpBound = '1';

        var boxes = Array.prototype.slice.call(wrap.querySelectorAll('.sms-otp-box'));
        var hidden = wrap.querySelector('.sms-otp-value');
        if (!boxes.length || !hidden) return;
        var form = wrap.closest('form');

        boxes.forEach(function (box, index) {
            box.addEventListener('input', function () {
                var raw = (box.value || '').replace(/\D/g, '');
                if (raw.length > 1) {
                    // Paste into one box — distribute
                    for (var i = 0; i < raw.length && (index + i) < boxes.length; i++) {
                        boxes[index + i].value = raw.charAt(i);
                    }
                    syncOtp(wrap);
                    focusBox(boxes, Math.min(index + raw.length, boxes.length - 1));
                    return;
                }
                box.value = raw.slice(0, 1);
                syncOtp(wrap);
                if (raw && index < boxes.length - 1) focusBox(boxes, index + 1);
            });

            box.addEventListener('keydown', function (ev) {
                if (ev.key === 'Backspace' && !box.value && index > 0) {
                    focusBox(boxes, index - 1);
                    boxes[index - 1].value = '';
                    syncOtp(wrap);
                    ev.preventDefault();
                } else if (ev.key === 'ArrowLeft' && index > 0) {
                    focusBox(boxes, index - 1);
                    ev.preventDefault();
                } else if (ev.key === 'ArrowRight' && index < boxes.length - 1) {
                    focusBox(boxes, index + 1);
                    ev.preventDefault();
                }
            });

            box.addEventListener('paste', function (ev) {
                var text = (ev.clipboardData || window.clipboardData).getData('text') || '';
                var digits = text.replace(/\D/g, '');
                if (!digits) return;
                ev.preventDefault();
                for (var i = 0; i < boxes.length; i++) {
                    boxes[i].value = digits.charAt(i) || '';
                }
                syncOtp(wrap);
                focusBox(boxes, Math.min(digits.length, boxes.length - 1));
            });

            box.addEventListener('focus', function () {
                try { box.select(); } catch (e) { /* ignore */ }
            });
        });

        if (form && form.dataset.smsOtpForm !== '1') {
            form.dataset.smsOtpForm = '1';
            form.addEventListener('submit', function (ev) {
                var wraps = form.querySelectorAll('[data-sms-otp]');
                var blocked = false;
                wraps.forEach(function (w) {
                    syncOtp(w);
                    var boxes = w.querySelectorAll('.sms-otp-box');
                    var hidden = w.querySelector('.sms-otp-value');
                    var need = parseInt(w.getAttribute('data-digits') || String(boxes.length), 10) || boxes.length;
                    var must = !!w.querySelector('.sms-otp-box[required]');
                    if (must && hidden && (hidden.value || '').length < need) {
                        boxes.forEach(function (b) { b.classList.add('is-invalid'); });
                        if (!blocked && boxes[0]) boxes[0].focus();
                        blocked = true;
                    } else {
                        boxes.forEach(function (b) { b.classList.remove('is-invalid'); });
                    }
                });
                if (blocked) ev.preventDefault();
            });
        }

        syncOtp(wrap);
    }

    function enhanceOtps(root) {
        (root || document).querySelectorAll('[data-sms-otp]').forEach(wireOtp);
    }

    function enhanceAll(root) {
        enhancePasswords(root);
        enhanceOtps(root);
        wireConfirmHooks(root);
        wireExportButtons(root);
    }

    function ensureConfirmModal() {
        if (document.getElementById('smsConfirmModal')) return;
        var wrap = document.createElement('div');
        wrap.innerHTML =
            '<div class="modal fade" id="smsConfirmModal" tabindex="-1" aria-hidden="true">' +
            '<div class="modal-dialog modal-dialog-centered">' +
            '<div class="modal-content sms-confirm-modal">' +
            '<div class="modal-header border-0 pb-0">' +
            '<h5 class="modal-title" id="smsConfirmTitle">Are you sure?</h5>' +
            '<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>' +
            '</div>' +
            '<div class="modal-body pt-2">' +
            '<div class="sms-confirm-icon text-warning mb-2"><i class="fas fa-exclamation-triangle fa-2x"></i></div>' +
            '<p class="mb-0" id="smsConfirmMsg">Please confirm this action.</p>' +
            '</div>' +
            '<div class="modal-footer border-0">' +
            '<button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>' +
            '<button type="button" class="btn btn-danger" id="smsConfirmOk">Yes, continue</button>' +
            '</div></div></div></div>';
        document.body.appendChild(wrap.firstChild);
    }

    function smsConfirm(message, onOk, opts) {
        opts = opts || {};
        ensureConfirmModal();
        var modalEl = document.getElementById('smsConfirmModal');
        var titleEl = document.getElementById('smsConfirmTitle');
        var msgEl = document.getElementById('smsConfirmMsg');
        var okBtn = document.getElementById('smsConfirmOk');
        if (titleEl) titleEl.textContent = opts.title || 'Are you sure?';
        if (msgEl) msgEl.textContent = message || 'Please confirm this action.';
        if (okBtn) {
            okBtn.className = 'btn ' + (opts.okClass || 'btn-danger');
            okBtn.textContent = opts.okText || 'Yes, continue';
            var next = okBtn.cloneNode(true);
            okBtn.parentNode.replaceChild(next, okBtn);
            okBtn = next;
        }
        var modal = bootstrap.Modal.getOrCreateInstance(modalEl);
        okBtn.addEventListener('click', function () {
            modal.hide();
            if (typeof onOk === 'function') onOk();
        }, { once: true });
        modal.show();
    }

    function wireConfirmHooks(root) {
        (root || document).querySelectorAll('[data-sms-confirm]').forEach(function (el) {
            if (el.dataset.smsConfirmBound === '1') return;
            el.dataset.smsConfirmBound = '1';
            el.addEventListener('click', function (ev) {
                if (el.dataset.smsConfirmSkip === '1') {
                    el.dataset.smsConfirmSkip = '0';
                    return;
                }
                ev.preventDefault();
                ev.stopPropagation();
                var msg = el.getAttribute('data-sms-confirm') || 'Are you sure you want to continue?';
                var title = el.getAttribute('data-sms-confirm-title') || 'Are you sure?';
                var okText = el.getAttribute('data-sms-confirm-ok') || 'Yes, continue';
                smsConfirm(msg, function () {
                    if (el.tagName === 'BUTTON' && el.type === 'submit' && el.form) {
                        el.dataset.smsConfirmSkip = '1';
                        if (typeof el.form.requestSubmit === 'function') el.form.requestSubmit(el);
                        else el.form.submit();
                        return;
                    }
                    if (el.tagName === 'A' && el.href) {
                        window.location.href = el.href;
                        return;
                    }
                    var form = el.closest('form');
                    if (form) form.submit();
                }, { title: title, okText: okText });
            });
        });

        (root || document).querySelectorAll('form[data-sms-confirm-submit]').forEach(function (form) {
            if (form.dataset.smsConfirmFormBound === '1') return;
            form.dataset.smsConfirmFormBound = '1';
            form.addEventListener('submit', function (ev) {
                if (form.dataset.smsConfirmSkip === '1') {
                    form.dataset.smsConfirmSkip = '0';
                    return;
                }
                ev.preventDefault();
                var msg = form.getAttribute('data-sms-confirm-submit') || 'Are you sure you want to continue?';
                var title = form.getAttribute('data-sms-confirm-title') || 'Are you sure?';
                var okText = form.getAttribute('data-sms-confirm-ok') || 'Yes, continue';
                smsConfirm(msg, function () {
                    form.dataset.smsConfirmSkip = '1';
                    form.submit();
                }, { title: title, okText: okText });
            });
        });
    }

    function csvEscape(val) {
        var s = String(val == null ? '' : val).replace(/\r?\n/g, ' ').trim();
        if (/[",]/.test(s)) return '"' + s.replace(/"/g, '""') + '"';
        return s;
    }

    function exportTableCsv(opts) {
        opts = opts || {};
        var table = typeof opts.table === 'string' ? document.querySelector(opts.table) : opts.table;
        if (!table) return false;
        var rowSel = opts.rowSelector || 'tbody tr';
        var rows = Array.prototype.slice.call(table.querySelectorAll(rowSel));
        var headers = Array.prototype.map.call(table.querySelectorAll('thead th'), function (th) {
            return th.textContent.replace(/\s+/g, ' ').trim();
        }).filter(Boolean);
        var lines = [];
        if (headers.length) lines.push(headers.map(csvEscape).join(','));
        var exported = 0;
        rows.forEach(function (tr) {
            if (tr.hidden) return;
            if (tr.classList.contains('sec-log-empty-filter') || tr.classList.contains('mod-log-empty-filter')) return;
            if (tr.classList.contains('sec-log-empty-static')) return;
            if (tr.querySelector('td[colspan]')) return;
            var cells = Array.prototype.map.call(tr.querySelectorAll('td'), function (td) {
                return td.innerText.replace(/\s+/g, ' ').trim();
            });
            if (!cells.length) return;
            lines.push(cells.map(csvEscape).join(','));
            exported += 1;
        });
        if (!exported) {
            window.alert('No rows to export with the current filters.');
            return false;
        }
        var blob = new Blob([lines.join('\r\n')], { type: 'text/csv;charset=utf-8;' });
        var url = URL.createObjectURL(blob);
        var a = document.createElement('a');
        a.href = url;
        a.download = opts.filename || ('audit-export-' + new Date().toISOString().slice(0, 10) + '.csv');
        document.body.appendChild(a);
        a.click();
        a.remove();
        URL.revokeObjectURL(url);
        return true;
    }

    function wireExportButtons(root) {
        (root || document).querySelectorAll('[data-sms-export-csv]').forEach(function (btn) {
            if (btn.dataset.smsExportBound === '1') return;
            btn.dataset.smsExportBound = '1';
            btn.addEventListener('click', function () {
                exportTableCsv({
                    table: btn.getAttribute('data-sms-export-csv'),
                    rowSelector: btn.getAttribute('data-sms-export-rows') || 'tbody tr',
                    filename: btn.getAttribute('data-sms-export-filename') || 'audit-export.csv'
                });
            });
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function () { enhanceAll(document); });
    } else {
        enhanceAll(document);
    }

    window.smsConfirm = smsConfirm;
    window.smsSecurityUi = {
        enhance: enhanceAll,
        enhancePasswords: enhancePasswords,
        enhanceOtps: enhanceOtps,
        exportTableCsv: exportTableCsv,
        confirm: smsConfirm
    };
})();
