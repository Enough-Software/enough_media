import 'package:enough_media/enough_media.dart';
import 'package:enough_media/media_provider.dart';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final MediaProvider mediaProvider;
  final BoxFit fit;
  final double width;
  final double height;
  const ImagePreview(
      {Key key,
      @required this.mediaProvider,
      this.fit = BoxFit.cover,
      this.width,
      this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageProvider = ImageInteractiveMedia.toImageProvider(mediaProvider);
    return Image(
      image: imageProvider,
      fit: fit,
      width: width,
      height: height,
    );
  }
}
