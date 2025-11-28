import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:lammah/core/utils/chat_string.dart';

class CallScreen extends StatefulWidget {
  final String appId;
  final String channelName;
  final bool isVideoCall;
  // يمكنك إضافة متغير token إذا كنت تستخدمه

  const CallScreen({
    super.key,
    required this.appId,
    required this.channelName,
    required this.isVideoCall,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late RtcEngine _engine;
  int? _remoteUid; // UID للمستخدم الآخر

  @override
  void initState() {
    super.initState();
    initializeAgora();
  }

  Future<void> initializeAgora() async {
    // إنشاء محرك Agora
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: widget.appId));

    // إضافة معالجات الأحداث
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint("Local user joined the channel");
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          debugPrint("Remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (connection, remoteUid, reason) {
          debugPrint("Remote user $remoteUid left");
          setState(() {
            _remoteUid = null;
          });
          Navigator.pop(context); // الخروج من المكالمة عند مغادرة الطرف الآخر
        },
      ),
    );

    // تفعيل الفيديو إذا كانت مكالمة فيديو
    if (widget.isVideoCall) {
      await _engine.enableVideo();
      await _engine.startPreview();
    } else {
      await _engine.enableAudio();
    }

    // الانضمام إلى القناة
    await _engine.joinChannel(
      token: ChatString.tokenCall, // ضع التوكن هنا إذا كنت تستخدمه
      channelId: widget.channelName,
      uid: 0, // 0 يعني أن Agora ستعين UID تلقائياً
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // عرض الفيديو
          Center(child: _buildVideoViews()),
          // أزرار التحكم (إنهاء المكالمة، كتم الصوت، ...)
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildVideoViews() {
    if (_remoteUid != null && widget.isVideoCall) {
      // عرض فيديو الطرفين
      return Stack(
        children: [
          // فيديو الطرف الآخر (ملء الشاشة)
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _engine,
              canvas: VideoCanvas(uid: _remoteUid),
              connection: RtcConnection(channelId: widget.channelName),
            ),
          ),
          // الفيديو الخاص بي (في زاوية الشاشة)
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              width: 100,
              height: 150,
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (widget.isVideoCall) {
      // عرض الفيديو الخاص بي فقط أثناء انتظر الطرف الآخر
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      // واجهة المكالمة الصوتية
      return Center(
        child: Text(
          _remoteUid == null ? "جاري الاتصال..." : "المكالمة جارية",
          style: const TextStyle(fontSize: 24),
        ),
      );
    }
  }

  Widget _buildControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 48.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.call_end),
        ),
      ),
    );
  }
}
