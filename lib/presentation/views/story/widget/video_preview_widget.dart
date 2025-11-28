import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class VideoPreviewWidget extends StatefulWidget {
  final File videoFile;
  const VideoPreviewWidget({super.key, required this.videoFile});

  @override
  State<VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {}); // تحديث الواجهة عند انتهاء التحميل
        _controller.play(); // تشغيل تلقائي
        _controller.setLooping(true); // تكرار
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Center(child: CircularProgressIndicator());
  }
}
