<?php
require_once 'database.php';

function create_club_token(&$connection, &$user_id, &$club_id): string {
    try {
        $token = generate_club_token();
        $query = 'INSERT INTO club_invites (token, created_by, club_id, expires_at) VALUES (?, ?, ?, NOW() + INTERVAL 1 DAY)';
        $params = [$token, $user_id, $club_id];

        $result = execute($connection, $query, 'sii', $params);

        if ($result['affected_rows'] <= 0) {
            throw new Exception('Couldnt create invite');
        }

        return $token;
    } catch (Exception $e) {
        throw new Exception('Cannot create invite token: ' + $e->getMessage());
    }
}

function validate_club_token(&$connection, &$token): void {
    try {
        $query = 'SELECT expires_at FROM club_invites WHERE token=(?)';
        $params = [$token];

        $result = execute($connection, $query, 's', $params);

        if ($result['count'] <= 0) {
            throw new Exception('Invalid club token');
        }

        $tokenData = $result['data'][0];

        $format = 'Y-m-d H:i:s';
        $current_date = \DateTime::createFromFormat($format, time());
        $expires_at_date = \DateTime::createFromFormat($format, $tokenData['expires_at']);

        $query = 'DELETE FROM club_invites WHERE token=(?)';
        $params = [$token];
        execute($connection, $query, 's', $params);

        if ($current_date > $expires_at_date) {
            throw new Exception('Expired token');
        }
    } catch (Exception $e) {
        throw new Exception('Failed to validate invite token. Please try again later.');
    }
}

function generate_club_token(): string {
    return bin2hex(random_bytes(4));
}
?>