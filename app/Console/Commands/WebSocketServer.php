<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Ratchet\Server\IoServer;
use Ratchet\Http\HttpServer;
use Ratchet\WebSocket\WsServer;
use App\Http\Controllers\WebSocketController;
use React\EventLoop\Factory;
use React\Socket\SecureServer;
use React\Socket\Server;

class WebSocketServer extends Command
{
    protected $signature = 'websocket:serve {--port= : The port to run the WebSocket server on}';
    protected $description = 'Start the WebSocket server';

    public function handle()
    {
        $host = config('websocket.host', '0.0.0.0');
        $port = $this->option('port') ?? config('websocket.port', 8080);
        $sslEnabled = config('websocket.ssl.enabled', false);

        $this->info("Starting WebSocket server on {$host}:{$port}...");
        
        $loop = Factory::create();
        $webSocket = new WebSocketController();
        $server = new Server("{$host}:{$port}", $loop);

        if ($sslEnabled) {
            $cert = config('websocket.ssl.cert');
            $key = config('websocket.ssl.key');
            
            if (empty($cert) || empty($key)) {
                $this->error('SSL is enabled but certificate or key is missing');
                return 1;
            }

            $server = new SecureServer($server, $loop, [
                'local_cert' => $cert,
                'local_pk' => $key,
                'verify_peer' => false,
            ]);
        }

        $server = new IoServer(
            new HttpServer(
                new WsServer($webSocket)
            ),
            $server,
            $loop
        );

        $this->info("WebSocket server started on {$host}:{$port}" . ($sslEnabled ? ' (SSL enabled)' : ''));
        $loop->run();
    }
} 