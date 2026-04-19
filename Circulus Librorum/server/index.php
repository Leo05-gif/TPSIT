<?php

header('Content-Type: application/json');

require_once 'config/router.php';
require_once 'config/bootstrap.php';

$route = get_routes();

$uri = explode('/', $_SERVER['REQUEST_URI']);

if (!isset($uri[1], $uri[2], $uri[3]) || strcmp($uri[1], 'service') || empty($uri[2]) && empty($uri[3])) {
    http_response_code(404);
    die (json_encode([
        'success' => false,
        'message' => 'Unknown URI'
    ]));
}

$input_resource = $uri[2];
$input_method = $uri[3];

foreach ($route as $resource_key=>$resource_value) {
    foreach ($resource_value as $method_key=>$method_value) {
        if ($input_resource == $resource_key && $input_method == $method_value) {
            try {
                die(json_encode(call_user_func($method_value)));
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
}

http_response_code(406);
die (json_encode([
    'success' => false,
    'message' => 'Unknown Method'
]));
?>