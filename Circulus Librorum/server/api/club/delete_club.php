<?php

$root = $_SERVER['DOCUMENT_ROOT'];

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';

function delete_club() {
    try {
        $data = get_content();

        if (!isset($data['token'], $data['club_id'])) {
            throw new Exception('Not enough input values');
        }

        $usr_token = trim($data['token']);
        $club_id = trim($data['club_id']);

        $connection = connect();
        $usr_id = validate_user_token($connection, $usr_token);

        $query = 'DELETE FROM clubs WHERE owner_id=(?) AND id=(?)';
        $params = [$usr_id, $club_id];
        $deletion_result = execute($connection, $query, 'ii', $params);

        if ($deletion_result['affected_rows'] <= 0) {
            throw new Exception('Couldnt delete club');
        }

        return [
            'success' => true,
            'message' => 'Successful club deletion',
        ];

    } catch (Exception $e) {
        throw new Exception('Cannot delete club: ' . $e);
    }
}
?>