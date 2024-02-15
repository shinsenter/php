<?php

declare(strict_types=1);

$vars = array(
    'PHP_MAX_EXECUTION_TIME',
    'PHP_MEMORY_LIMIT',
    'PMA_ABSOLUTE_URI',
    'PMA_ARBITRARY',
    'PMA_BLOWFISH_SECRET',
    'PMA_CONTROLHOST',
    'PMA_CONTROLPASS',
    'PMA_CONTROLPORT',
    'PMA_CONTROLUSER',
    'PMA_DEFAULTLANG',
    'PMA_HOST',
    'PMA_HOSTS',
    'PMA_MAXROWS',
    'PMA_PASSWORD',
    'PMA_PMADB',
    'PMA_PORT',
    'PMA_PORTS',
    'PMA_PROPERTIESNUMCOLUMNS',
    'PMA_PROTECTBINARY',
    'PMA_QUERYHISTORYDB',
    'PMA_QUERYHISTORYMAX',
    'PMA_ROWACTIONTYPE',
    'PMA_SENDERRORREPORTS',
    'PMA_SHOWALL',
    'PMA_SOCKET',
    'PMA_SOCKETS',
    'PMA_URLQUERYENCRYPTION',
    'PMA_URLQUERYENCRYPTIONSECRETKEY',
    'PMA_USER',
    'PMA_VERBOSE',
    'PMA_VERBOSES',
    'APP_PATH',
);
foreach ($vars as $var) {
    $env = getenv($var);
    if (!isset($_ENV[$var]) && $env !== false) {
        $_ENV[$var] = $env;
    }
}

$cfg      = [];
$root_dir = $_ENV['APP_PATH'] ?: '/var/www/html';

$cfg['UploadDir']                   = $root_dir . '/tmp/upload';
$cfg['SaveDir']                     = $root_dir . '/tmp/save';
$cfg['AllowArbitraryServer']        = (bool) ($_ENV['PMA_ARBITRARY'] ?? false);
$cfg['blowfish_secret']             = ($_ENV['PMA_BLOWFISH_SECRET'] ?? 'random_string_with_32_chars_long');
$cfg['DefaultLang']                 = ($_ENV['PMA_DEFAULTLANG'] ?? 'en');
$cfg['MaxRows']                     = (int) ($_ENV['PMA_MAXROWS'] ?? '100');
$cfg['PmaAbsoluteUri']              = ($_ENV['PMA_ABSOLUTE_URI'] ?? '');
$cfg['PropertiesNumColumns']        = (int) ($_ENV['PMA_PROPERTIESNUMCOLUMNS'] ?? '2');
$cfg['ProtectBinary']               = (bool) ($_ENV['PMA_PROTECTBINARY'] ?? true);
$cfg['QueryHistoryDB']              = (bool) ($_ENV['PMA_QUERYHISTORYDB'] ?? true);
$cfg['QueryHistoryMax']             = (int) ($_ENV['PMA_QUERYHISTORYMAX'] ?? '100');
$cfg['RowActionType']               = ($_ENV['PMA_ROWACTIONTYPE'] ?? 'both');
$cfg['SendErrorReports']            = ($_ENV['PMA_SENDERRORREPORTS'] ?? 'never');
$cfg['ShowAll']                     = (bool) ($_ENV['PMA_SHOWALL'] ?? false);
$cfg['URLQueryEncryption']          = (bool) ($_ENV['PMA_URLQUERYENCRYPTION'] ?? false);
$cfg['URLQueryEncryptionSecretKey'] = ($_ENV['PMA_URLQUERYENCRYPTIONSECRETKEY'] ?? '');

if (isset($_ENV['PHP_MAX_EXECUTION_TIME'])) {
    $cfg['ExecTimeLimit'] = $_ENV['PHP_MAX_EXECUTION_TIME'];
}

if (isset($_ENV['PHP_MEMORY_LIMIT'])) {
    $cfg['MemoryLimit'] = $_ENV['PHP_MEMORY_LIMIT'];
}

