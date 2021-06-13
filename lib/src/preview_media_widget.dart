import 'package:enough_media/src/preview/preview.dart';
import 'package:flutter/material.dart';

import 'interactive_media_widget.dart';
import 'media_provider.dart';

/// Shows the provided media in a preview mode.
class PreviewMediaWidget extends StatefulWidget {
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

  /// Optional fallback builder that is invoked when an unsupported media is encountered
  final Widget Function(BuildContext context, MediaProvider mediaProvider)?
      fallbackBuilder;

  /// Optional fallback builder that is invoked when an unsupported media is encountered
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
    this.fallbackBuilder,
    this.interactiveFallbackBuilder,
    this.contextMenuEntries,
    this.onContextMenuSelected,
  }) : super(key: key);

  @override
  _PreviewMediaWidgetState createState() => _PreviewMediaWidgetState();
}

class _PreviewMediaWidgetState extends State<PreviewMediaWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.showInteractiveDelegate != null ||
        (this.widget.contextMenuEntries?.isNotEmpty ?? false)) {
      if (widget.useHeroAnimation) {
        return Hero(
          tag: widget.mediaProvider,
          child: _buildInteractiveDelegateButton(),
        );
      }
      return _buildInteractiveDelegateButton();
    }
    return _buildPreview();
  }

  Widget _buildInteractiveDelegateButton() {
    void Function() onPressed;
    void Function()? onLongPressed;
    if (widget.showInteractiveDelegate != null) {
      onPressed = _showInteractiveDelegate;
      if (this.widget.contextMenuEntries?.isNotEmpty ?? false) {
        onLongPressed = _showContextMenu;
      }
    } else {
      onPressed = _showContextMenu;
    }
    return ButtonTheme(
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minWidth: 0, //wraps child's width
      height: 0, //wraps child's height
      child: MaterialButton(
        onPressed: onPressed,
        onLongPress: onLongPressed,
        child: _buildPreview(),
      ),
    );
  }

  void _showInteractiveDelegate() {
    final interactive = InteractiveMediaWidget(
      mediaProvider: widget.mediaProvider,
      heroTag: widget.mediaProvider,
      fallbackBuilder: widget.interactiveFallbackBuilder,
    );
    widget.showInteractiveDelegate!(interactive);
  }

  void _showContextMenu() async {
    final selectedValue = await showMenu(
      items: widget.contextMenuEntries!,
      context: context,
      position: _getPosition((widget.width ?? 60) / 2),
    );
    if (selectedValue != null && widget.onContextMenuSelected != null) {
      widget.onContextMenuSelected!(widget.mediaProvider, selectedValue);
    }
  }

  RelativeRect _getPosition(double? shift) {
    shift ??= 60;
    final rb = context.findRenderObject() as RenderBox?;
    final offset = rb?.localToGlobal(Offset.zero);
    double left = (offset?.dx ?? 120) + shift;
    double top = (offset?.dy ?? 120) + shift;
    return RelativeRect.fromLTRB(left, top, left + 60, top + 60);
  }

  Widget _buildPreview() {
    final provider = widget.mediaProvider;
    if (provider.isImage) {
      return ImagePreview(
        mediaProvider: provider,
        width: widget.width,
        height: widget.height,
      );
    }
    if (provider is TextMediaProvider) {
      return Material(
        // required for Hero transition
        type: MaterialType.transparency,
        child: Container(
          width: widget.width,
          height: widget.height,
          child: Column(
            children: [
              Text(
                provider.name,
                style: Theme.of(context).textTheme.subtitle2,
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
    final builder = widget.fallbackBuilder;
    if (builder != null) {
      return builder(context, widget.mediaProvider);
    }
    return Container(
      width: widget.width,
      height: widget.height,
      child: Text(widget.mediaProvider.name),
    );
  }
}
