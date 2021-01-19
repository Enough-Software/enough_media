import 'package:enough_media/preview/all_preview.dart';
import 'package:enough_media/widget_registry.dart';
import 'package:flutter/material.dart';

import 'interactive_media_widget.dart';
import 'media_provider.dart';

/// Shows the provided media in a preview mode.
class PreviewMediaWidget extends StatelessWidget {
  /// The media source
  final MediaProvider mediaProvider;

  /// Should a hero animation be used - this defaults to `true` when the `showInteractiveDelegate` is specified.
  final bool useHeroAnimation;

  /// Specifies if the registry should be used, defaults to `false` so there is no registry lookup
  final bool useRegistry;

  /// The width of the preview media
  final double width;

  /// The height of the preview media
  final double height;

  /// Optional delegate to switch to (typically fullscreen) interactive mode
  final Future Function(InteractiveMediaWidget) showInteractiveDelegate;

  /// Optional fallback widget that is shown when an unsupported media is encountered
  final Widget fallbackWidget;

  /// Creates a new media preview
  PreviewMediaWidget({
    Key key,
    @required this.mediaProvider,
    this.width,
    this.height,
    this.showInteractiveDelegate,
    this.useHeroAnimation = true,
    this.useRegistry = false,
    this.fallbackWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showInteractiveDelegate != null) {
      if (useHeroAnimation) {
        return Hero(
          tag: mediaProvider,
          child: _buildInteractiveDelegateButton(),
        );
      }
      return _buildInteractiveDelegateButton();
    }
    return _buildPreview();
  }

  Widget _buildInteractiveDelegateButton() {
    return ButtonTheme(
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minWidth: 0, //wraps child's width
      height: 0, //wraps child's height
      child: MaterialButton(
        onPressed: () {
          final interactive = InteractiveMediaWidget(
            mediaProvider: mediaProvider,
            useRegistry: useRegistry,
            heroTag: mediaProvider,
          );
          showInteractiveDelegate(interactive);
        },
        child: _buildPreview(),
      ),
    );
  }

  Widget _buildPreview() {
    final provider = mediaProvider;
    if (useRegistry) {
      final registryWidget = resolveFromRegistry();
      if (registryWidget != null) {
        return registryWidget;
      }
    }
    if (provider.isImage) {
      return ImagePreview(
        mediaProvider: provider,
        width: width,
        height: height,
      );
    }
    if (provider is TextMediaProvider) {
      return Text(
        provider.text,
        style: TextStyle(fontSize: 8),
        overflow: TextOverflow.ellipsis,
      );
    }
    if (fallbackWidget != null) {
      return fallbackWidget;
    }
    return Text('Not supported: ${mediaProvider.mediaType}');
  }

  Widget resolveFromRegistry() {
    final registry = WidgetRegistry();
    final provider = mediaProvider;
    if (registry.resolvePreview != null) {
      final resolved = registry.resolvePreview(provider, width, height);
      if (resolved != null) {
        return resolved;
      }
    }
    final mimeTypeResolver = registry.previewRegistry[provider.mediaType];
    if (mimeTypeResolver != null) {
      return mimeTypeResolver(provider, width, height);
    }
    return null;
  }
}
