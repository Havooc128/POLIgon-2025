import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:poligon/main.dart';
import 'package:poligon/service/web_socket_service.dart';

/// Author: Łukasz Piętka (FUT 2025)
class MaxWidthContainer extends StatefulWidget {
  final Widget child;

  const MaxWidthContainer({super.key, required this.child});

  @override
  State<MaxWidthContainer> createState() => _MaxWidthContainerState();
}

bool _isConnected = true;

/// Author: Łukasz Piętka (FUT 2025)
class _MaxWidthContainerState extends State<MaxWidthContainer> {
  StreamSubscription? _internetConnectionSS;

  @override
  void initState() {
    super.initState();
    _internetConnectionSS = InternetConnection().onStatusChange.listen((e) {
      switch (e) {
        case InternetStatus.connected:
          if (!_isConnected) {
            sendSnackBar(context, message: 'Przywrócono połączenie z internetem');
            setState(() {
              _isConnected = true;
            });
          }
        break;
        case InternetStatus.disconnected:
          if (_isConnected) {
            sendSnackBar(context, message: 'Utracono połączenie z internetem!');
              _isConnected = false;
          }
          break;
      }
    });
  }

  @override
  void dispose() {
    _internetConnectionSS?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WebSocketService service = WebSocketService();
    if(!service.isConnected) {
      print('WebSocket found inactive - reconnecting...');
      service.connect();
    }
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: widget.child,
      ),
    );
  }
}
