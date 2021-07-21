import 'package:flutter_test/flutter_test.dart';

import 'package:enough_media/enough_media.dart';

void main() {
  test('media info', () {
    assert(TextMediaProvider('image.jpg', 'image/jpeg', 'text').isImage, true);
    assert(TextMediaProvider('music', 'audio/mp3', 'text').isAudio, true);
    assert(TextMediaProvider('video', 'video/mp4', 'text').isVideo, true);
    assert(TextMediaProvider('json', 'application/json', 'text').isApplication,
        true);
    assert(TextMediaProvider('pdf', 'application/pdf', 'text').isApplication,
        true);
  });
}
