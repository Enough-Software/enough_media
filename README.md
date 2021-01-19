# enough_media

An opinionated but extensible framework for media previews and interactions.
This is useful for apps that handle a variety of media files.
Originally motivated by creating a [Flutter email app](https://github.com/enough-software/enough_mail_app).

## Getting Started

1. Create a `MediaProvider`, e.g.
  * `UrlMediaProvider('funny.png', 'image/png', 'https://domain.com/resources/funny.png')`
  * `AssetMediaProvider('funny.png', 'image/png', 'stuff/funny.png')`
  * `MemoryMediaProvider('funny.png', 'image/png', data)` // data is a `Uint8List`
2. Either build a `PreviewMediaWidget` or an `InteractiveMediaWidget`.
3. Done :-)

## API Documentation
Check out the full API documentation at https://pub.dev/documentation/enough_media/latest/


## Installation
Add this dependencies your pubspec.yaml file:

```
dependencies:
  enough_media: ^0.1.0
```
The latest version or `enough_media` is [![enough_media version](https://img.shields.io/pub/v/enough_media.svg)](https://pub.dartlang.org/packages/enough_media).


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/enough-software/enough_media/issues

## License

Licensed under the commercial friendly [Mozilla Public License 2.0](LICENSE).