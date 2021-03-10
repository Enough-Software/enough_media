import 'package:enough_media/media_provider.dart';
import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';

/// Displays PDFs
class PdfInteractiveMedia extends StatefulWidget {
  final MediaProvider mediaProvider;
  PdfInteractiveMedia({Key? key, required this.mediaProvider})
      : super(key: key);

  @override
  _PdfInteractiveMediaState createState() => _PdfInteractiveMediaState();
}

class _PdfInteractiveMediaState extends State<PdfInteractiveMedia> {
  late PdfController pdfController;

  @override
  void initState() {
    pdfController = PdfController(document: initDocument(widget.mediaProvider));
    super.initState();
  }

  Future<PdfDocument> initDocument(final MediaProvider provider) {
    if (provider is MemoryMediaProvider) {
      return PdfDocument.openData(provider.data);
      // } else if (provider is UrlMediaProvider) {
      //     provider.url
      //   );
    } else if (provider is AssetMediaProvider) {
      return PdfDocument.openAsset(provider.assetName);
    } else {
      throw StateError('Unsupported media provider $provider');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PdfView(
      controller: pdfController,
    );
  }

  // void onTextSelectionChanged(PdfTextSelectionChangedDetails details) {
  //   if (details.selectedText == null && overlayEntry != null) {
  //     overlayEntry.remove();
  //     overlayEntry = null;
  //   } else if (details.selectedText != null && overlayEntry == null) {
  //     final OverlayState overlayState = Overlay.of(context);
  //     overlayEntry = OverlayEntry(
  //       builder: (context) => Positioned(
  //         top: details.globalSelectedRegion.center.dy - 55,
  //         left: details.globalSelectedRegion.bottomLeft.dx,
  //         child: RaisedButton(
  //           child: Text('Copy', style: TextStyle(fontSize: 17)),
  //           onPressed: () {
  //             Clipboard.setData(ClipboardData(text: details.selectedText));
  //             pdfViewerController.clearSelection();
  //           },
  //           color: Colors.white,
  //           elevation: 10,
  //         ),
  //       ),
  //     );
  //     overlayState.insert(overlayEntry);
  //   }
  // }
}
