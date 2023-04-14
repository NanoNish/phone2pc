import 'package:flutter/material.dart';
// import 'package:ip_geolocation_api/ip_geolocation_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
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
                onPressed: () => Navigator.pushReplacementNamed(context, '/scan'),
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
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/broadcast'),
                child: const Text("Broadcast"),
              ),
            ),
          ],
        ));
  }
}
