<?php

$root = $_SERVER['DOCUMENT_ROOT'];

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';

function get_sessions(): array {
    try {
        $data = $_GET;

        if (!isset($data['token'], $data['club_id'])) {
            throw new Exception('Not enough input values');
        }

        $token = trim($data['token']);
        $club_id = trim($data['club_id']);

        $connection = connect();
        validate_user_token($connection, $token);

        $query = 'SELECT * FROM sessions WHERE club_id=(?)';
        $params = [$club_id];
        $result = execute($connection, $query, 'i', $params);

        if ($result['count'] <= 0) {
            throw new Exception('Couldnt find sessions');
        }

        return [
            'success' => true,
            'data' => $result['data'],
        ];

    } catch (Exception $e) {
        throw new Exception($e->getMessage());
    }
}
?>