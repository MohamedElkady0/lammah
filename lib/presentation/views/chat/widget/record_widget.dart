import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final int durationInMillis;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    required this.durationInMillis,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _player.setUrl(widget.audioUrl);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // دالة لتحويل المدة إلى تنسيق 01:23
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
              return const CircularProgressIndicator(color: Colors.white);
            }
            return IconButton(
              icon: Icon(
                playing == true ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: () {
                playing == true ? _player.pause() : _player.play();
              },
            );
          },
        ),
        Expanded(
          child: StreamBuilder<Duration>(
            stream: _player.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = Duration(milliseconds: widget.durationInMillis);
              return Slider(
                value: position.inMilliseconds.toDouble().clamp(
                  0.0,
                  duration.inMilliseconds.toDouble(),
                ),
                min: 0.0,
                max: duration.inMilliseconds.toDouble(),
                onChanged: (value) {
                  _player.seek(Duration(milliseconds: value.toInt()));
                },
                activeColor: Colors.white,
                inactiveColor: Colors.grey,
              );
            },
          ),
        ),
        Text(
          _formatDuration(Duration(milliseconds: widget.durationInMillis)),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
