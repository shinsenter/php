<?php

function docker_config($config_path)
{
    try {
        if (file_exists($config_path)) {
            $content = str_replace(' * @package WordPress
 */', ' * @package WordPress
 */

if (!function_exists(\'getenv_docker\')) {
	// a helper function to lookup "env_FILE", "env", then fallback
	function getenv_docker($env, $default) {
		if ($fileEnv = getenv($env . \'_FILE\')) {
			return rtrim(file_get_contents($fileEnv), "\r\n");
		}

		if (($val = getenv($env)) !== false) {
			return $val;
		}

		return $default;
	}
}
', file_get_contents($config_path));

            $content = preg_replace(
                '/^define\( *["\']([a-z0-9_]+)["\'],( *)((?!.*getenv_docker *\( *\'WORDPRESS_).+?) *\) *;/mi',
                'define( \'$1\',$2getenv_docker(\'WORDPRESS_$1\') ?: $3 );',
                $content
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
