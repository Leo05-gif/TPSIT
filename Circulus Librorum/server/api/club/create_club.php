<?php

$root = $_SERVER['DOCUMENT_ROOT'];

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';

function create_club(): array {
    try {
        $data = get_content();

        if (!isset($data['token'], $data['name'], $data['description'])) {
            throw new Exception('Not enough input values');
        }

        $usr_token = trim($data['token']);
        $club_name = trim($data['name']);
        $club_description = trim($data['description']);

        $connection = connect();

        $owner_id = validate_user_token($connection, $usr_token);

        $query = 'INSERT INTO clubs (owner_id, name, description, created_at) VALUES (?, ?, ?, NOW())';
        $params = [$owner_id, $club_name, $club_description];
        $insert_result = execute($connection, $query, 'iss', $params);

        $club_id = $insert_result['last_insert_id'];

        if ($club_id === null) {
            throw new Exception('Couldnt create club');
        }

        $query = 'INSERT INTO club_memberships (user_id, club_id, joined_in) VALUES (?, ?, NOW())';
        $params = [$owner_id, $club_id];
        execute($connection, $query, 'ii', $params);

        return [
            'success' => true,
            'message' => 'Successful club creation',
        ];
    } catch (Exception $e) {
        throw new Exception($e);
    }
}
?>