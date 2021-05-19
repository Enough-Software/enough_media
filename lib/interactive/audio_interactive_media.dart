import 'package:chewie_audio/chewie_audio.dart';
import 'package:enough_media/util/file_helper.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../enough_media.dart';
import '../media_provider.dart';

/// Displays simple audio player
class AudioInteractiveMedia extends StatefulWidget {
  final MediaProvider mediaProvider;
  AudioInteractiveMedia({
    Key? key,
    required this.mediaProvider,
  }) : super(key: key);

  @override
  _AudioInteractiveMediaState createState() => _AudioInteractiveMediaState();
}

class _AudioInteractiveMediaState extends State<AudioInteractiveMedia> {
  // late String _name;
  late VideoPlayerController _videoController;
  late ChewieAudioController _chewieController;
  late Future<ChewieAudioController> _loader;

  @override
  void initState() {
    super.initState();
    _loader = _loadAudio();
  }

  void dispose() {
    _videoController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  Future<ChewieAudioController> _loadAudio() async {
    final provider = widget.mediaProvider;
    if (provider is MemoryMediaProvider) {
      // first save the video to a file and then play it from there:
      final file = await FileHelper.saveAsFile(provider);
      _videoController = VideoPlayerController.file(file);
    } else if (provider is UrlMediaProvider) {
      _videoController = VideoPlayerController.network(provider.url);
    } else if (provider is AssetMediaProvider) {
      _videoController = VideoPlayerController.asset(provider.assetName);
    } else {
      throw StateError('Unsupported media provider $provider');
    }
    await _videoController.initialize();
    _chewieController = ChewieAudioController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,
    );
    return _chewieController;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChewieAudioController>(
      future: _loader,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return Center(child: CircularProgressIndicator());
          case ConnectionState.done:
            return _buildAudioPlayer();
        }
      },
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      color: Colors.black,
      child: Center(
        child: ChewieAudio(
          controller: _chewieController,
        ),
      ),
    );
  }
}
