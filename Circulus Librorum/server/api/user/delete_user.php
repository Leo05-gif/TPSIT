<?php

$root = $_SERVER['DOCUMENT_ROOT'];

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';

function delete_user(): array {
    try {

        $data = get_content();

        if (!isset($data['token'], $data['password'])) {
            throw new Exception('Not enough input values');
        }

        $token = trim($data['token']);
        $pwd = trim($data['password']);

        check_param($token);
        check_param($pwd);

        $connection = connect();
        $user_id = validate_user_token($connection, $token);

        $query = 'SELECT * FROM users WHERE id=(?)';
        $params = [$user_id];
        $pwd_result = execute($connection, $query, 'i', $params);

        if ($pwd_result['count'] <= 0) {
            throw new Exception('Failed to find user');
        }

        $hash_pwd = $pwd_result['data'][0]['password'];

        if (!password_verify($pwd, $hash_pwd)) {
            throw new Exception('Failed to validated password');
        }

        $query = 'DELETE FROM users WHERE id=(?)';
        $params = [$user_id];
        execute($connectio,$query, 'i', $params);

        http_response_code(200);
        return [
            'success' => true,
            'message' => 'User has been deleted',
        ];

    } catch (Exception $e) {
        throw new Exception('Failed to delete user. Please try again later');
    }
}
?>