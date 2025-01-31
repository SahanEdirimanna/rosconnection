import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String rosBridgeUrl = "ws://10.10.18.70:9090"; // Change to ROS PC IP
  late WebSocketChannel channel;
  bool isConnected = false;
  String rosMessage = "Test your codes here";

  @override
  void initState() {
    super.initState();
    connectToRos();
  }

  void connectToRos() {
    channel = WebSocketChannel.connect(Uri.parse(rosBridgeUrl));
    channel.stream.listen((message) {
      setState(() {
        rosMessage = "Received: $message";
      });
    }, onDone: () {
      setState(() {
        isConnected = false;
      });
    }, onError: (error) {
      print("WebSocket error: $error");
    });

    setState(() {
      isConnected = true;
    });
  }

  void test1() {
    if (isConnected) {
      var msg = {
        "op": "publish",
        "topic": "/chatter",
        "msg": {"data": "test 1 helloo from mac"}       
      };
      channel.sink.add(jsonEncode(msg));
    }
  }

  void test2() {
    if (isConnected) {
      var msg = {
        "op": "publish",
        "topic": "/chatter",
        "msg": {"data": "test 2 helloo from mac"}       
      };
      channel.sink.add(jsonEncode(msg));
    }
  }
  void getInfo() {
    if (isConnected) {
      var msg = {
        "op": "call_service",
        "service": "/get_info",
        "args": {}
      };
      channel.sink.add(jsonEncode(msg));
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Flutter ROS ")),
        body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(rosMessage, style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: test1,
            child: Text("test1"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: test2,
            child: Text("test2"),
          ),
        ],
          ),
        ),
      ),
    );
  }
}