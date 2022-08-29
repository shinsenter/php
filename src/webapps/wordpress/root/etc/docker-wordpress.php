<?php

function docker_config($config_path)
{
    try {
        if (file_exists($config_path)) {
            $content = preg_replace(
                '/^define\( *["\']([a-z0-9_]+)["\'],( *)((?!.*getenv *\( *\'WORDPRESS_).+?) *\) *;/mi',
                'define( \'$1\',$2getenv(\'WORDPRESS_$1\') ?: $3 );',
                file_get_contents($config_path)
            );

            if (!empty($content)) {
                file_put_contents($config_path, $content);
            }
        }
    } catch (\Throwable $th) {
        unset($th);
    }
}

docker_config(getenv('WEBHOME') . '/wp-config-sample.php');
docker_config(getenv('WEBHOME') . '/wp-config.php');
