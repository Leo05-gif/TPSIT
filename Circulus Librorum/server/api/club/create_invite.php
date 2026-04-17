<?php
$root = $_SERVER['DOCUMENT_ROOT'];

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';
require_once $root . '/utils/club_token.php';

function create_invite() {
    try {
        $data = get_content();

        if (!isset($data['token'], $data['club_id'])) {
            throw new Exception('Not enough input values');
        }

        $user_token = trim($data['token']);
        $club_id = trim($data['club_id']);

        $connection = connect();
        $owner_id = validate_user_token($connection, $user_token);

        $query = 'SELECT * FROM clubs WHERE owner_id=(?) AND id=(?)';
        $params = [$owner_id, $club_id];
        $result = execute($connection, $query, 'ii', $params);

        if ($result['count'] <= 0) {
            throw new Exception('Club isnt owned by user');
        }

        $invite = create_club_invite($connection, $owner_id, $club_id);
    
        http_response_code(201);
        return [
            'success' => true,
            'message' => 'Successful invite creation',
            'invite' => $invite,
        ];
    } catch (Exception $e) {
        throw new Exception('Cannot create invite: ' . $e->getMessage());
    }
}
?>