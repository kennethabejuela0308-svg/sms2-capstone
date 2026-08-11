<?php
/**
 * SMS 2 - Scripts
 */
?>
<!-- Bootstrap JS (local) -->
<script src="<?= BASE_URL ?>/assets/vendor/bootstrap/bootstrap.bundle.min.js"></script>
<!-- SMS 2 App -->
<?php if (empty($omitThemeJs)): ?>
<script src="<?= BASE_URL ?>/assets/js/theme.js"></script>
<?php endif; ?>
<?php if (empty($omitAppChromeJs)): ?>
<script src="<?= BASE_URL ?>/assets/js/ph-clock.js"></script>
<script src="<?= BASE_URL ?>/assets/js/sidebar.js"></script>
<script src="<?= BASE_URL ?>/assets/js/app.js"></script>
<script src="<?= BASE_URL ?>/assets/js/sms-security-ui.js?v=5"></script>
<!-- Global Search -->
<script src="<?= BASE_URL ?>/assets/js/search.js"></script>
<?php endif; ?>
</body>
</html>
