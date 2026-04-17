<?php

function get_routes(): array {
    return $router = [
            'user' => [
                'login' => 'login',
                'register' => 'register',
                'delete_user' => 'delete_user'
            ],
            'club' => [
                'create_club' => 'create_club',
                'delete_club' => 'delete_club',
                'create_invite' => 'create_invite' 
            ]
        ];
}
?>