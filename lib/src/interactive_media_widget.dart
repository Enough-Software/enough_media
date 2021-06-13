import 'package:enough_media/enough_media.dart';
import 'package:flutter/material.dart';

/// Wraps any supported media into an interactive widget.
class InteractiveMediaWidget extends StatelessWidget {
  /// The provider for the media to be shown
  final MediaProvider mediaProvider;
  final Object? heroTag;
  final Widget Function(BuildContext context, MediaProvider mediaProvider)?
      fallbackBuilder;

  /// Creates a new interactive widget for the given [mediaProvider].
  ///
  /// Define the [heroTag] to enable hero animations.
  /// Defined a [fallbackBuilder] to generate an interactive media when the given media is not supported.
  const InteractiveMediaWidget({
    Key? key,
    required this.mediaProvider,
    this.fallbackBuilder,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tag = heroTag;
    if (tag != null) {
      return Hero(tag: tag, child: _buildMedia(context));
    }
    return _buildMedia(context);
  }

  Widget _buildMedia(BuildContext context) {
    final provider = mediaProvider;
    if (provider.isImage) {
      return ImageInteractiveMedia(mediaProvider: provider);
    } else if (mediaProvider.mediaType == 'application/pdf') {
      return PdfInteractiveMedia(mediaProvider: provider);
    } else if (mediaProvider.isAudio) {
      return AudioInteractiveMedia(mediaProvider: provider);
    } else if (mediaProvider.isVideo) {
      return VideoInteractiveMedia(mediaProvider: provider);
    } else if (mediaProvider.isText) {
      return TextInteractiveMedia(mediaProvider: mediaProvider);
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
      final builder = fallbackBuilder;
      if (builder != null) {
        return builder(context, provider);
      }
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
