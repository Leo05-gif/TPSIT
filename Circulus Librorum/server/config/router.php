<?php

function get_routes(): array {
    return [
        'user' => [
            'login'    => ['POST'   => 'login'],
            'register' => ['POST'   => 'register'],
            'delete'   => ['DELETE' => 'delete_user'],
        ],
        'club' => [
            'create' => ['POST'   => 'create_club'],
            'delete' => ['DELETE' => 'delete_club'],
            'invite' => ['POST'   => 'create_invite'],
            'get'    => ['GET'    => 'get_memberships'],
            'join'   => ['POST'   => 'join_club'],
        ],
        'session' => [
            'create'   => ['POST'   => 'create_session'],
            'delete'   => ['DELETE' => 'delete_session'],
            'get'     => ['GET'    => 'get_sessions'],
            'complete' => ['PUT'    => 'complete_session'],
        ],
        'turn' => [
            'create'   => ['POST'   => 'create_turn'],
            'delete'   => ['DELETE' => 'delete_turn'],
            'get'     => ['GET'    => 'get_turns'],
            'complete' => ['PUT'    => 'complete_turn'],
        ],
    ];
}