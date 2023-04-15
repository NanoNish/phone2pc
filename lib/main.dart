import 'package:flutter/material.dart';
import 'package:phone2pc/broadcast_page.dart';
import 'package:phone2pc/camera_page.dart';
import 'package:phone2pc/home_page.dart';
import 'package:phone2pc/scan_page.dart';
import 'package:phone2pc/result.dart';

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
        '/broadcast': (BuildContext context) => const BroadCastPage(),
        '/camera': (BuildContext context) {
          final Result args =
              ModalRoute.of(context)!.settings.arguments as Result;
          return CameraPage(ip: args.ip, isBroadcast: args.isBroadcast);
        },
      },
      initialRoute: '/home',
    );
  }
}

//minSDKVersion is set to 20 however it can be changed