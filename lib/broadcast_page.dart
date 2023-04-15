import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:network_info_plus/network_info_plus.dart';
import './result.dart';

class BroadCastPage extends StatefulWidget {
  const BroadCastPage({super.key});

  @override
  State<BroadCastPage> createState() => _BroadCastPageState();
}

class _BroadCastPageState extends State<BroadCastPage> {
  String? ip;

  void broadcast() async {
    final tempIP = await getIP();
    setState(() {
      ip = tempIP;
    });
  }

  Future<String> getIP() async {
    final info = NetworkInfo();
    String? wifiIP = await info.getWifiIP();
    print(wifiIP);
    return wifiIP!;
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
        onPressed: () =>
            Navigator.pushReplacementNamed(context, '/camera', arguments: Result(ip, true)),
        child: const Icon(
          Icons.refresh,
        ),
      ),
    );
  }
}
