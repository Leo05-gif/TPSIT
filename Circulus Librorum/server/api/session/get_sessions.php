<?php
function get_sessions() {
    try {
        $data = get_content();

        if (!isset($data['token'], $data['club_id'])) {
            throw new Exception('Not enough input values');
        }

        $token = trim($data['token']);
        $club_id = trim($data['club_id']);

        $connection = connect();
        validate_user_token($connection, $token);

        $query = 'SELECT * FROM sessions WHERE club_id=(?)';
        $params = [$club_id];
        $result = execute($connection, $query, 'i', $params);
        
        return [
            'success' => true,
            'data' => $result['data'][0],
        ];

    } catch (Exception $e) {
        throw new Exception($e);
    }
}
?>