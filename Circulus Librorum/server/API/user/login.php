<?php

include_once __DIR__ . '/../../utils/token.php';
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

    $connection = connect();

    $query = 'SELECT * FROM users WHERE username=(?)';
    $params = [$usr];
    if (!$stmt = execute($connection, $query, 's', $params)) {
        die(http_response_code(400));
    }

    if (!$result = fetch_data($stmt)) {
        die(http_response_code(400));
    }

    if (!$row = $result->fetch_assoc()) {
        die(http_response_code(400));
    }

    if (!isset($row['id'], $row['password'])) {
        die(http_response_code(400)); 
    }

    if (!password_verify($pwd, $row['password'])) {
        die(http_response_code(401));
    }

    if (!$token = create_token($connection, $row['id'])) {
        die(http_response_code(400));
    }
    
    header('Content-Type: application/json');
    http_response_code(200);
    echo json_encode(['token' => $token]);

    $connection->close();
}
?>