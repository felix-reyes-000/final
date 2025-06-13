<?php

namespace App\Http\Controllers;

use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;
use Illuminate\Support\Facades\Auth;
use App\Models\Order;
use App\Models\Store;

class WebSocketController extends Controller implements MessageComponentInterface
{
    protected $clients;
    protected $storeConnections;

    public function __construct()
    {
        $this->clients = new \SplObjectStorage;
        $this->storeConnections = [];
    }

    public function onOpen(ConnectionInterface $conn)
    {
        $this->clients->attach($conn);
        
        // Get token from query string
        $query = parse_url($conn->httpRequest->getUri(), PHP_URL_QUERY);
        parse_str($query, $params);
        
        if (isset($params['token'])) {
            $store = Store::where('auth_token', $params['token'])->first();
            if ($store) {
                $this->storeConnections[$store->id] = $conn;
                $conn->store_id = $store->id;
            }
        }
    }

    public function onMessage(ConnectionInterface $from, $msg)
    {
        $data = json_decode($msg);
        
        if ($data->type === 'ping') {
            $from->send(json_encode(['type' => 'pong']));
        }
    }

    public function onClose(ConnectionInterface $conn)
    {
        $this->clients->detach($conn);
        
        if (isset($conn->store_id)) {
            unset($this->storeConnections[$conn->store_id]);
        }
    }

    public function onError(ConnectionInterface $conn, \Exception $e)
    {
        $conn->close();
    }

    public function notifyNewOrder($storeId, $orderId)
    {
        if (isset($this->storeConnections[$storeId])) {
            $this->storeConnections[$storeId]->send(json_encode([
                'type' => 'new_order',
                'order_id' => $orderId
            ]));
        }
    }
} 