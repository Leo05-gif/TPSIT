<?php

include_once('database.php');

function generate_token(): string {
    return bin2hex(random_bytes(64));
}

function create_token(&$connection, &$id): string {
    $query = 'DELETE FROM users_tokens WHERE id=(?)';
    $params = [$id];
    if (!$stmt = execute($connection, $query, 's', $params)) {
        return false;
    }
    $stmt->close();

    $token = generate_token();

    $query = 'INSERT INTO users_tokens (id, token, expires_at) VALUES (?, ?, NOW() + INTERVAL 30 DAY)';
    $params = [$id, $token];
    if (!$stmt = execute($connection, $query, 'ss', $params)) {
        return false;
    }
    $stmt->close();

    return $token;
}

function validate_token(&$connection, &$token): bool {
    $query = 'SELECT expires_at FROM users_tokens WHERE token=(?)';
    $params = [$token];
    if (!$stmt = execute($connection, $query, 's', $params)) {
        return false;
    }
    
    if (!$result = fetch_data($stmt)) {
        return false;
    }

    if (!$row = $result->fetch_assoc()) {
        return false;
    }

    $format = 'Y-m-d H:i:s';
    $current_date = \DateTime::createFromFormat($format, time());
    $expires_at_date = \DateTime::createFromFormat($format, $row['expires_at']);

    if ($current_date > $expires_at_date) {
        return false;
    }
    
    return true;
}
?>