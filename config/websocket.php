<?php

return [
    /*
    |--------------------------------------------------------------------------
    | WebSocket Server Configuration
    |--------------------------------------------------------------------------
    |
    | Here you may configure the WebSocket server settings.
    |
    */

    'host' => env('WEBSOCKET_HOST', '0.0.0.0'),
    'port' => env('WEBSOCKET_PORT', 8080),
    'allowed_origins' => explode(',', env('WEBSOCKET_ALLOWED_ORIGINS', '*')),
    'ssl' => [
        'enabled' => env('WEBSOCKET_SSL_ENABLED', false),
        'cert' => env('WEBSOCKET_SSL_CERT', ''),
        'key' => env('WEBSOCKET_SSL_KEY', ''),
    ],
]; 