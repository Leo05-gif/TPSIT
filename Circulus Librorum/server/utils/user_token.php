<?php

require_once 'database.php';

function create_user_token(&$connection, &$id): string {
    try {
        $query = 'DELETE FROM user_tokens WHERE id=(?)';
        $params = [$id];

        execute($connection, $query, 'i', $params);

        $token = generate_user_token();

        $query = 'INSERT INTO user_tokens (id, token, expires_at) VALUES (?, ?, NOW() + INTERVAL 30 DAY)';
        $params = [$id, $token];

        execute($connection, $query, 'is', $params);
            
        return $token;

    } catch (Exception $e) {
        throw new Exception('Failed to create authentication token. Please try again later.');
    }
}

function validate_user_token(&$connection, string &$token): int {
    try {
        $query = 'SELECT * FROM user_tokens WHERE token=(?)';
        $params = [$token];

        $result = execute($connection, $query, 's', $params);

        if ($result['count'] <= 0) {
            throw new Exception('Invalid token');
        }

        $token_data = $result['data'][0];

        $format = 'Y-m-d H:i:s';
        $current_date = \DateTime::createFromFormat($format, time());
        $expires_at_date = \DateTime::createFromFormat($format, $token_data['expires_at']);

        if ($current_date > $expires_at_date) {
            throw new Exception('Expired token');
        }
        return $token_data['id'];
    } catch (Exception $e) {
        throw new Exception('Failed to validate authentication token. Please try again later.' . $e->getMessage());
    }
}

function generate_user_token(): string {
    return bin2hex(random_bytes(64));
}
?>