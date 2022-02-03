import 'package:app/bubble.dart';
import 'package:flutter/material.dart';

import 'package:app/dummy_data.dart';

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
  late final List<BubbleInformation> dummys;

  @override
  void initState() {
    super.initState();
    dummys = dummyData;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: BubbleViewer(
        centerBubbleRadius: 100,
        bubbles: dummys,
        windowSize: size,
        centerImageURL:
            'https://cdn.pixabay.com/photo/2018/01/15/07/51/woman-3083387_1280.jpg',
        // backgroundColor: const Color(0xff833ab4),
        backgroundColor: const Color(0xfffcb045),
        useBadge: true,
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Hello World!'),
        )),
        onCenterPressed: () => print('center pressed'),
        enableSurroundingBackground: false,
      ),
    );
  }
}
