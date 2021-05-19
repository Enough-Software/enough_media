import 'package:chewie/chewie.dart';
import 'package:enough_media/util/file_helper.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../media_provider.dart';

class VideoInteractiveMedia extends StatefulWidget {
  final MediaProvider mediaProvider;
  VideoInteractiveMedia({Key? key, required this.mediaProvider})
      : super(key: key);

  @override
  _VideoInteractiveMediaState createState() => _VideoInteractiveMediaState();
}

class _VideoInteractiveMediaState extends State<VideoInteractiveMedia> {
  late VideoPlayerController _videoController;
  late ChewieController _chewieController;
  late Future<VideoPlayerController> _loader;

  @override
  void initState() {
    super.initState();
    _loader = _loadVideo();
  }

  void dispose() {
    _videoController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  Future<VideoPlayerController> _loadVideo() async {
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
    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,
      // Try playing around with some of these other options:

      // showControls: false,
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),
      // placeholder: Container(
      //   color: Colors.grey,
      // ),
      // autoInitialize: true,
    );
    //_videoController.addListener(() => setState(() {}));
    return _videoController;
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
          case ConnectionState.done:
            return _buildVideo();
        }
      },
    );
  }

  Widget _buildVideo() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Chewie(
          controller: _chewieController,
        ),
      ),
    );
  }
}
