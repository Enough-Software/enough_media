import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart' as pp;
import '../media_provider.dart';

class VideoInteractiveMedia extends StatefulWidget {
  final MediaProvider mediaProvider;
  VideoInteractiveMedia({Key key, this.mediaProvider}) : super(key: key);

  @override
  _VideoInteractiveMediaState createState() => _VideoInteractiveMediaState();
}

class _VideoInteractiveMediaState extends State<VideoInteractiveMedia> {
  VideoPlayerController _controller;
  Future<VideoPlayerController> _loader;

  @override
  void initState() {
    super.initState();
    _loader = loadVideo();
  }

  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<VideoPlayerController> loadVideo() async {
    final provider = widget.mediaProvider;
    if (provider is MemoryMediaProvider) {
      // first save the video to a file and then play it from there:
      final directory = await pp.getTemporaryDirectory();
      final file = File('${directory.path}/${provider.name}');
      await file.writeAsBytes(provider.data, flush: true);
      _controller = VideoPlayerController.file(file);
    } else if (provider is UrlMediaProvider) {
      _controller = VideoPlayerController.network(provider.url);
    } else if (provider is AssetMediaProvider) {
      _controller = VideoPlayerController.asset(provider.assetName);
    } else {
      throw StateError('Unsupported media provider $provider');
    }
    await _controller.initialize();
    await _controller.play();
    _controller.addListener(() => setState(() {}));
    return _controller;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VideoPlayerController>(
      future: _loader,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return Center(child: CircularProgressIndicator());
            break;
          case ConnectionState.done:
            return buildVideo();
            break;
        }
        return Text('loading video...');
      },
    );
  }

  Widget buildVideo() {
    return Container(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              VideoPlayer(_controller),
              _ControlsOverlay(controller: _controller),
              VideoProgressIndicator(_controller, allowScrubbing: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key key, this.controller}) : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : play();
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }

  void play() async {
    final position = controller.value.position;
    if (position == controller.value.duration) {
      await controller.seekTo(Duration.zero);
    }
    await controller.play();
  }
}
