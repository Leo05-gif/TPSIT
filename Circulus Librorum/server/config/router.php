<?php

function get_routes(): array {
    return $router = [
            'user' => [
                'login' => 'login',
                'register' => 'register',
                'delete' => 'delete_user'
            ],
            'club' => [
                'create' => 'create_club',
                'delete' => 'delete_club'
            ]
        ];
}
?>