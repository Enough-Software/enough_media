import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';

import '../media_provider.dart';

/// Displays simple audio player
class AudioInteractiveMedia extends StatefulWidget {
  final MediaProvider mediaProvider;
  AudioInteractiveMedia({
    Key key,
    @required this.mediaProvider,
  }) : super(key: key);

  @override
  _AudioInteractiveMediaState createState() => _AudioInteractiveMediaState();
}

class _AudioInteractiveMediaState extends State<AudioInteractiveMedia> {
  String name;
  FlutterSoundPlayer audioPlayer;
  Track track;

  @override
  void initState() {
    final provider = widget.mediaProvider;
    name = provider.name ?? '<unknown>';
    if (provider is MemoryMediaProvider) {
      track = Track(dataBuffer: provider.data, trackTitle: name);
    } else if (provider is UrlMediaProvider) {
      track = Track(trackPath: provider.url, trackTitle: name);
    } else if (provider is AssetMediaProvider) {
      track = Track(trackPath: provider.assetName, trackTitle: name);
    } else {
      throw StateError('Unsupported media provider $provider');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(name),
          ),
          SoundPlayerUI.fromTrack(track),
        ],
      ),
    );
  }
}
