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
        $query = 'SELECT id FROM user_tokens WHERE token=(?)';
        $params = [$token];

        $token_result = execute($connection, $query, 's', $params);

        if ($token_result['count'] <= 0) {
            error_log('User session doesnt exist');
            throw new Exception('Failed to find token');
        }

        $query = 'SELECT * FROM users WHERE id=(?)';
        $params = [$token_result['data'][0]['id']];

        $pwd_result = execute($connection, $query, 'i', $params);

        if ($pwd_result['count'] <= 0) {
            error_log('User not found');
            throw new Exception('Failed to find user');
        }

        if (!password_verify($pwd, $pwd_result['data'][0]['password'])) {
            error_log('invalid password');
            throw new Exception('Failed to validated password');
        }

        validate_token($connection, $token);

        $query = 'DELETE FROM users WHERE id=(?)';
        $params = [$pwd_result['data'][0]['id']];

        execute($connectio,$query, 'i', $params);

        http_response_code(200);
        return [
            'success' => true,
            'message' => 'User has been deleted',
        ];

    } catch (Exception $e) {
        error_log('Deleting failed for ' . $token . ': ' . $e->getMessage());
        throw new Exception('Failed to delete user. Please try again later');
    }
}
?>