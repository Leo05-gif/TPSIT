<?php
$root = $_SERVER['DOCUMENT_ROOT'];

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';

function get_memberships(): array {
    try {
        $data = $_GET;

        if (!isset($data['token'])) {
            throw new Exception('Not enough input values');
        }

        $token = trim($data['token']);

        $connection = connect();
        $usr_id = validate_user_token($connection, $token);

        $query = '
            SELECT
                c.id,
                c.owner_id,
                c.name,
                c.description,
                c.created_at,
                cm.joined_in
            FROM club_memberships cm
            JOIN clubs c ON c.id = cm.club_id
            WHERE cm.user_id = (?)
        ';
        $param = [$usr_id];
        $result = execute($connection, $query, 'i', $param);

        if ($result['count'] <= 0) {
            throw new Exception('Couldnt find memberships');
        }

        return [
            'success' => true,
            'data' => $result['data'],
        ];
    } catch (Exception $e) {
        throw new Exception($e->getMessage());
    }
}
?>