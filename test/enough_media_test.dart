import 'package:flutter_test/flutter_test.dart';

import 'package:enough_media/enough_media.dart';

void main() {
  test('media info', () {
    assert(MediaProvider('image.jpg', 'image/jpeg', null).isImage, true);
    assert(MediaProvider('music', 'audio/mp3', null).isAudio, true);
    assert(MediaProvider('video', 'video/mp4', null).isVideo, true);
    assert(MediaProvider('json', 'application/json', null).isApplication, true);
    assert(MediaProvider('pdf', 'application/pdf', null).isApplication, true);
  });
}
