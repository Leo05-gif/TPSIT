<?php

define('DB_SERVER', '127.0.0.1:3306');
define('DB_USERNAME', 'root');
define('DB_PASSWORD', '123');
define('DB_NAME', 'librorum');

function connect(): mysqli {
    mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

    try {
        $connection = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);
        $connection->set_charset('utf8mb4');
        return $connection;
    } catch (mysqli_sql_exception $e) {
        error_log('Database connection failed: ' . $e->getMessage() . 
                    ' | Code: ' . $e->getCode());

        throw new Exception('Unable to connect to the database. Please try again later.');
    }  
}

function execute(&$connection, string $query, string $types = '', array $params = []): array {
    try {
        $stmt = $connection->prepare($query);

        if (!$stmt) {
            throw new mysqli_sql_exception('Prepare failed: ' . $connection->error);
        }

         if (!empty($params)) {
            if (strlen($types) !== count($params)) {
                throw new Exception('Parameter count does not match types');
            }
            $stmt->bind_param($types, ...$params);
        }

        $stmt->execute();

        if (stripos(trim($query), 'SELECT') === 0) {
            $result = $stmt->get_result();
            $data = $result->fetch_all(MYSQLI_ASSOC);
            $stmt->close();

            return [
                'data'    => $data,
                'count'   => count($data)
            ];
        }

        $affected = $stmt->affected_rows;
        $lastInsertId = $connection->insert_id;
        $stmt->close();

        return [
            'affected_rows'  => $affected,
            'last_insert_id' => $lastInsertId ?: null
        ];

    } catch (mysqli_sql_exception | Exception $e) {
        error_log('Query failed: ' . $e->getMessage() . 
                ' | Query: ' . $query . 
                ' | Params: ' . json_encode($params));

        throw new Exception('Database operation failed. Please try again later.');
    }
}

?>