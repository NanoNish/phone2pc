import 'package:flutter/material.dart';
// import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:bonsoir/bonsoir.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? ip;

  @override
  void initState() {
    super.initState();
  }

  Future<String> getIP() async {
    final info = NetworkInfo();
    String? wifiIP = await info.getWifiIP();
    return wifiIP!;
  }

  void scan() {}

  void broadcast() async {
    final tempIP = await getIP();
    setState(() {
      ip = tempIP;
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
            onPressed: scan,
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
                  ))),
      ],
    ));
  }
}
