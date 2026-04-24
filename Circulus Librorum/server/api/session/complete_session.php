<?php

$root = $_SERVER['DOCUMENT_ROOT'];

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';

function complete_session() {
    try {
        $data = get_content();

        if (!isset($data["token"], $data['club_id'], $data['session_id'], $data['value'])) {
            throw new Exception('Not enough input values');
        }

        $token = trim($data['token']);
        $club_id = trim($data['club_id']);
        $session_id = trim($data['session_id']);
        $value = trim($data['value']);

        $connection = connect();
        $usr_id = validate_user_token($connection, $token);
        
        $query = 'SELECT * FROM clubs WHERE id=(?) AND owner_id=(?)';
        $params = [$club_id, $usr_id];
        $result = execute($connection, $query, 'ii', $params);

        if ($result['count'] <= 0) {
            throw new Exception('Invalid operation');
        }

        $query = 'UPDATE sessions SET completed=(?) WHERE club_id=(?) AND id=(?)';
        $params = [$value, $club_id, $session_id];
        execute($connection, $query, 'iii', $params);
    } catch (Exception $e) {
        throw new Exception($e);
    }
}
?>