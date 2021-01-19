import 'dart:typed_data';

class MediaProvider {
  /// The name of this media
  final String name;

  /// The media type like text/plain or image/jpeg
  final String mediaType;

  /// The size in bytes, if known
  final int size;

  MediaProvider(this.name, this.mediaType, this.size);
  bool get isImage => mediaType.startsWith('image/');
  bool get isText => mediaType.startsWith('text/');
  bool get isVideo => mediaType.startsWith('video/');
  bool get isModel => mediaType.startsWith('model/');
  bool get isAudio => mediaType.startsWith('audio/');
  bool get isApplication => mediaType.startsWith('application/');
  bool get isFont => mediaType.startsWith('font/');
}

class UrlMediaProvider extends MediaProvider {
  final String url;
  UrlMediaProvider(String name, String mediaType, this.url, {int size})
      : super(name, mediaType, size);
}

class MemoryMediaProvider extends MediaProvider {
  final Uint8List data;

  MemoryMediaProvider(String name, String mediaType, this.data)
      : super(name, mediaType, data.length);
}

class AssetMediaProvider extends MediaProvider {
  final String assetName;
  AssetMediaProvider(String name, String mediaType, this.assetName)
      : super(name, mediaType, null);
}

class TextMediaProvider extends MediaProvider {
  final String text;
  TextMediaProvider(String name, String mediaType, this.text)
      : super(name, mediaType, null);
}
