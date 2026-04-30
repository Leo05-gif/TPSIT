<?php

function get_routes(): array {
    return $router = [
            'user' => [
                'login' => 'login',
                'register' => 'register',
                'delete_user' => 'delete'
            ],
            'club' => [
                'create_club' => 'create_club',
                'delete_club' => 'delete_club',
                'create_invite' => 'create_invite' ,
                'get_memberships' => 'get_memberships',
                'join_club' => 'join_club'
            ],
            'session' => [
                'create_session' => 'create_session',
                'delete_session' => 'delete_session',
                'get_sessions' => 'get_sessions',
                'complete_session' => 'complete_session'
            ],
            'turn' => [
                'create_turn' => 'create_turn',
                'delete_turn' => 'delete_turn',
                'get_turns' => 'get_turns',
                'complete_turn' => 'complete_turn'
            ]
        ];
}
?>