import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:io';

class BroadCastPage extends StatefulWidget {
  const BroadCastPage({super.key});

  @override
  State<BroadCastPage> createState() => _BroadCastPageState();
}

class _BroadCastPageState extends State<BroadCastPage> {
  String? ip;
  bool serverRunning = false;
  HttpServer? server;

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
  void initState() {
    broadcast();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Periscope",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: broadcast,
        child: const Icon(
          Icons.refresh,
        ),
      ),
    );
  }
}
