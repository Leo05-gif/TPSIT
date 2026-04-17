<?php
$root = $_SERVER['DOCUMENT_ROOT'];

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';
require_once $root . '/utils/club_token.php';

# TODO() SE APPARTENENTE, RITORNA ERRORE
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

        $query = 'INSERT INTO club_memberships (user_id, club_id, joined_in) VALUES (?, ?, NOW())';
        $params = [$usr_id, $club_id];
        execute($connection, $query, 'ii', $params);
    } catch (Exception $e) {
        throw new Exception('Cannot join club: ' + $e->getMessage());
    }
}
?>