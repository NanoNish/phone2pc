import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:phone2pc/result.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:sdp_transform/sdp_transform.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class CameraPage extends StatefulWidget {
  CameraPage({Key? key, this.ip, this.isBroadcast}) : super(key: key);

  final String? ip;
  final bool? isBroadcast;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  void scan() async {}

  void broadcast() async {
    var handler =
        const Pipeline().addMiddleware(logRequests()).addHandler(_echoRequest);
    var server = await shelf_io.serve(handler, widget.ip ?? 'localhost', 6969);
    print('Serving at http://${server.address.host}:${server.port}');
  }

  Response _echoRequest(Request request) =>
      Response.ok('Request for "${request.url}"');

  @override
  void initState() {
    if (widget.isBroadcast ?? true) {
      broadcast();
    } else {
      scan();
    }
    super.initState();
  }

  // SizedBox videoRenderers() => SizedBox(
  //       height: 210,
  //       child: Row(children: [
  //         Flexible(
  //           child: Container(
  //             key: const Key('local'),
  //             margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
  //             decoration: const BoxDecoration(color: Colors.black),
  //             child: RTCVideoView(_localVideoRenderer),
  //           ),
  //         ),
  //         Flexible(
  //           child: Container(
  //             key: const Key('remote'),
  //             margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
  //             decoration: const BoxDecoration(color: Colors.black),
  //             child: RTCVideoView(_remoteVideoRenderer),
  //           ),
  //         ),
  //       ]),
  //     );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Periscope",
        ),
      ),
      body: Column(
        children: [
          // videoRenderers(),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: TextField(
                    // controller: sdpController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    maxLength: TextField.noMaxLength,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Offer"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Answer"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Set Remote Description"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Set Candidate"),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
