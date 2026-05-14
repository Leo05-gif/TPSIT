<?php
function check_param(&$param): bool {
    if (is_string($param) && strlen($param) < 4) {
        throw new Exception('Wrong input');
    }
    return true;
}

function get_content(): mixed {
    if (!$content = file_get_contents('php://input')) {
        throw new Exception('Cannot read input file');
    }
    return json_decode($content, true);
}
?>