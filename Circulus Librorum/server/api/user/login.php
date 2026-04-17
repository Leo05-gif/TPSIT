<?php

$root = $_SERVER['DOCUMENT_ROOT'];

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';

function login(): array {
    try {

        $data = get_content();

        if (!isset($data['username'], $data['password'])) {
            throw new Exception('Not enough input values');
        }

        $usr = trim($data['username']);
        $pwd = trim($data['password']);

        check_param($usr);
        check_param($pwd);

        $connection = connect();

        $query = 'SELECT * FROM users WHERE username=(?)';
        $params = [$usr];

        $result = execute($connection, $query, 's', $params);

        if (empty($result['data']) || count($result['data']) === 0) {
            throw new Exception('Failed to login');
        }

        if (!password_verify($pwd, $result['data'][0]['password'])) {
            throw new Exception('Failed to verify password. Please try again');
        }

        $token = create_user_token($connection, $result['data'][0]['id']);

        http_response_code(201);
        return [
            'success' => true,
            'message' => 'Successful login',
            'token' => $token,
        ];

    } catch (Exception $e) {
            throw new Exception('Failed to login user. Please try again later');
    }
}
?>