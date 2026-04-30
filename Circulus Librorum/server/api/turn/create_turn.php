<?php

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';

function create_turn(): array {
    try {
        $data = get_content();

        if (!isset($data['token'], $data['club_id'], $data['session_id'], $data['from'], $data['till'])) {
            throw new Exception('Not enough input values');
        }

        $token = trim($data['token']);
        $club_id = trim($data['club_id']);
        $session_id = trim($data['session_id']);
        $from = trim($data['from']);
        $till = trim($data['till']);

        $connection = connect();
        $usr_id = validate_user_token($connection, $token);

        $query = 'SELECT * FROM clubs WHERE owner_id=(?) AND id=(?)';
        $params = [$usr_id, $club_id];
        $result = execute($connection, $query, 'ii', $params);

        if ($result['count'] <= 0) {
            throw new Exception('Invalid operation');
        }

        $dtfrom = DateTime::createFromFormat('y-m-d', $from);
        $dttill = DateTime::createFromFormat('y-m-d', $till);

        $query = 'INSERT INTO turns (session_id, start, end, completed) VALUES (?, ?, ?, false)';
        $params = [$session_id, $from, $till];
        $result = execute($connection, $query, 'iss', $params);

        if ($result['affected_rows'] <= 0) {
            throw new Exception('Something went wrong!');
        }

        return [
            'success' => true,
            'message' => 'Turn created successfully'
        ];
        
    } catch (Exception $e) {
        throw new Exception($e);
    }
}
?>