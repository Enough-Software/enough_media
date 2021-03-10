import 'package:enough_media/media_provider.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

/// Displays zoomable images
class ImageInteractiveMedia extends StatelessWidget {
  final MediaProvider mediaProvider;
  const ImageInteractiveMedia({Key? key, required this.mediaProvider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PhotoView(
      imageProvider: toImageProvider(mediaProvider),
      basePosition: Alignment.center,
    );
  }

  static ImageProvider toImageProvider(MediaProvider provider) {
    if (provider is MemoryMediaProvider) {
      return MemoryImage(provider.data);
    } else if (provider is UrlMediaProvider) {
      return NetworkImage(provider.url);
    } else if (provider is AssetMediaProvider) {
      return AssetImage(provider.assetName);
    } else {
      throw StateError('Unsupported media provider $provider');
    }
  }
}
