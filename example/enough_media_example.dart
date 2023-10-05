import 'dart:typed_data';

import 'package:enough_media/enough_media.dart';
import 'package:flutter/material.dart';

/// Preview media.
Widget buildPreview(String name, String mimeType, Uint8List data) {
  final mediaProvider = MemoryMediaProvider(name, mimeType, data);
  return PreviewMediaWidget(
    mediaProvider: mediaProvider,
  );
}

/// Provide interactive media, typically for near-full-screen experiences:
Widget buildInteractive(String name, String mimeType, Uint8List data) {
  final mediaProvider = MemoryMediaProvider(name, mimeType, data);
  return InteractiveMediaWidget(
    mediaProvider: mediaProvider,
  );
}

/// Preview media and let enough_media move to the interactive experience with a Hero-based animation:
Widget buildPreviewWithShowInteractiveDelegate(
    BuildContext context, String name, String mimeType, Uint8List data) {
  final mediaProvider = MemoryMediaProvider(name, mimeType, data);
  return PreviewMediaWidget(
    mediaProvider: mediaProvider,
    showInteractiveDelegate: (media) => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(body: media),
      ),
    ),
  );
}
