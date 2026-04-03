<?php

include_once __DIR__ . '/../../utils/token.php';
include_once __DIR__ . '/../../utils/database.php';
include_once __DIR__ . '/../../utils/handler.php';

if($_SERVER["REQUEST_METHOD"] == "POST") {
    $data = get_content();

    if (!isset($data['token'], $data['password'])) {
        die(http_response_code(400));
    }

    $token = trim($data['token']);
    $pwd = trim($data['password']);

    if (!check_param($token) && !check_param($pwd)) {
        die(http_response_code(400));
    }

    $connection = connect();

    if (!validate_token($connection, $token)) {
        die(http_response_code(400));
    }

    $query = 'SELECT id FROM users_tokens WHERE token=(?)';
    $params = [$token];
    if (!$stmt = execute($connection, $query, 's', $params)) {
        die(http_response_code(401));
    }

    if (!$result = fetch_data($stmt)) {
        die(http_response_code(400));
    }

    if (!$row = $result->fetch_assoc()) {
        die(http_response_code(400));
    }

    if (!isset($row['id'])) {
        die(http_response_code(400));
    }

    $id = $row['id'];

    $query = 'SELECT password FROM users WHERE id=(?)';
    $params = [$id];
    if (!$stmt = execute($connection, $query, 's', $params)) {
        die(http_response_code(400));
    }

    if (!$result = fetch_data($stmt)) {
        die(http_response_code(400));
    }

    if (!$row = $result->fetch_assoc()) {
        die(http_response_code(400));
    }

    if (!isset($row['password'])) {
        die(http_response_code(400)); 
    }

    if (!password_verify($pwd, $row['password'])) {
        die(http_response_code(401));
    }

    $query = 'DELETE FROM users WHERE id=(?)';
    $params = [$id];
    if (!$stmt = execute($connection, $query, 's', $params)) {
        die(http_response_code(400));
    }

    echo http_response_code(200);
    $stmt->close();
    $connection->close();
}
?>