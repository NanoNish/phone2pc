import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:phone2pc/scan_page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
// import 'package:ip_geolocation_api/ip_geolocation_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? ip;
  String? scannedIP;
  bool serverRunning = false;
  HttpServer? server;

  @override
  void initState() {
    super.initState();
  }

  Future<String> getIP() async {
    // final response = await http.get(
    //   Uri.parse('https://api.ipify.org'),
    // );
    // print(response.body);
    // return response.body;
    final info = NetworkInfo();
    String? wifiIP = await info.getWifiIP();
    print(wifiIP);
    return wifiIP!;
  }

  void scan() async {
    final response = await sendOffer("title");
    print(response);
  }

  Future<http.Response> sendOffer(String title) {
    return http.get(
      Uri.parse('http://$scannedIP:6969'),
    );
  }

  void broadcast() async {
    if (serverRunning) return;
    final tempIP = await getIP();
    final tempServer = await HttpServer.bind(InternetAddress.anyIPv6, 6969);
    setState(() {
      ip = tempIP;
      server ??= tempServer;
      if (server != null) serverRunning = true;
    });
    await server!.forEach((HttpRequest request) {
      request.response.write('Hello, world!');
      request.response.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 100,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
          ),
          child: TextButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScanPage(),
                ),
              );
              setState(() {
                scannedIP = result;
              });
              scan();
            },
            child: const Text("Scan"),
          ),
        ),
        const SizedBox(
          height: 100,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
          ),
          child: TextButton(
            onPressed: broadcast,
            child: const Text("Broadcast"),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
          ),
          child: (ip == null
              ? const SizedBox(
                  height: 0,
                )
              : QrImage(
                  data: ip!,
                  version: QrVersions.auto,
                  size: 200.0,
                )),
        ),
      ],
    ));
  }
}
