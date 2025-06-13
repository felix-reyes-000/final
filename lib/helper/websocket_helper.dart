import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:get/get.dart';
import 'package:sixam_mart_store/features/order/controllers/order_controller.dart';
import 'package:sixam_mart_store/features/dashboard/widgets/new_request_dialog_widget.dart';
import 'package:sixam_mart_store/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebSocketHelper {
  static final WebSocketHelper _instance = WebSocketHelper._internal();
  factory WebSocketHelper() => _instance;
  WebSocketHelper._internal();

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  bool _isConnected = false;
  bool _isConnecting = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectInterval = Duration(seconds: 5);
  static const Duration _pingInterval = Duration(seconds: 30);

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;

  Future<void> connect() async {
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      final wsUrl = Uri.parse('${ApiConfig.baseUrl.replaceAll('http', 'ws')}/ws');
      _channel = WebSocketChannel.connect(wsUrl);
      
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
          _reconnectAttempts = 0; // Reset reconnect attempts on successful message
        },
        onError: (error) {
          print('WebSocket Error: $error');
          _handleError(error);
        },
        onDone: () {
          print('WebSocket Connection Closed');
          _handleDisconnection();
        },
      );

      _startPingTimer();
      _isConnected = true;
    } catch (e) {
      print('WebSocket Connection Error: $e');
      _handleError(e);
    } finally {
      _isConnecting = false;
    }
  }

  void _handleError(dynamic error) {
    _isConnected = false;
    _stopPingTimer();
    
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      _scheduleReconnect();
    } else {
      print('Max reconnection attempts reached');
      // Notify user or handle max attempts reached
    }
  }

  void _handleDisconnection() {
    _isConnected = false;
    _stopPingTimer();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectInterval, () {
      if (!_isConnected && !_isConnecting) {
        connect();
      }
    });
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (timer) {
      if (_isConnected) {
        _sendPing();
      }
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _sendPing() {
    try {
      _channel?.sink.add('ping');
    } catch (e) {
      print('Error sending ping: $e');
      _handleError(e);
    }
  }

  void _handleMessage(dynamic message) {
    try {
      if (message == 'pong') return;
      
      final data = json.decode(message);
      if (data['type'] == 'new_order') {
        _handleNewOrder(data['data']);
      }
    } catch (e) {
      print('Error handling message: $e');
    }
  }

  void _handleNewOrder(Map<String, dynamic> orderData) {
    // Handle new order notification
    // This will be implemented in the UI layer
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _stopPingTimer();
    _channel?.sink.close();
    _isConnected = false;
    _isConnecting = false;
    _reconnectAttempts = 0;
  }

  @override
  void dispose() {
    disconnect();
  }
} 