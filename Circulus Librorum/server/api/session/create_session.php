<?php

$root = $_SERVER['DOCUMENT_ROOT'];

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';

function create_session(): array {
    try {
        $data = get_content();

        if (!isset($data['token'], $data['club_id'], $data['book_title'], $data['description'])) {
            throw new Exception('Not enough input values');
        }

        $token = trim($data['token']);
        $club_id = trim($data['club_id']);
        $book_title = trim($data['book_title']);
        $description = trim($data['description']);

        $connection = connect();
        $usr_id = validate_user_token($connection, $token);

        $query = 'SELECT * FROM clubs WHERE owner_id=(?) AND id=(?)';
        $params = [$usr_id, $club_id];
        $result = execute($connection, $query, 'ii', $params);

        if ($result['count'] <= 0) {
            throw new Exception('Couldnt create sessions');
        }

        $query = 'INSERT INTO sessions (club_id, book_title, description, completed) VALUES (?, ?, ?, false)';
        $params = [$club_id, $book_title, $description];
        $result = execute($connection, $query, 'iss', $params);

        if ($result['affected_rows'] <= 0) {
            throw new Exception('Couldnt create session');
        }

        return [
            'success' => true,
            'message' => 'Session was created successfully',
        ];
    } catch (Exception $e) {
        throw new Exception($e);
    }
} 
?>