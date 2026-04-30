<?php

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';

function complete_turn(): array {
    try {
        $data = get_content();

        if (!isset($data['token'], $data['club_id'], $data['turn_id'], $data['value'])) {
            throw new Exception('Not enough input values');
        }

        $token = trim($data['token']);
        $club_id = trim($data['club_id']);
        $turn_id = trim($data['turn_id']);
        $value = trim($data['value']);

        $connection = connect();
        $usr_id = validate_user_token($connection, $token);

        $query = 'SELECT * FROM clubs WHERE owner_id=(?) AND id=(?)';
        $params = [$usr_id, $club_id];
        $result = execute($connection, $query, 'ii', $params);

        if ($result['count'] <= 0) {
            throw new Exception('Invalid operation');
        }

        $query = 'UPDATE turns SET completed=(?) WHERE id=(?)';
        $params = [$value, $turn_id];
        $result = execute($connection, $query, 'ii', $params);

        if ($result['affected_rows'] <= 0) {
            throw new Exception('Couldnt update turn');
        }

        return [
            'success' => true,
            'message' => 'action done successfully'
        ];
    } catch (Exception $e) {
        throw new Exception($e);
    }
}
?>