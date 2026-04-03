<?php

include_once __DIR__ . '/../../utils/database.php';
include_once __DIR__ . '/../../utils/handler.php';

if($_SERVER["REQUEST_METHOD"] == "POST") {
    $data = get_content();

    if (!isset($data['username']) && $data['password']) {
        die(http_response_code(400));
    }

    $usr = trim($data['username']);
    $pwd = trim($data['password']);

    if (!check_param($usr) || !check_param($pwd)) {
        die(http_response_code(400));
    }

    $pwd_hash = password_hash($pwd, PASSWORD_BCRYPT);

    $connection = connect();

    $query = 'SELECT username from users WHERE username=(?)';
    $params = [$usr];
    if (!$stmt = execute($connection, $query, 's', $params)) {
        die(http_response_code(400));
    }

    if (!$result = fetch_data($stmt)) {
        die(http_response_code(400));
    }

    if ($row = $result->fetch_assoc()) {
        die(http_response_code(400));
    }

    $query = 'INSERT INTO users(username, password, created_at) VALUES(?, ?, NOW())';
    $params = [$usr, $pwd_hash];
    if (!$stmt = execute($connection, $query, 'ss', $params)) {
        die(http_response_code(400));
    }

    echo http_response_code(201);
     
    $stmt->close();
    $connection->close();
}
?>