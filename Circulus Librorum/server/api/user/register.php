<?php

$root = $_SERVER['DOCUMENT_ROOT'];

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';

function register(): array {
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

        $query = 'SELECT username from users WHERE username=(?)';
        $params = [$usr];

        $result = execute($connection, $query, 's', $params);

        if (!empty($result['data']) && count($result['data']) > 0) {
            throw new Exception('Failed to register');
        }

        $pwd_hash = password_hash($pwd, PASSWORD_BCRYPT);

        if ($pwd_hash == false) {
            throw new Exception('Password hashing failed');
        }

        $query = 'INSERT INTO users(username, password, created_at) VALUES(?, ?, NOW())';
        $params = [$usr, $pwd_hash];

        $result = execute($connection, $query, 'ss', $params);

        http_response_code(201);
        return [
            'success' => true,
            'message' => 'Successful registration',
        ];

    } catch (Exception $e) {
        throw new Exception('Failed to registrate user. Please try again later');
    }
}
?>