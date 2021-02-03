import 'dart:io';

import 'package:chewie/chewie.dart';
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
  VideoPlayerController _videoController;
  ChewieController _chewieController;
  Future<VideoPlayerController> _loader;

  @override
  void initState() {
    super.initState();
    _loader = loadVideo();
  }

  void dispose() {
    if (_videoController != null) {
      _videoController.dispose();
      _chewieController.dispose();
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
        child: Chewie(
          controller: _chewieController,
        ),
      ),
    );
  }
}
