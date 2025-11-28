import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final int durationInMillis;
  final Color contentColor; // 1. إضافة متغير للون (أبيض أو أسود)

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    required this.durationInMillis,
    this.contentColor = Colors.white, // الافتراضي أبيض
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // استخدام try-catch لتجنب توقف التطبيق إذا كان الرابط تالفاً
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _player.setUrl(widget.audioUrl);
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;

            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: widget.contentColor,
                  strokeWidth: 2,
                ),
              );
            }

            // 2. التحقق مما إذا انتهى المقطع لإظهار زر التشغيل مرة أخرى
            bool isCompleted = processingState == ProcessingState.completed;

            return IconButton(
              icon: Icon(
                (playing == true && !isCompleted)
                    ? Icons.pause
                    : Icons.play_arrow,
                color: widget.contentColor,
              ),
              onPressed: () {
                if (isCompleted) {
                  _player.seek(Duration.zero); // إعادة للبداية
                  _player.play();
                } else {
                  playing == true ? _player.pause() : _player.play();
                }
              },
            );
          },
        ),
        Expanded(
          child: StreamBuilder<Duration>(
            stream: _player.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              // التأكد من أن المدة لا تساوي صفر لتجنب القسمة على صفر
              final totalDuration = widget.durationInMillis > 0
                  ? widget.durationInMillis.toDouble()
                  : 1.0;

              return Slider(
                value: position.inMilliseconds.toDouble().clamp(
                  0.0,
                  totalDuration,
                ),
                min: 0.0,
                max: totalDuration,
                onChanged: (value) {
                  _player.seek(Duration(milliseconds: value.toInt()));
                },
                activeColor: widget.contentColor,
                inactiveColor: widget.contentColor.withAlpha(300),
              );
            },
          ),
        ),
        Text(
          _formatDuration(Duration(milliseconds: widget.durationInMillis)),
          style: TextStyle(color: widget.contentColor, fontSize: 12),
        ),
      ],
    );
  }
}