/* Fallback to default linked */
$hosts = array('mysql');

/* Set by environment */
if (!empty($_ENV['PMA_HOST'])) {
    $hosts = array($_ENV['PMA_HOST']);
    $verbose = array($_ENV['PMA_VERBOSE'] ?? '');
    $ports = array($_ENV['PMA_PORT'] ?? '');
} elseif (!empty($_ENV['PMA_HOSTS'])) {
    $hosts = array_map('trim', explode(',', $_ENV['PMA_HOSTS']));
    $verbose = array_map('trim', explode(',', $_ENV['PMA_VERBOSES'] ?? ''));
    $ports = array_map('trim', explode(',', $_ENV['PMA_PORTS'] ?? ''));
}
if (!empty($_ENV['PMA_SOCKET'])) {
    $sockets = array($_ENV['PMA_SOCKET']);
} elseif (!empty($_ENV['PMA_SOCKETS'])) {
    $sockets = explode(',', $_ENV['PMA_SOCKETS']);
}

/* Server settings */
for ($i = 1; isset($hosts[$i - 1]); $i++) {
    $cfg['Servers'][$i]['host'] = $hosts[$i - 1];
    if (isset($verbose[$i - 1])) {
        $cfg['Servers'][$i]['verbose'] = $verbose[$i - 1];
    }
    if (isset($ports[$i - 1])) {
        $cfg['Servers'][$i]['port'] = $ports[$i - 1];
    }
    if (isset($_ENV['PMA_USER'])) {
        $cfg['Servers'][$i]['auth_type'] = 'config';
        $cfg['Servers'][$i]['user'] = $_ENV['PMA_USER'];
        $cfg['Servers'][$i]['password'] = isset($_ENV['PMA_PASSWORD']) ? $_ENV['PMA_PASSWORD'] : '';
    } else {
        $cfg['Servers'][$i]['auth_type'] = 'cookie';
    }
    if (isset($_ENV['PMA_PMADB'])) {
        $cfg['Servers'][$i]['pmadb'] = $_ENV['PMA_PMADB'];
        $cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
        $cfg['Servers'][$i]['relation'] = 'pma__relation';
        $cfg['Servers'][$i]['table_info'] = 'pma__table_info';
        $cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
        $cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
        $cfg['Servers'][$i]['column_info'] = 'pma__column_info';
        $cfg['Servers'][$i]['history'] = 'pma__history';
        $cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
        $cfg['Servers'][$i]['tracking'] = 'pma__tracking';
        $cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
        $cfg['Servers'][$i]['recent'] = 'pma__recent';
        $cfg['Servers'][$i]['favorite'] = 'pma__favorite';
        $cfg['Servers'][$i]['users'] = 'pma__users';
        $cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
        $cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
        $cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
        $cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
        $cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
        $cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
    }
    if (isset($_ENV['PMA_CONTROLHOST'])) {
        $cfg['Servers'][$i]['controlhost'] = $_ENV['PMA_CONTROLHOST'];
    }
    if (isset($_ENV['PMA_CONTROLPORT'])) {
        $cfg['Servers'][$i]['controlport'] = $_ENV['PMA_CONTROLPORT'];
    }
    if (isset($_ENV['PMA_CONTROLUSER'])) {
        $cfg['Servers'][$i]['controluser'] = $_ENV['PMA_CONTROLUSER'];
    }
    if (isset($_ENV['PMA_CONTROLPASS'])) {
        $cfg['Servers'][$i]['controlpass'] = $_ENV['PMA_CONTROLPASS'];
    }
    $cfg['Servers'][$i]['compress'] = false;
    $cfg['Servers'][$i]['AllowNoPassword'] = true;
}
for ($i = 1; isset($sockets[$i - 1]); $i++) {
    $cfg['Servers'][$i]['socket'] = $sockets[$i - 1];
    $cfg['Servers'][$i]['host'] = 'localhost';
}

$i--;

@file_exists($root_dir . '/config.user.inc.php') && include($root_dir . '/config.user.inc.php');
