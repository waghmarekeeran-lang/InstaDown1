import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_colors.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String filePath;
  const VideoPlayerScreen({super.key, required this.filePath});
  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _ctrl;
  bool _showCtrl = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _init();
  }

  Future<void> _init() async {
    if (widget.filePath.isEmpty) return;
    final file = File(widget.filePath);
    if (!file.existsSync()) return;
    final ctrl = VideoPlayerController.file(file);
    await ctrl.initialize();
    ctrl.setLooping(false);
    ctrl.play();
    setState(() { _ctrl = ctrl; _initialized = true; });
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showCtrl = !_showCtrl),
        child: Stack(fit: StackFit.expand, children: [
          _initialized && _ctrl != null
              ? Center(child: AspectRatio(aspectRatio: _ctrl!.value.aspectRatio, child: VideoPlayer(_ctrl!)))
              : const Center(child: CircularProgressIndicator(color: Colors.white)),
          AnimatedOpacity(
            opacity: _showCtrl ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: _Controls(ctrl: _ctrl, onClose: () => Navigator.pop(context)),
          ),
        ]),
      ),
    );
  }
}

class _Controls extends StatefulWidget {
  final VideoPlayerController? ctrl;
  final VoidCallback onClose;
  const _Controls({required this.ctrl, required this.onClose});
  @override State<_Controls> createState() => _ControlsState();
}

class _ControlsState extends State<_Controls> {
  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;
    final playing = ctrl?.value.isPlaying ?? false;
    final pos = ctrl?.value.position ?? Duration.zero;
    final dur = ctrl?.value.duration ?? Duration.zero;
    final prog = dur.inMilliseconds > 0 ? pos.inMilliseconds / dur.inMilliseconds : 0.0;

    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 3,
          activeTrackColor: AppColors.progressAmber,
          inactiveTrackColor: Colors.white30,
          thumbColor: AppColors.progressAmber,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
        ),
        child: Slider(
          value: prog.clamp(0.0, 1.0),
          onChanged: (v) {
            if (dur.inMilliseconds > 0) {
              ctrl?.seekTo(Duration(milliseconds: (v * dur.inMilliseconds).toInt()));
            }
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            IconButton(icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 32), onPressed: () { setState(() { playing ? ctrl?.pause() : ctrl?.play(); }); }),
            IconButton(icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 26), onPressed: () => ctrl?.seekTo(Duration.zero)),
            IconButton(icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 26), onPressed: () {}),
          ]),
          Row(children: [
            IconButton(icon: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 24), onPressed: () {}),
            IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 24), onPressed: widget.onClose),
          ]),
        ]),
      ),
    ]);
  }
}
