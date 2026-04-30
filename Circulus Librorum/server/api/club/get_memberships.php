<?php
$root = $_SERVER['DOCUMENT_ROOT'];

require_once $root . '/utils/handler.php';
require_once $root . '/utils/database.php';
require_once $root . '/utils/user_token.php';

function get_memberships(): array {
    try {
        $data = get_content();

        if (!isset($data['token'])) {
            throw new Exception('Not enough input values');
        }

        $token = trim($data['token']);

        $connection = connect();
        $usr_id = validate_user_token($connection, $token);

        $query = 'SELECT * FROM club_memberships WHERE user_id=(?)';
        $param = [$usr_id];
        $result = execute($connection, $query, 'i', $param);

        if ($result['count'] <= 0) {
            throw new Exception('Couldnt find memberships');
        }

        return [
            'success' => true,
            'data' => $result['data'][0],
        ];
    } catch (Exception $e) {
        throw new Exception($e);
    }
}
?>