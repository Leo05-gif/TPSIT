<?php
function check_param(&$param) {
    if (strlen($param) < 8 && is_string($param)) {
        return false;
    }
    return true;
}

function get_content() {
    if (!$content = file_get_contents('php://input')) {
        die(http_response_code(400));
    }
    return json_decode($content, true);
}
?>