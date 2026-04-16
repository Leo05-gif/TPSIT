<?php

$root = $_SERVER['DOCUMENT_ROOT'];

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';

function create_club(): array {
    try {
        $data = get_content();

        if (!isset($data['token'], $data['name'], $data['description'])) {
            error_log('CREATE_CLUB: invalid input');
            throw new Exception('Not enough input values');
        }

        $usr_token = trim($data['token']);
        $club_name = trim($data['name']);
        $club_description = trim($data['description']);

        $connection = connect();

        validate_token($connection, $usr_token);

        $query = 'SELECT * FROM user_tokens WHERE token=(?)';
        $params = [$usr_token];
        $user_result = execute($connection, $query, 's', $params);

        if ($user_result['count'] <= 0) {
            error_log('CREATE_CLUB: user not found');
            throw new Exception('User not found');
        }

        $owner_id = $user_result['data'][0]['id'];

        $query = 'INSERT INTO clubs (owner_id, name, description, created_at) VALUES (?, ?, ?, NOW())';
        $params = [$owner_id, $club_name, $club_description];
        $insert_result = execute($connection, $query, 'iss', $params);

        $club_id = $insert_result['last_insert_id'];

        if ($club_id === null) {
            error_log('CREATE_CLUB: club id couldnt be found');
            throw new Exception('Couldnt create club');
        }

        $query = 'INSERT INTO club_memberships (user_id, club_id, joined_in) VALUES (?, ?, NOW())';
        $params = [$owner_id, $club_id];
        execute($connection, $query, 'ii', $params);

        http_response_code(201);
        return [
            'success' => true,
            'message' => 'Successful club creation',
        ];
    } catch (Exception $e) {
        error_log('CREATE_CLUB: cannot create a new club');
        throw new Exception('Cannot create a new club: ' . $e);
    }
}
?>