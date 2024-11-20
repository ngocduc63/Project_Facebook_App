import 'dart:async';

import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/controllers/socket_controller.dart';
import 'package:facebook/models/user_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallScreen extends StatefulWidget {
  final String callerId, calleeId;
  final UserModel userInfo;
  final dynamic offer;
  const CallScreen({
    super.key,
    this.offer,
    required this.callerId,
    required this.calleeId,
    required this.userInfo,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final socket = SocketController.instance.getSocket();
  final _localRTCVideoRenderer = RTCVideoRenderer();
  final _remoteRTCVideoRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  RTCPeerConnection? _rtcPeerConnection;
  List<RTCIceCandidate> rtcIceCandidates = [];
  bool isAudioOn = true, isVideoOn = true, isFrontCameraSelected = true;

  bool _isLocalRendererDisposed = false;
  bool _isRemoteRendererDisposed = false;

  bool isControlsVisible = false;
  Timer? _hideControlsTimer;
  double _smallVideoTop = 20;
  double _startTop = 20;
  double _smallVideoLeft = 20;
  double _startLeft = 20;

  @override
  void initState() {
    super.initState();
    _localRTCVideoRenderer.initialize();
    _remoteRTCVideoRenderer.initialize();
    _setupPeerConnection();
    _toggleControls();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _toggleControls() {
    setState(() {
      isControlsVisible = !isControlsVisible;
    });

    if (isControlsVisible) {
      _hideControlsTimer?.cancel();

      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        setState(() {
          isControlsVisible = false;
        });
      });
    }
  }

  _setupPeerConnection() async {
    try {
      _rtcPeerConnection = await createPeerConnection({
        'iceServers': [
          {
            'urls': [
              'stun:stun1.l.google.com:19302',
              'stun:stun2.l.google.com:19302'
            ]
          }
        ]
      });

      if (_rtcPeerConnection == null) {
        throw Exception("Failed to create RTC Peer Connection");
      }

      // Listen for remote media tracks
      _rtcPeerConnection!.onTrack = (event) {
        if (!_isRemoteRendererDisposed && event.streams.isNotEmpty) {
          _remoteRTCVideoRenderer.srcObject = event.streams[0];
          setState(() {});
        }
      };

      // Get local media stream
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': isAudioOn,
        'video': isVideoOn
            ? {'facingMode': isFrontCameraSelected ? 'user' : 'environment'}
            : false,
      });

      if (_localStream != null) {
        // Add local tracks to peer connection
        _localStream!.getTracks().forEach((track) {
          _rtcPeerConnection?.addTrack(track, _localStream!);
        });

        // Set local video renderer
        if (!_isLocalRendererDisposed) {
          _localRTCVideoRenderer.srcObject = _localStream;
        }
        setState(() {});
      }

      // Handle incoming call
      if (widget.offer != null) {
        _handleIncomingCall();
      } else {
        _handleOutgoingCall();
      }

      socket!.on('end_call_noti', (_) {
        _leaveCall(true);
      });
    } catch (e) {
      print("Error in setting up peer connection: $e");
    }
  }

  _handleIncomingCall() async {
    if (_rtcPeerConnection == null) return;

    // Listen for remote Ice Candidates
    socket!.on("IceCandidate", (data) {
      if (_rtcPeerConnection != null) {
        _rtcPeerConnection!.addCandidate(RTCIceCandidate(
          data["iceCandidate"]["candidate"],
          data["iceCandidate"]["id"],
          data["iceCandidate"]["label"],
        ));
      }
    });

    // Set remote description
    await _rtcPeerConnection!.setRemoteDescription(
      RTCSessionDescription(widget.offer["sdp"], widget.offer["type"]),
    );

    // Create and send answer
    RTCSessionDescription answer = await _rtcPeerConnection!.createAnswer();
    await _rtcPeerConnection!.setLocalDescription(answer);

    socket!.emit("answerCall", {
      "callerId": widget.callerId,
      "sdpAnswer": answer.toMap(),
    });
  }

  _handleOutgoingCall() async {
    if (_rtcPeerConnection == null) return;

    // Collect ICE Candidates
    _rtcPeerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      rtcIceCandidates.add(candidate);
    };

    // Handle call answered
    socket!.on("callAnswered", (data) async {
      if (_rtcPeerConnection == null) return;

      await _rtcPeerConnection!.setRemoteDescription(
        RTCSessionDescription(
          data["sdpAnswer"]["sdp"],
          data["sdpAnswer"]["type"],
        ),
      );

      // Send collected ICE Candidates
      for (RTCIceCandidate candidate in rtcIceCandidates) {
        socket!.emit("IceCandidate", {
          "calleeId": widget.calleeId,
          "iceCandidate": {
            "id": candidate.sdpMid,
            "label": candidate.sdpMLineIndex,
            "candidate": candidate.candidate,
          }
        });
      }
    });

    // Create and send offer
    RTCSessionDescription offer = await _rtcPeerConnection!.createOffer();
    await _rtcPeerConnection!.setLocalDescription(offer);

    socket!.emit('makeCall', {
      "calleeId": widget.calleeId,
      "sdpOffer": offer.toMap(),
    });
  }

  _leaveCall(bool isEnd) {
    if (!isEnd) {
      String currentUserId = UserServicePref.instance.getUserInfo.id;
      String to =
          widget.calleeId == currentUserId ? widget.callerId : widget.calleeId;
      socket!.emit('end_call', {"calleeId": to});
    }
    _rtcPeerConnection?.close();
    Navigator.pop(context);
  }

  _toggleMic() {
    isAudioOn = !isAudioOn;
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = isAudioOn;
    });
    setState(() {});
  }

  _toggleCamera() {
    isVideoOn = !isVideoOn;
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = isVideoOn;
    });
    setState(() {});
  }

  _switchCamera() {
    isFrontCameraSelected = !isFrontCameraSelected;
    _localStream?.getVideoTracks().forEach((track) {
      Helper.switchCamera(track);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                  '${ApiConfig.linkImage}${widget.userInfo.avatar}'),
            ),
            const SizedBox(width: 10),
            Text(
              widget.userInfo.name,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteColor),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.lightBlueColor,
      ),
      body: GestureDetector(
        onTap: _toggleControls,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Video chính
            RTCVideoView(
              _remoteRTCVideoRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
            // Video nhỏ
            Positioned(
              top: _smallVideoTop,
              left: _smallVideoLeft,
              child: GestureDetector(
                onPanStart: (details) {
                  _startTop = _smallVideoTop;
                  _startLeft = _smallVideoLeft;
                },
                onPanUpdate: (details) {
                  setState(() {
                    _smallVideoTop = _startTop + details.localPosition.dy - 75;
                    _smallVideoLeft =
                        _startLeft + details.localPosition.dx - 60;

                    if (_smallVideoTop < 0) _smallVideoTop = 0;
                    if (_smallVideoLeft < 0) _smallVideoLeft = 0;
                    if (_smallVideoTop >
                        MediaQuery.of(context).size.height - 250) {
                      _smallVideoTop = MediaQuery.of(context).size.height - 250;
                    }
                    if (_smallVideoLeft >
                        MediaQuery.of(context).size.width - 120) {
                      _smallVideoLeft = MediaQuery.of(context).size.width - 120;
                    }
                  });
                },
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 150,
                      width: 120,
                      child: RTCVideoView(
                        _localRTCVideoRenderer,
                        mirror: isFrontCameraSelected,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    )),
              ),
            ),

            // Các nút điều khiển
            if (isControlsVisible)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildControlButton(
                      icon: isAudioOn ? Icons.mic : Icons.mic_off,
                      onPressed: _toggleMic,
                    ),
                    _buildControlButton(
                      icon: Icons.call_end,
                      onPressed: () => _leaveCall(false),
                      backgroundColor: Colors.red,
                    ),
                    _buildControlButton(
                      icon: Icons.cameraswitch,
                      onPressed: _switchCamera,
                    ),
                    _buildControlButton(
                      icon: isVideoOn ? Icons.videocam : Icons.videocam_off,
                      onPressed: _toggleCamera,
                      backgroundColor: const Color.fromARGB(255, 6, 189, 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.blue,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  @override
  void dispose() {
    _isLocalRendererDisposed = true;
    _isRemoteRendererDisposed = true;
    _localRTCVideoRenderer.dispose();
    _remoteRTCVideoRenderer.dispose();
    _localStream?.dispose();
    _rtcPeerConnection?.dispose();
    _hideControlsTimer?.cancel();
    _leaveCall(false);
    socket?.off('end_call');
    super.dispose();
  }
}
