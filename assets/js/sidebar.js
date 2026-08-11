/**
 * SMS 2 - Sidebar Toggle & Responsive Behavior
 * Desktop: collapse to icon rail (icons stay visible)
 * Mobile: drawer overlay
 */
document.addEventListener('DOMContentLoaded', function () {
    const sidebar = document.getElementById('smsSidebar');
    const overlay = document.getElementById('sidebarOverlay');
    const toggleBtn = document.getElementById('sidebarToggle');

    if (!sidebar) return;

    const DESKTOP_BREAKPOINT = 992;

    function isDesktop() {
        return window.innerWidth >= DESKTOP_BREAKPOINT;
    }

    function openMobileSidebar() {
        sidebar.classList.add('show');
        if (overlay) overlay.classList.add('show');
        document.body.classList.add('sidebar-open');
        document.body.style.overflow = 'hidden';
    }

    function closeMobileSidebar() {
        sidebar.classList.remove('show');
        if (overlay) overlay.classList.remove('show');
        document.body.classList.remove('sidebar-open');
        document.body.style.overflow = '';
    }

    function collapseOpenMenus() {
        sidebar.querySelectorAll('.collapse.show').forEach(function (el) {
            if (typeof bootstrap !== 'undefined' && bootstrap.Collapse) {
                const instance = bootstrap.Collapse.getOrCreateInstance(el, { toggle: false });
                instance.hide();
            } else {
                el.classList.remove('show');
            }
        });
        sidebar.querySelectorAll('.sidebar-parent[aria-expanded="true"]').forEach(function (link) {
            link.setAttribute('aria-expanded', 'false');
        });
    }

    function restoreActiveMenus() {
        sidebar.querySelectorAll('.sidebar-parent.active').forEach(function (link) {
            const target = link.getAttribute('href');
            if (!target || target.charAt(0) !== '#') return;
            const el = document.querySelector(target);
            if (!el) return;
            if (typeof bootstrap !== 'undefined' && bootstrap.Collapse) {
                bootstrap.Collapse.getOrCreateInstance(el, { toggle: false }).show();
            } else {
                el.classList.add('show');
            }
            link.setAttribute('aria-expanded', 'true');
        });
    }

    function setCollapsed(collapsed) {
        document.body.classList.toggle('sidebar-collapsed', collapsed);
        try {
            localStorage.setItem('sidebarCollapsed', collapsed ? 'true' : 'false');
        } catch (e) { /* ignore */ }

        if (collapsed) {
            collapseOpenMenus();
        } else {
            restoreActiveMenus();
        }

        if (toggleBtn) {
            toggleBtn.setAttribute('aria-expanded', collapsed ? 'false' : 'true');
            toggleBtn.setAttribute(
                'aria-label',
                collapsed ? 'Expand sidebar' : 'Collapse sidebar'
            );
            toggleBtn.setAttribute(
                'title',
                collapsed ? 'Expand sidebar' : 'Collapse sidebar'
            );
        }
    }

    function toggleDesktopSidebar() {
        setCollapsed(!document.body.classList.contains('sidebar-collapsed'));
    }

    function handleToggle() {
        if (isDesktop()) {
            closeMobileSidebar();
            toggleDesktopSidebar();
        } else {
            if (sidebar.classList.contains('show')) {
                closeMobileSidebar();
            } else {
                openMobileSidebar();
            }
        }
    }

    if (toggleBtn) {
        toggleBtn.addEventListener('click', handleToggle);
    }

    if (overlay) {
        overlay.addEventListener('click', closeMobileSidebar);
    }

    // Accordion: opening one module closes the others
    function closeOtherMenus(exceptEl) {
        sidebar.querySelectorAll('.collapse.show, .collapse.collapsing').forEach(function (el) {
            if (el === exceptEl) return;
            if (typeof bootstrap !== 'undefined' && bootstrap.Collapse) {
                const instance = bootstrap.Collapse.getOrCreateInstance(el, { toggle: false });
                instance.hide();
            } else {
                el.classList.remove('show');
            }
        });
        sidebar.querySelectorAll('.sidebar-parent[aria-expanded="true"]').forEach(function (link) {
            const target = link.getAttribute('href');
            if (exceptEl && target && target.charAt(0) === '#' && document.querySelector(target) === exceptEl) {
                return;
            }
            link.setAttribute('aria-expanded', 'false');
        });
    }

    sidebar.querySelectorAll('.collapse').forEach(function (el) {
        el.addEventListener('show.bs.collapse', function () {
            closeOtherMenus(el);
        });
    });

    // When collapsed, module icons navigate to overview instead of expanding
    sidebar.querySelectorAll('.sidebar-parent').forEach(function (link) {
        link.addEventListener('click', function (e) {
            if (!isDesktop() || !document.body.classList.contains('sidebar-collapsed')) {
                return;
            }
            e.preventDefault();
            e.stopPropagation();
            const url = link.getAttribute('data-overview-url');
            if (url) {
                window.location.href = url;
            }
        });
    });

    // Close drawer after navigation on mobile/tablet
    sidebar.querySelectorAll('.nav-link').forEach(function (link) {
        link.addEventListener('click', function () {
            if (!isDesktop()) {
                // Allow collapse parents to open submenu before closing drawer
                if (link.classList.contains('sidebar-parent')) {
                    return;
                }
                closeMobileSidebar();
            }
        });
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && !isDesktop() && sidebar.classList.contains('show')) {
            closeMobileSidebar();
        }
    });

    function applyLayoutForViewport() {
        if (isDesktop()) {
            closeMobileSidebar();
            let preferCollapsed = false;
            try {
                preferCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';
            } catch (e) { /* ignore */ }
            setCollapsed(preferCollapsed);
        } else {
            document.body.classList.remove('sidebar-collapsed');
            closeMobileSidebar();
            if (toggleBtn) {
                toggleBtn.setAttribute('aria-label', 'Open sidebar');
                toggleBtn.setAttribute('title', 'Open sidebar');
            }
        }
    }

    applyLayoutForViewport();

    function syncViewportUnit() {
        document.documentElement.style.setProperty('--vh', (window.innerHeight * 0.01) + 'px');
    }
    syncViewportUnit();

    let resizeTimer;
    let lastDesktop = isDesktop();
    window.addEventListener('resize', function () {
        syncViewportUnit();
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function () {
            const nowDesktop = isDesktop();
            if (nowDesktop !== lastDesktop) {
                applyLayoutForViewport();
                lastDesktop = nowDesktop;
            }
        }, 120);
    });

    window.addEventListener('orientationchange', function () {
        setTimeout(function () {
            syncViewportUnit();
            applyLayoutForViewport();
            lastDesktop = isDesktop();
        }, 200);
    });
});
