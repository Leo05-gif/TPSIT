<?php
define('ROOT', __DIR__ . '/../');
require_once ROOT . 'api/user/login.php';
require_once ROOT . 'api/user/register.php';
require_once ROOT . 'api/user/delete_user.php';

require_once ROOT . 'api/club/create_club.php';
require_once ROOT . 'api/club/delete_club.php';
require_once ROOT . 'api/club/create_invite.php';
require_once ROOT . 'api/club/join_club.php';
require_once ROOT . 'api/club/get_memberships.php';

require_once ROOT . 'api/session/create_session.php';
require_once ROOT . 'api/session/delete_session.php';
require_once ROOT . 'api/session/get_sessions.php';
require_once ROOT . 'api/session/complete_session.php';
?>