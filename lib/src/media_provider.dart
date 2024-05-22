import 'dart:convert';
import 'dart:typed_data';

import 'package:enough_media/src/util/http_helper.dart';
import 'package:flutter/services.dart' show rootBundle;

abstract class MediaProvider {
  /// The name of this media
  final String name;

  /// The media type like text/plain or image/jpeg
  final String mediaType;

  /// The size in bytes, if known
  final int? size;

  /// Description, can be useful when sharing this media
  final String? description;

  /// Creates a new media provider with the given [name], [mediaType] like application/pdf, [size] in bytes and [description].
  MediaProvider(this.name, this.mediaType, this.size, {this.description});

  /// Checks if this is an image
  bool get isImage => mediaType.startsWith('image/');

  /// Checks if this is text
  bool get isText => mediaType.startsWith('text/');

  /// Checks if this is a video
  bool get isVideo => mediaType.startsWith('video/');

  /// Checks if this is a model
  bool get isModel => mediaType.startsWith('model/');

  /// Checks if this is an audio media
  bool get isAudio => mediaType.startsWith('audio/');

  /// Checks if this is an application media
  bool get isApplication => mediaType.startsWith('application/');

  /// Checks if this is a font
  bool get isFont => mediaType.startsWith('font/');

  /// Checks if this is a message
  bool get isMessage => mediaType.startsWith('message/');

  /// Converts this provider to a [TextMediaProvider], note that the [mediaType] will stay the same
  ///
  /// Throws a [StateError] when the conversion fails.
  Future<TextMediaProvider> toTextProvider();

  /// Converts this provider to a [MemoryMediaProvider], note that the [mediaType] will stay the same
  ///
  /// Throws a [StateError] when the conversion fails.
  Future<MemoryMediaProvider> toMemoryProvider();
}

/// Media provider for remote media files
class UrlMediaProvider extends MediaProvider {
  /// The url like `https://domain.com/resources/file.png`
  final String url;

  /// Creates a new URL media provider with the given [name], [mediaType] and [url].
  /// Optionally specify the [size] in bytes and the [description].
  UrlMediaProvider(String name, String mediaType, this.url,
      {int? size, String? description})
      : super(name, mediaType, size, description: description);

  @override
  Future<TextMediaProvider> toTextProvider() {
    return toMemoryProvider().then((p) => p.toTextProvider());
  }

  @override
  Future<MemoryMediaProvider> toMemoryProvider() async {
    final result = await HttpHelper.httpGet(url);
    if (result.data != null) {
      return MemoryMediaProvider(name, mediaType, result.data!,
          description: description);
    }
    throw StateError(
        'Unable to download $url, got status code ${result.statusCode}');
  }
}

/// Provides preloaded media
class MemoryMediaProvider extends MediaProvider {
  /// The preloaded media data
  final Uint8List data;

  /// Creates a new meemory media provider with the given [name], [mediaType] and [data].
  /// Optionally specify the [description].
  MemoryMediaProvider(String name, String mediaType, this.data,
      {String? description})
      : super(name, mediaType, data.length, description: description);

  @override
  Future<TextMediaProvider> toTextProvider() {
    final text = utf8.decode(data, allowMalformed: true);
    return Future.value(
        TextMediaProvider(name, mediaType, text, description: description));
  }

  @override
  Future<MemoryMediaProvider> toMemoryProvider() {
    return Future.value(this);
  }
}

/// Provides assets as media
class AssetMediaProvider extends MediaProvider {
  /// The name of the asset, depending on the asset location also requires the path
  final String assetName;

  /// Creates a new asset media provider with the given [name], [mediaType] and [assetName].
  /// Optionally specify the [size] in bytes and the [description].
  AssetMediaProvider(String name, String mediaType, this.assetName,
      {String? description})
      : super(name, mediaType, null, description: description);

  @override
  Future<TextMediaProvider> toTextProvider() async {
    String text = await rootBundle.loadString(assetName);
    return TextMediaProvider(name, mediaType, text, description: description);
  }

  @override
  Future<MemoryMediaProvider> toMemoryProvider() async {
    final data = await rootBundle.load(assetName);
    final buffer = data.buffer;
    final uint8ListData =
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return MemoryMediaProvider(name, mediaType, uint8ListData,
        description: description);
  }
}

class TextMediaProvider extends MediaProvider {
  final String text;
  TextMediaProvider(String name, String mediaType, this.text,
      {String? description})
      : super(name, mediaType, null, description: description);

  @override
  Future<TextMediaProvider> toTextProvider() {
    return Future.value(this);
  }

  @override
  Future<MemoryMediaProvider> toMemoryProvider() {
    final data = utf8.encode(text);
    // ignore: unnecessary_type_check
    final uint8ListData = data is Uint8List ? data : Uint8List.fromList(data);
    return Future.value(MemoryMediaProvider(name, mediaType, uint8ListData,
        description: description));
  }
}
