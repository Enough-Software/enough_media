import 'package:enough_media/enough_media.dart';
import 'package:enough_media/media_provider.dart';
import 'package:flutter/widgets.dart';

class WidgetRegistry {
  static WidgetRegistry _instance;
  final previewRegistry =
      <String, Widget Function(MediaProvider, double width, double height)>{};
  final interactiveRegistry = <String, Widget Function(MediaProvider)>{};
  Widget Function(MediaProvider, double width, double height) resolvePreview;
  Widget Function(MediaProvider) resolveInteractive;

  WidgetRegistry._internal();

  factory WidgetRegistry() {
    _instance ??= WidgetRegistry._internal();
    return _instance;
  }
}
