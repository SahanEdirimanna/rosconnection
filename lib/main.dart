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
  final String rosBridgeUrl = "ws://10.10.18.70:9090"; // Change to your ROS PC's IP
  late WebSocketChannel channel;
  bool isConnected = false;
  String rosMessage = "Test your codes here";

  List<String> jointNames = [];
  List<double> positions = [];
  List<double> velocities = [];
  List<double> efforts = [];

  @override
  void initState() {
    super.initState();
    connectToRos();
  }

  void connectToRos() {
    channel = WebSocketChannel.connect(Uri.parse(rosBridgeUrl));

    // Subscribe to /m1n6s200_driver/out/joint_state topic
    var subscribeMsg = {
      "op": "subscribe",
      "topic": "/m1n6s200_driver/out/joint_state"
    };
    channel.sink.add(jsonEncode(subscribeMsg));

    // Listen for messages from ROS
    channel.stream.listen((message) {
      setState(() {
        rosMessage = "Received: $message";
        parseRosMessage(message); // Extract values from the message
      });
    }, onDone: () {
      setState(() {
        isConnected = false;
      });
    }, onError: (error) {
      setState(() {
        isConnected = false;
      });
    });
  }

  void parseRosMessage(String message) {
    try {
      Map<String, dynamic> data = jsonDecode(message);
      if (data.containsKey("msg")) {
        Map<String, dynamic> msg = data["msg"];

        setState(() {
          jointNames = List<String>.from(msg["name"] ?? []);
          positions = List<double>.from(msg["position"] ?? []);
          velocities = List<double>.from(msg["velocity"] ?? []);
          efforts = List<double>.from(msg["effort"] ?? []);
        });
      }
    } catch (e) {
      print("Error parsing message: $e");
    }
  }

  void test1() {
    if (isConnected) {
      var msg = {
        "op": "publish",
        "topic": "/chatter",
        "msg": {"data": "test 1 hello from mac"}       
      };
      channel.sink.add(jsonEncode(msg));
    }
  }

  void test2() {
    if (isConnected) {
      var msg = {
        "op": "publish",
        "topic": "/chatter",
        "msg": {"data": "test 2 hello from mac"}       
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
        appBar: AppBar(title: Text("Flutter ROS WebSocket")),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                //child: Text(rosMessage, style: TextStyle(fontSize: 18)),
              ),
              DataTable(
                columns: [
                  DataColumn(label: Text('Joint Name')),
                  DataColumn(label: Text('Position')),
                  DataColumn(label: Text('Velocity')),
                  DataColumn(label: Text('Effort')),
                ],
                rows: List.generate(
                  jointNames.length,
                  (index) => DataRow(cells: [
                    DataCell(Text(jointNames[index])),
                    DataCell(Text(positions.length > index ? positions[index].toStringAsFixed(2) : 'N/A')),
                    DataCell(Text(velocities.length > index ? velocities[index].toStringAsFixed(2) : 'N/A')),
                    DataCell(Text(efforts.length > index ? efforts[index].toStringAsFixed(2) : 'N/A')),
                  ]),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: test1,
                child: Text("Publish Test 1"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: test2,
                child: Text("Publish Test 2"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}