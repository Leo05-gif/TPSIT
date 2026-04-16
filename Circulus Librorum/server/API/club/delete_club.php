<?php

$root = $_SERVER['DOCUMENT_ROOT'];

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';

function delete_club() {
    try {
        $data = $data = get_content();

        if (!isset($data['token'], $data['club_id'])) {
            error_log(message: 'DELETE_CLUB: invalid input');
            throw new Exception('Not enough input values');
        }

        $usr_token = trim($data['token']);
        $club_id = trim($data['club_id']);

        $connection = connect();
        validate_token($connection, $usr_token);

        $query = 'SELECT id FROM user_tokens WHERE token=(?)';
        $params = [$usr_token];
        $usr_result = execute($connection, $query, 's', $params);
        
        if ($usr_result['count'] <= 0) {
            error_log('DELETE_CLUB: user not found');
            throw new Exception('User not found');
        }

        $usr_id = $usr_result['data'][0]['id'];

        $query = 'DELETE FROM clubs WHERE owner_id=(?) AND id=(?)';
        $params = [$usr_id, $club_id];
        $deletion_result = execute($connection, $query, 'ii', $params);

        if ($deletion_result['affected_rows'] <= 0) {
            error_log('DELETE_CLUB: couldnt delete club');
            throw new Exception('Couldnt delete club');
        }

        return [
            'success' => true,
            'message' => 'Successful club deletion',
        ];

    } catch (Exception $e) {
        error_log('DELETE_CLUB: cannot delete club');
        throw new Exception('Cannot delete club: ' . $e);
    }
}
?>