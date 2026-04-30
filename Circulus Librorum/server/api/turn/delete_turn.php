<?php

$root = $_SERVER['DOCUMENT_ROOT'];

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';

function delete_turn(): array {
    try {
        $data = get_content();

        if (!isset($data['token'], $data['club_id'], $data['turn_id'])) {
            throw new Exception('Not enough input values');
        }

        $token = trim($data['token']);
        $club_id = trim($data['club_id']);
        $turn_id = trim($data['turn_id']);

        $connection = connect();
        $usr_id = validate_user_token($connection, $token);

        $query = 'SELECT * FROM clubs WHERE owner_id=(?) AND id=(?)';
        $params = [$usr_id, $club_id];
        $result = execute($connection, $query, 'ii', $params);

        if ($result['count'] <= 0) {
            throw new Exception('Invalid operation');
        }

        $query = 'DELETE FROM turns WHERE id=(?)';
        $params = [$turn_id];
        $deletion_result = execute($connection, $query, 'i', $params);


        if ($deletion_result['affected_rows'] <= 0) {
            throw new Exception('Couldnt delete turn');
        }

        return [
            'success' => true,
            'message' => 'Successful turn deletion',
        ];
    } catch (Exception $e) {
        throw new Exception($e);
    }
}
?>