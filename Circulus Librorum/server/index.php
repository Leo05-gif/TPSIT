<?php

header('Content-Type: application/json');

require_once 'config/router.php';
require_once 'config/bootstrap.php';

$route = get_routes();

$uri = explode('/', parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));

if (!isset($uri[1], $uri[2], $uri[3]) || strcmp($uri[1], 'service') || empty($uri[2]) || empty($uri[3])) {
    http_response_code(404);
    die(json_encode([
        'success' => false,
        'message' => 'Unknown URI'
    ]));
}

$input_resource = $uri[2];
$input_method   = $uri[3];
$http_method    = $_SERVER['REQUEST_METHOD'];

$status_map = [
    'POST'   => 201,
    'GET'    => 200,
    'PUT'    => 200,
    'DELETE' => 200,
];

foreach ($route as $resource_key => $resource_value) {
    foreach ($resource_value as $method_key => $method_value) {
        if ($input_resource !== $resource_key || $input_method !== $method_key) {
            continue;
        }

        if (!isset($method_value[$http_method])) {
            http_response_code(405);
            header('Allow: ' . implode(', ', array_keys($method_value)));
            die(json_encode([
                'success' => false,
                'message' => 'Method not allowed'
            ]));
        }

        $handler     = $method_value[$http_method];
        $status_code = $status_map[$http_method] ?? 200;

        try {
            http_response_code($status_code);
            die(json_encode(call_user_func($handler)));
        } catch (Exception $e) {
            error_log('ERROR: ' . $e->getMessage());
            http_response_code(400);
            die(json_encode([
                'success' => false,
                'message' => $e->getMessage(),
            ]));
        }
    }
}

http_response_code(404);
die(json_encode([
    'success' => false,
    'message' => 'Unknown route'
]));