<?php

$root = $_SERVER['DOCUMENT_ROOT'];

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';

function get_turns(): array {
    try {
        $data = $_GET;

        if (!isset($data['token'], $data['session_id'])) {
            throw new Exception('Not enough input values');
        }

        $token      = trim($data['token']);
        $session_id = trim($data['session_id']);

        $connection = connect();
        validate_user_token($connection, $token);

        $query  = 'SELECT * FROM turns WHERE session_id=(?)';
        $params = [$session_id];
        $result = execute($connection, $query, 'i', $params);

        return [
            'success' => true,
            'data'    => $result['data'],
        ];

    } catch (Exception $e) {
        throw new Exception($e->getMessage());
    }
}
?>