import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class SourcePage extends StatefulWidget {
  const SourcePage({super.key});

  @override
  State<SourcePage> createState() => _SourcePageState();
}

class _SourcePageState extends State<SourcePage> {
  RTCPeerConnection? connection;
  RTCSessionDescription? offer;

  void call() async {}

  @override
  void initState() async {
    connection = await createPeerConnection({});
    await connection!.createOffer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
