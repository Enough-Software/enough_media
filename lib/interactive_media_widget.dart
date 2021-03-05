import 'package:enough_media/enough_media.dart';
import 'package:enough_media/media_provider.dart';
import 'package:enough_media/widget_registry.dart';
import 'package:flutter/material.dart';

class InteractiveMediaWidget extends StatelessWidget {
  final MediaProvider mediaProvider;
  final bool useRegistry;
  final Object heroTag;
  const InteractiveMediaWidget({
    Key key,
    @required this.mediaProvider,
    this.useRegistry = false,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (heroTag != null) {
      return Hero(tag: heroTag, child: _buildMedia());
    }
    return _buildMedia();
  }

  Widget _buildMedia() {
    final provider = mediaProvider;
    if (useRegistry) {
      final registry = WidgetRegistry();
      if (registry.resolveInteractive != null) {
        final resolved = registry.resolveInteractive(provider);
        if (resolved != null) {
          return resolved;
        }
      }
      final mimeTypeResolver = registry.interactiveRegistry[provider.mediaType];
      if (mimeTypeResolver != null) {
        return mimeTypeResolver(provider);
      }
    }
    if (provider.isImage) {
      return ImageInteractiveMedia(mediaProvider: provider);
    } else if (mediaProvider.mediaType == 'application/pdf') {
      return PdfInteractiveMedia(mediaProvider: provider);
    } else if (mediaProvider.isAudio) {
      return AudioInteractiveMedia(mediaProvider: provider);
    } else if (mediaProvider.isVideo) {
      return VideoInteractiveMedia(mediaProvider: provider);
    } else if (provider is TextMediaProvider) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Material(
          // required for Hero transition
          type: MaterialType.transparency,
          child: SelectableText(provider.text),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Material(
          // required for Hero transition
          type: MaterialType.transparency,
          child: SelectableText('${provider.name}:\n'
              'Unsupported content with mime type ${provider.mediaType}'),
        ),
      );
    }
  }
}
