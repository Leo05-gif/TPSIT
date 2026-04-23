<?php
$root = $_SERVER['DOCUMENT_ROOT'];

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';
require_once $root . '/utils/club_token.php';

function join_club() {
    try {
        $data = get_content();

        if (!isset($data['token'], $data['invite'])) {
            throw new Exception('Not enough input values');
        }

        $token = trim($data['token']);
        $invite = trim($data['invite']);

        $connection = connect();
        $usr_id = validate_user_token($connection, $token);
        $club_id = validate_club_invite($connection, $invite);

        $query = 'SELECT * FROM club_memberships WHERE user_id=(?) AND club_id=(?)';
        $params = [$usr_id, $club_id];
        $result = execute($connection, $query, 'ii', $params);

        if ($result['count'] > 0) {
            throw new Exception($usr_id . ' is already inside this club: ' . $club_id);
        }

        $query = 'INSERT INTO club_memberships (user_id, club_id, joined_in) VALUES (?, ?, NOW())';
        $params = [$usr_id, $club_id];
        execute($connection, $query, 'ii', $params);

        $query = 'DELETE FROM club_invites WHERE token=(?)';
        $params = [$invite];
        execute($connection, $query, 's', $params);

        return [
            'success' => true,
            'message' => 'club joined successfully',
        ];

    } catch (Exception $e) {
        throw new Exception($e);
    }
}
?>