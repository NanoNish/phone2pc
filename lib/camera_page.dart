import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:phone2pc/result.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/src/message.dart';
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
  final localVideoRenderer = RTCVideoRenderer();
  final remoteVideoRenderer = RTCVideoRenderer();
  bool _offer = false;
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  String? sendCandidate;
  String? sdpAnswer;

  //Handling of requests
  void scan() async {
    var sdpOffer = await _createOffer();
    peerConnection!.onIceCandidate = (e) async {
      if (e.candidate != null) {
        if (sendCandidate == null) {
          sendCandidate = json.encode({
            'candidate': e.candidate.toString(),
            'sdpMid': e.sdpMid.toString(),
            'sdpMlineIndex': e.sdpMLineIndex,
          });
          final http.Response response = await http.post(Uri.parse(widget.ip!),
              body: <String, String>{
                "sdpOffer": sdpOffer,
                "iceCandidate": sendCandidate!
              });
          print(response.body);
          sdpAnswer = response.body;
          _setRemoteDescription(sdpAnswer!);
        }
      }
    };
  }

  void broadcast() async {
    var handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addHandler(_echoRequest);
    var server = await shelf_io.serve(handler, widget.ip ?? 'localhost', 6969);
    print('Serving at http://${server.address.host}:${server.port}');
  }

  Future<shelf.Response> _echoRequest(shelf.Request request) async {
    var payload = await request.readAsString();
    var payloadMap = jsonDecode(payload);
    await _setRemoteDescription(payloadMap["sdpOffer"]);
    await _addCandidate(payloadMap["iceCandidate"]);
    var sdpAnswer = await _createAnswer();

    return shelf.Response.ok(sdpAnswer);
  }

  _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      }
    };

    MediaStream stream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);

    localVideoRenderer.srcObject = stream;
    return stream;
  }

  void _createPeerConnecion() async {
    Map<String, dynamic> configuration = {
      "sdpSemantics": "plan-b",
      "iceServers": [
        {},
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    localStream = await _getUserMedia();

    RTCPeerConnection pc =
        await createPeerConnection(configuration, offerSdpConstraints);

    for (var track in localStream!.getTracks()) {
      pc.addTrack(track);
    }

    pc.onIceConnectionState = (e) {
      print(e);
    };

    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
      remoteVideoRenderer.srcObject = stream;
    };

    peerConnection = pc;
    if (widget.isBroadcast ?? true) {
      broadcast();
    } else {
      scan();
    }
  }

  Future<String> _createOffer() async {
    RTCSessionDescription description =
        await peerConnection!.createOffer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp.toString());
    print(json.encode(session));
    _offer = true;

    peerConnection!.setLocalDescription(description);
    return json.encode(session);
  }

  Future<String> _createAnswer() async {
    RTCSessionDescription description =
        await peerConnection!.createAnswer({'offerToReceiveVideo': 1});

    var session = parse(description.sdp.toString());
    print(json.encode(session));

    peerConnection!.setLocalDescription(description);
    return json.encode(session);
  }

  Future<void> _setRemoteDescription(String jsonString) async {
    dynamic session = jsonDecode(jsonString);

    String sdp = write(session, null);

    RTCSessionDescription description =
        RTCSessionDescription(sdp, _offer ? 'answer' : 'offer');
    print(description.toMap());

    await peerConnection!.setRemoteDescription(description);
  }

  Future<void> _addCandidate(String jsonString) async {
    dynamic session = jsonDecode(jsonString);
    print(session['candidate']);
    dynamic candidate = RTCIceCandidate(
        session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
    await peerConnection!.addCandidate(candidate);
  }

  initRenderer() async {
    await localVideoRenderer.initialize();
    await remoteVideoRenderer.initialize();
  }

  @override
  void initState() {
    initRenderer();
    _createPeerConnecion();
    super.initState();
  }

  SizedBox videoRenderers() => SizedBox(
        height: 210,
        child: Row(children: [
          Flexible(
            child: Container(
              key: const Key('local'),
              margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              decoration: const BoxDecoration(color: Colors.black),
              child: RTCVideoView(localVideoRenderer),
            ),
          ),
          Flexible(
            child: Container(
              key: const Key('remote'),
              margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              decoration: const BoxDecoration(color: Colors.black),
              child: RTCVideoView(remoteVideoRenderer),
            ),
          ),
        ]),
      );

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
          videoRenderers(),
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
