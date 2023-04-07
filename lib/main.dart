import 'package:flutter/material.dart';
import './home_page.dart';
import './scan_page.dart';
import './source_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/home': (BuildContext context) => const HomePage(),
        '/scan': (BuildContext context) => const ScanPage(),
        '/source': (BuildContext context) => const SourcePage(),
      },
      initialRoute: '/home',
    );
  }
}

//minSDKVersion is set to 20 however it can be changed