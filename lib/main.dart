import 'package:flutter/material.dart';
import 'package:qrapp/pages/CameraScan.dart';
import 'package:qrapp/pages/ResultPage.dart';
import 'package:qrapp/pages/TestLocation.dart';

import 'pages/Home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.dark,
      home: CameraScan(),
//    home: ResultPage(),
    );
  }
}
