## [2.3.0] - 2024-05-22
* Update dependencies

## [2.2.1] - 2023-10-05
* Update dependencies

## [2.2.0] - 2022-05-18
* Use pdfx instead of package:native_pdf_view package
* Ensure compatibility with Flutter 3.0

## [2.1.0] - 2021-07-21
* Use builder function instead of prebuild fallback widgets
* `MediaProviders` can now be converted for easier consumption

## [2.0.0] - 2021-06-13
* Restructured package
* Use `chewie_audio` instead of `flutter_sound_lite` package for better iOS support
* Use `CupertinoContextMenu` on iOS and MacOS when there are context menu items registered on a `PreviewMediaWidget`
* Use `fallbackBuilder` instead of `fallbackWidget` for better performance in the `PreviewMediaWidget` and `InteractiveMediaWidget`
* Removed `WidgetRegistry` as the fallback builders are a better way to control fallback generation

## [1.0.0] - 2021-03-10
* Support null-safefty
* Use open source [native_pdf_view](https://pub.dev/packages/native_pdf_view) package instead of commercial package
* Improved video controls

## [0.2.0] - 2021-02-02
* A `MediaProvider` can now also have a description that can be useful when sharing the media to other apps.
* The hero animation now works also for text media.
* Specify context menu items for `MediaPreviewWidget`s by specifying the `contextMenuEntries` and `onContextMenuSelected` parameters.

## [0.1.0] - 2021-01-19

* Opinionated but extensible collection of preview and interactive media widgets.
* Supports image, audio, PDF and text media for interactive experiences.
* Supports image and text for preview experiences.
