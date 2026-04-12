<?php

require_once 'database.php';

function create_token(&$connection, &$id): string {
    try {
        $query = 'DELETE FROM users_tokens WHERE id=(?)';
        $params = [$id];

        execute($connection, $query, 'i', $params);

        $token = generate_token();

        $query = 'INSERT INTO users_tokens (id, token, expires_at) VALUES (?, ?, NOW() + INTERVAL 30 DAY)';
        $params = [$id, $token];

        execute($connection, $query, 'is', $params);
            
        return $token;

    } catch (Exception $e) {
        error_log('Token creation failed for user ' . $id . ': ' . $e->getMessage());
        throw new Exception('Failed to create authentication token. Please try again later.');
    }
}

function validate_token(&$connection, string &$token): void {
    try {
        $query = 'SELECT expires_at FROM users_tokens WHERE token=(?)';
        $params = [$token];

        $result = execute($connection, $query, 's', $params);

        if (empty($result['data']) || count($result['data']) === 0) {
            error_log('Invalid token attempt: ' . $token);
            throw new Exception('Invalid token');
        }

        $tokenData = $result['data'][0];

        $format = 'Y-m-d H:i:s';
        $current_date = \DateTime::createFromFormat($format, time());
        $expires_at_date = \DateTime::createFromFormat($format, $tokenData['expires_at']);

        if ($current_date > $expires_at_date) {
            error_log('Expired token: ' . $token);
            throw new Exception('Expired token');
        }
    } catch (Exception $e) {
        error_log('Token validation failed for token ' . $token . ': ' . $e->getMessage());
        throw new Exception('Failed to valida authentication token. Please try again later.');
    }
}

function generate_token(): string {
    return bin2hex(random_bytes(64));
}
?>