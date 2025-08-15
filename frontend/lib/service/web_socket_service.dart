import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

/// Author: Łukasz Piętka (FUT 2025)
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();

  factory WebSocketService() => _instance;

  WebSocketService._internal();

  WebSocketChannel? _channel;
  final Map<String, void Function(Map<String, dynamic>)> _handlers = {};
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  /// Umożliwia rejestrowanie handlera dla konkretnego typu wiadomości (np. "announcements")
  void registerHandler(String type, void Function(Map<String, dynamic>) handler) {
    if (_handlers.containsKey(type)) return;
    _handlers[type] = handler;
  }

  void unregisterHandler(String type) {
    _handlers.remove(type);
  }

  /// Połączenie z WebSocketem
  void connect() {
    if (_isConnected) return;

    final uri = Uri.parse("wss://poligon-2025.azurewebsites.net/api/ws");
    _channel = WebSocketChannel.connect(uri);
    _isConnected = true;

    _channel!.stream.listen((message) {
      try {
        final data = jsonDecode(message);
        final type = data['type'];

        if (type != null && _handlers.containsKey(type)) {
          _handlers[type]!(data);
        }
      } catch (e) {
        print("Failed to parse WebSocket message: $e");
      }
    }, onError: (error) {
      print("WebSocket error: $error");
      _isConnected = false;
    }, onDone: () {
      print("WebSocket closed");
      _isConnected = false;
    });

    print("WebSocket connected");
  }

  void dispose() {
    _channel?.sink.close(status.normalClosure);
    _isConnected = false;
    _handlers.clear();
  }
}
