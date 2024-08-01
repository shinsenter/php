<?php
require __DIR__ . '/vendor/autoload.php';

use Nyholm\Psr7\Response;
use Nyholm\Psr7\Factory\Psr17Factory;

use Spiral\RoadRunner\Worker;
use Spiral\RoadRunner\Http\PSR7Worker;

$worker  = Worker::create();
$factory = new Psr17Factory();
$psr7    = new PSR7Worker($worker, $factory, $factory, $factory);

while (true) {
    try {
        $request = $psr7->waitRequest();
        if ($request === null) {
            break;
        }
    } catch (\Throwable $e) {
        $psr7->respond(new Response(400));
        continue;
    }

    try {
        ob_start();
        if ((bool) trim((string) shell_exec('is-debug && echo 1 || echo 0'))) {
            phpinfo();
        } else {
            echo 'It works!';
        }
        $html = ob_get_contents();
        ob_clean();

        $psr7->respond(new Response(200, [], $html));
    } catch (\Throwable $e) {
        $psr7->respond(new Response(500, [], 'Something went wrong!'));
        $psr7->getWorker()->error((string)$e);
    }
}
