import 'package:enough_media/enough_media.dart';
import 'package:flutter/material.dart';

/// Wraps any supported media into an interactive widget.
class InteractiveMediaWidget extends StatelessWidget {
  /// Creates a new interactive widget for the given [mediaProvider].
  ///
  /// Define the [heroTag] to enable hero animations.
  ///
  /// Define the [builder] to potentially create better fitting
  /// interactive widgets for the given [mediaProvider].
  ///
  /// Defined a [fallbackBuilder] to generate an interactive media when the
  /// given media is not supported.
  const InteractiveMediaWidget({
    super.key,
    required this.mediaProvider,
    this.builder,
    this.fallbackBuilder,
    this.heroTag,
  });

  /// The provider for the media to be shown
  final MediaProvider mediaProvider;

  /// The hero tag for animating between preview and interactive, for example.
  final Object? heroTag;

  /// The builder for creating the concrete interactive widget for the
  /// given [mediaProvider].
  ///
  /// When this function returns `null`, the default interactive widgets
  /// will be build.
  ///
  /// When no default interactive widget is associated, the Widget
  /// created by the [fallbackBuilder] will be used.
  ///
  /// When no [fallbackBuilder] is defined, then a default fallback
  /// is generated.
  final Widget? Function(BuildContext context, MediaProvider mediaProvider)?
      builder;

  /// The builder for creating the fallback interactive widget for the
  /// given [mediaProvider].
  ///
  /// This is used when neither the [builder] nor the default registrations
  /// generated a widget.
  final Widget Function(BuildContext context, MediaProvider mediaProvider)?
      fallbackBuilder;

  @override
  Widget build(BuildContext context) {
    final heroTag = this.heroTag;

    return (heroTag != null)
        ? Hero(tag: heroTag, child: _buildMedia(context))
        : _buildMedia(context);
  }

  Widget _buildMedia(BuildContext context) {
    final provider = mediaProvider;
    final callback = builder;
    if (callback != null) {
      final widget = callback(context, provider);
      if (widget != null) {
        return widget;
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
          child: SelectableText(
            '${provider.name}:\n'
            'Unsupported content with mime type ${provider.mediaType}',
          ),
        ),
      );
    }
  }
}
