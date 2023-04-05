import 'package:flutter/material.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';
import 'package:network_info_plus/network_info_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        const SizedBox(
          height: 200,
        ),
        Container(
          color: Colors.black54,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
          ),
          child: const TextButton(
            onPressed: onPressed,
            child: Text("Scan"),
          ),
        ),
      ],
    ));
  }
}

void onPressed() async {
  final info = NetworkInfo();
  final wifiIP = await info.getWifiIP();
  print(wifiIP);
  const port = 443;
  final stream = NetworkAnalyzer.discover2(
    '110.61.5',
    port,
    timeout: const Duration(milliseconds: 5000),
  );

  int found = 0;
  stream.listen((NetworkAddress addr) {
    if (addr.exists) {
      found++;
      print('-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^');
      print('-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^');
      print('-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^');
      print('Found device: ${addr.ip}:$port');
    }
  });
}
