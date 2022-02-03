import 'package:flutter/material.dart';

import 'package:app/floating_chat_view.dart';
import 'package:app/dummy_data.dart';
import 'floating_chat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey _widgetKey = GlobalKey();

  // dummy data
  late List<FloatingChat> data;
  late FloatingChat center;

  @override
  void initState() {
    super.initState();
    data = dummyChats;
    center = dummyCenter;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxHeight = size.height;
    final maxWidth = size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FloatingChatView(
        globalKey: _widgetKey,
        centerChatBubble: center,
        chatRooms: data,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
      ),
    );
  }
}
