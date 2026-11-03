<?php
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
// Shows which replica answered and what PHP sees behind the proxy.
header('Content-Type: application/json');
echo json_encode([
    'host'        => gethostname(),
    'https'       => $_SERVER['HTTPS'] ?? '',
    'scheme'      => $_SERVER['REQUEST_SCHEME'] ?? '',
    'remote_addr' => $_SERVER['REMOTE_ADDR'] ?? '',
]), "\n";
