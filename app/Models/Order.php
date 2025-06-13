protected static function booted()
{
    static::created(function ($order) {
        // Get WebSocket controller instance
        $wsController = app()->make('App\Http\Controllers\WebSocketController');
        
        // Notify store about new order
        $wsController->notifyNewOrder($order->store_id, $order->id);
        
        // Continue with existing notification logic
        // ... existing notification code ...
    });
} 