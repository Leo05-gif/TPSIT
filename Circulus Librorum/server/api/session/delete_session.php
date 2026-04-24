<?php

$root = $_SERVER['DOCUMENT_ROOT'];

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';

function delete_session() {
    try {
        $data = get_content();

        if (!isset($data['token'], $data['club_id'], $data['session_id'])) {
            throw new Exception('Not enough input values');
        }

        $token = trim($data['token']);
        $club_id = trim($data['club_id']);
        $session_id = trim($data['session_id']);

        $connection = connect();
        $usr_id = validate_user_token($connection, $token);

        $query = 'SELECT * FROM clubs WHERE owner_id=(?) AND id=(?)';
        $params = [$usr_id, $club_id];
        $result = execute($connection, $query, 'ii', $params);

        if ($result['count'] <= 0) {
            throw new Exception('Session doesnt exist');
        }

        $query = 'DELETE FROM sessions WHERE id=(?)';
        $params = [$session_id];
        $deletion_result = execute($connection, $query, 'i', $params);


        if ($deletion_result['affected_rows'] <= 0) {
            throw new Exception('Couldnt delete session');
        }

        return [
            'success' => true,
            'message' => 'Successful session deletion',
        ];


    } catch (Exception $e) {
        throw new Exception($e);
    }
}
?>