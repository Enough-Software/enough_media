import 'dart:io';

import 'package:enough_media/src/preview/preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'interactive_media_widget.dart';
import 'media_provider.dart';

/// Shows the provided media in a preview mode.
class PreviewMediaWidget extends StatelessWidget {
  /// The media source
  final MediaProvider mediaProvider;

  /// Should a hero animation be used - this defaults to `true` when the `showInteractiveDelegate` is specified.
  final bool useHeroAnimation;

  /// The width of the preview media
  final double? width;

  /// The height of the preview media
  final double? height;

  /// Optional delegate to switch to (typically fullscreen) interactive mode
  final Future Function(InteractiveMediaWidget)? showInteractiveDelegate;

  /// Optional builder to create a dedicated preview widget before a default one is generated.
  final Widget? Function(BuildContext context, MediaProvider mediaProvider)?
      builder;

  /// Optional fallback builder that is invoked when an unsupported media is encountered
  final Widget Function(BuildContext context, MediaProvider mediaProvider)?
      fallbackBuilder;

  /// Optional builder for creating the interactive widget.
  final Widget? Function(BuildContext context, MediaProvider mediaProvider)?
      interactiveBuilder;

  /// Optional fallback builder that is invoked when an unsupported media is encountered when creating the interactive widget.
  final Widget Function(BuildContext context, MediaProvider mediaProvider)?
      interactiveFallbackBuilder;

  /// Optional list of context menu entries.
  ///
  /// When the `showInteractiveDelegate` is defined, then the context menu is shown after a long press.
  /// When the `showInteractiveDelegate` is not defined, then the context menu is shown after a press.
  /// Note that additionally the onContextMenuSelected delegate needs to be specified
  final List<PopupMenuEntry>? contextMenuEntries;

  /// Handler for context menu
  final Function(MediaProvider mediaProvider, dynamic entry)?
      onContextMenuSelected;

  /// Creates a new media preview for the specified [mediaProvider].
  ///
  /// Optionally specify the desired [width] and [height] of the preview widget.
  /// Define the [showInteractiveDelegate] callback to navigate to the interactive media widget when the preview is tapped.
  /// Set [useHeroAnimation] to `false` when no hero animation should be shown when going from preview to interactive mode.
  /// Set [useRegistry] to `true` when the [WidgetRegistry] should be used for looking up matching widgets.
  /// Define a [fallbackBuilder] to generate a preview widget when the media type in the [mediaProvider] is not directly supported.
  /// Define [contextMenuEntries] and a [onContextMenuSelected] callback to enable context menu items.
  PreviewMediaWidget({
    Key? key,
    required this.mediaProvider,
    this.width,
    this.height,
    this.showInteractiveDelegate,
    this.useHeroAnimation = true,
    this.builder,
    this.fallbackBuilder,
    this.interactiveBuilder,
    this.interactiveFallbackBuilder,
    this.contextMenuEntries,
    this.onContextMenuSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showInteractiveDelegate != null ||
        (contextMenuEntries?.isNotEmpty ?? false)) {
      if (useHeroAnimation) {
        return Hero(
          tag: mediaProvider,
          child: _buildInteractiveDelegateButton(context),
        );
      }
      return _buildInteractiveDelegateButton(context);
    }
    return _buildPreview(context);
  }

  Widget _buildInteractiveDelegateButton(BuildContext context) {
    if (Platform.isIOS || Platform.isMacOS) {
      return _buildCupertinoButton(context);
    }
    void Function() onPressed;
    void Function()? onLongPressed;
    if (showInteractiveDelegate != null) {
      onPressed = _showInteractiveDelegate;
      if (contextMenuEntries?.isNotEmpty ?? false) {
        onLongPressed = () => _showContextMenu(context);
      }
    } else {
      onPressed = () => _showContextMenu(context);
    }
    return MaterialButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      onLongPress: onLongPressed,
      child: _buildPreview(context),
    );
  }

  Widget _buildCupertinoButton(BuildContext context) {
    final menuEntries = contextMenuEntries;
    final callback = onContextMenuSelected;
    if (menuEntries != null && menuEntries.isNotEmpty && callback != null) {
      final cupertinoActions = menuEntries
          .whereType<PopupMenuItem>()
          .map((e) => CupertinoContextMenuAction(
                child: e.child!,
                onPressed: () {
                  Navigator.of(context).pop();
                  callback(mediaProvider, e);
                },
              ))
          .toList();
      return CupertinoContextMenu(
        actions: cupertinoActions,
        child: CupertinoButton(
          child: _buildPreview(context),
          onPressed: _showInteractiveDelegate,
        ),
      );
    }
    return CupertinoButton(
      child: _buildPreview(context),
      onPressed: _showInteractiveDelegate,
    );
  }

  void _showInteractiveDelegate() {
    final interactive = InteractiveMediaWidget(
      mediaProvider: mediaProvider,
      heroTag: mediaProvider,
      builder: interactiveBuilder,
      fallbackBuilder: interactiveFallbackBuilder,
    );
    showInteractiveDelegate!(interactive);
  }

  void _showContextMenu(BuildContext context) async {
    final selectedValue = await showMenu(
      items: contextMenuEntries!,
      context: context,
      position: _getPosition((width ?? 60) / 2, context),
    );
    if (selectedValue != null && onContextMenuSelected != null) {
      onContextMenuSelected!(mediaProvider, selectedValue);
    }
  }

  RelativeRect _getPosition(double shift, BuildContext context) {
    final rb = context.findRenderObject() as RenderBox?;
    final offset = rb?.localToGlobal(Offset.zero);
    double left = (offset?.dx ?? 120) + shift;
    double top = (offset?.dy ?? 120) + shift;
    return RelativeRect.fromLTRB(left, top, left + 60, top + 60);
  }

  Widget _buildPreview(BuildContext context) {
    final provider = mediaProvider;
    final callback = builder;
    if (callback != null) {
      final preview = callback(context, provider);
      if (preview != null) {
        return preview;
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
      return Material(
        // required for Hero transition
        type: MaterialType.transparency,
        child: Container(
          width: width,
          height: height,
          child: Column(
            children: [
              Text(
                provider.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                provider.text,
                style: TextStyle(fontSize: 8),
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }
    final fallback = fallbackBuilder;
    if (fallback != null) {
      return fallback(context, mediaProvider);
    }
    return Container(
      width: width,
      height: height,
      child: Text(mediaProvider.name),
    );
  }
}
