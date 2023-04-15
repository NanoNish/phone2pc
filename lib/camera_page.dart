import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:phone2pc/result.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class CameraPage extends StatefulWidget {
  CameraPage({Key? key, required this.isBroadcast}) : super(key: key);

  String? ip = "10.61.23.205";
  final bool isBroadcast;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class SDP {
  String offer;

  SDP({
    required this.offer,
  });
}

class _CameraPageState extends State<CameraPage> {
  String? ip;
  bool serverRunning = false;
  HttpServer? server;
  var iceCandidate;

  final _localVideoRenderer = RTCVideoRenderer();
  final _remoteVideoRenderer = RTCVideoRenderer();
  final sdpController = TextEditingController();

  bool _offer = false;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  void scan() async {
    final sdpOffer = await _createOffer();
    final response = await sendOffer(sdpOffer);
    _setRemoteDescription(response.headers["sdpAnswer"]!);
    _addCandidate(response.headers["candidate"]!);
  }

  void broadcast() async {
    final tempServer = await HttpServer.bind(InternetAddress.anyIPv6, 6969);
    setState(() {
      server ??= tempServer;
      if (server != null) serverRunning = true;
    });
    await server!.forEach((HttpRequest request) async {
      print(request.headers["sdpOffer"]);
      _setRemoteDescription(request.headers["sdpOffer"]!.first);
      // String data = await utf8.decoder.bind(request).join();
      // debugPrint(data);

      request.response.headers.add("sdpOffer", await _createOffer());
      request.response.headers.add("candidate", iceCandidate);

      request.response.close();
    });
  }

  Future<http.Response> sendOffer(String sdpOffer) {
    print(sdpOffer);
    return http.post(
      Uri.parse('http://$ip:6969'),
      headers: <String, String>{
        "sdpOffer": sdpOffer,
      },
      // body: SDP(offer: sdpOffer),
    );
  }

  initRenderer() async {
    await _localVideoRenderer.initialize();
    await _remoteVideoRenderer.initialize();
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

    _localVideoRenderer.srcObject = stream;
    return stream;
  }

  _createPeerConnecion() async {
    Map<String, dynamic> configuration = {};

    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    _localStream = await _getUserMedia();

    RTCPeerConnection pc =
        await createPeerConnection(configuration, offerSdpConstraints);

    pc.addStream(_localStream!);

    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        setState(() {
          iceCandidate ??= json.encode({
            'candidate': e.candidate.toString(),
            'sdpMid': e.sdpMid.toString(),
            'sdpMlineIndex': e.sdpMLineIndex,
          });
        });
        print(json.encode({
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMLineIndex,
        }));
      }
    };

    pc.onIceConnectionState = (e) {
      print(e);
    };

    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
      _remoteVideoRenderer.srcObject = stream;
    };

    return pc;
  }

  Future<String> _createOffer() async {
    RTCSessionDescription description =
        await _peerConnection!.createOffer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp.toString());
    print(json.encode(session));
    _offer = true;

    _peerConnection!.setLocalDescription(description);
    return json.encode(session);
  }

  Future<String> _createAnswer() async {
    RTCSessionDescription description =
        await _peerConnection!.createAnswer({'offerToReceiveVideo': 1});

    var session = parse(description.sdp.toString());
    print(json.encode(session));

    _peerConnection!.setLocalDescription(description);
    return json.encode(session);
  }

  void _setRemoteDescription(String sdpDesc) async {
    String jsonString = sdpDesc;
    dynamic session = await jsonDecode(jsonString);

    String sdp = write(session, null);

    RTCSessionDescription description =
        RTCSessionDescription(sdp, _offer ? 'answer' : 'offer');
    print(description.toMap());

    await _peerConnection!.setRemoteDescription(description);
  }

  void _addCandidate(String candid) async {
    String jsonString = candid;
    dynamic session = await jsonDecode(jsonString);
    print(session['candidate']);
    dynamic candidate = RTCIceCandidate(
        session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
    await _peerConnection!.addCandidate(candidate);
  }

  @override
  void initState() {
    initRenderer();
    _createPeerConnecion().then((pc) {
      _peerConnection = pc;
    });
    if (widget.isBroadcast) {
      broadcast();
    } else {
      scan();
    }
    // _getUserMedia();
    super.initState();
  }

  @override
  void dispose() async {
    await _localVideoRenderer.dispose();
    sdpController.dispose();
    super.dispose();
  }

  SizedBox videoRenderers() => SizedBox(
        height: 210,
        child: Row(children: [
          Flexible(
            child: Container(
              key: const Key('local'),
              margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              decoration: const BoxDecoration(color: Colors.black),
              child: RTCVideoView(_localVideoRenderer),
            ),
          ),
          Flexible(
            child: Container(
              key: const Key('remote'),
              margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              decoration: const BoxDecoration(color: Colors.black),
              child: RTCVideoView(_remoteVideoRenderer),
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
                    controller: sdpController,
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
                    onPressed: _createOffer,
                    child: const Text("Offer"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: _createAnswer,
                    child: const Text("Answer"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () => _setRemoteDescription,
                    child: const Text("Set Remote Description"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () => _addCandidate,
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
