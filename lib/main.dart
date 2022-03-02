import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(Provider(
    create: (_) => Repo(),
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  WebSocket? _ws;
  var value = "";
  Timer? _timer;

  void _connect() async {
    try {
      print("connecting...");
      _ws = await context.read<Repo>().websocket.timeout(Duration(seconds: 10));
      print("connected");

      await for (var s in _ws!) {
        setState(() {
          value = s;
        });
      }
    } finally {
      print("disconnected");
      _timer = Timer(Duration(seconds: 10), () => _connect());
    }
  }

  @override
  void initState() {
    _connect();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ws?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text(value)),
      ),
    );
  }
}

class Repo {
  Future<WebSocket> get websocket => WebSocket.connect(
      'wss://demo.piesocket.com/v3/channel_1?api_key=oCdCMcMPQpbvNjUIzqtvF1d2X2okWpDQj4AwARJuAgtjhzKxVEjQU6IdCjwm&notify_self');
}
