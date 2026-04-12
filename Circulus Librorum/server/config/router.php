<?php

function get_routes(): array {
    return $router = [
            'user' => [
                'login' => 'user/login',
                'register' => 'user/register',
                'delete' => 'user/delete'
            ]
        ];
}
?>