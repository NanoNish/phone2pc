import 'package:flutter/material.dart';
import 'package:phone2pc/broadcast_page.dart';
import 'package:phone2pc/camera_page.dart';
import 'package:phone2pc/home_page.dart';
import 'package:phone2pc/scan_page.dart';

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
        '/camerabcast': (BuildContext context) => CameraPage(isBroadcast: true),
        '/camerascan': (BuildContext context) => CameraPage(isBroadcast: false),
        '/broadcast': (BuildContext context) => const BroadCastPage(),
      },
      initialRoute: '/home',
    );
  }
}

//minSDKVersion is set to 20 however it can be changed