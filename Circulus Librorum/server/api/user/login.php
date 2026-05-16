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

        $user = $result['data'][0];

        if (!password_verify($pwd, $user['password'])) {
            throw new Exception('Failed to verify password');
        }

        $token = create_user_token($connection, $user['id']);

        $token_query = 'SELECT expires_at FROM user_tokens WHERE id=(?)';
        $token_result = execute($connection, $token_query, 'i', [$user['id']]);
        $expires_at = $token_result['data'][0]['expires_at'];

        return [
            'success'    => true,
            'message'    => 'Successful login',
            'token'      => $token,
            'expires_at' => $expires_at,
            'user'       => [
                'id'         => $user['id'],
                'username'   => $user['username'],
                'password'   => $user['password'],
                'created_at' => $user['created_at'],
            ],
        ];

    } catch (Exception $e) {
        throw new Exception($e->getMessage());
    }
}
?>