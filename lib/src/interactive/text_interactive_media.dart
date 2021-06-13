import 'dart:convert';

import 'package:enough_media/enough_media.dart';
import 'package:flutter/material.dart';

/// Displays texts
class TextInteractiveMedia extends StatelessWidget {
  final MediaProvider mediaProvider;

  const TextInteractiveMedia({Key? key, required this.mediaProvider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      // required for Hero transition
      type: MaterialType.transparency,
      child: SelectableText(
        toText(mediaProvider),
      ),
    );
  }

  static String toText(MediaProvider mediaProvider) {
    if (mediaProvider is TextMediaProvider) {
      return mediaProvider.text;
    }
    if (mediaProvider is MemoryMediaProvider) {
      return utf8.decode(mediaProvider.data);
    }
    return '${mediaProvider.name}: Unsupported MediaProvider $mediaProvider';
  }
}
