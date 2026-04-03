<?php
define('DB_SERVER', '127.0.0.1:3306');
define('DB_USERNAME', 'root');
define('DB_PASSWORD', '1234');
define('DB_NAME', 'librorum');


function connect(): mixed {
    try {
        $connection = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);        
    } catch (Exception $e) {
        echo http_response_code(503);
        die('CONNECTION ERROR'. $e->getMessage());
    }
    return $connection; 
}

function execute(&$connection, $query, $types, $params): mixed {
    if (!$stmt = $connection->prepare($query)) {
        return false;
    }

    if (!$stmt->bind_param($types, ...$params)) {
        $stmt->close();
        return false;
    }

    if (!$stmt->execute()) {
        $stmt->close();
        return false;
    }

    return $stmt;
}

function fetch_data($stmt) {
    if (!$result = $stmt->get_result()) {
        return false;
    }
    $stmt->close();
    return $result;
}
?>