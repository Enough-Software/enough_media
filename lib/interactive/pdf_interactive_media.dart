import 'dart:typed_data';

import 'package:enough_media/media_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Displays PDFs
class PdfInteractiveMedia extends StatefulWidget {
  final MediaProvider mediaProvider;
  PdfInteractiveMedia({Key key, @required this.mediaProvider})
      : super(key: key);

  @override
  _PdfInteractiveMediaState createState() => _PdfInteractiveMediaState();
}

class _PdfInteractiveMediaState extends State<PdfInteractiveMedia> {
  PdfViewerController pdfViewerController;
  OverlayEntry overlayEntry;

  @override
  void initState() {
    pdfViewerController = PdfViewerController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.mediaProvider;
    if (provider is MemoryMediaProvider) {
      return SfPdfViewer.memory(
        provider.data,
        controller: pdfViewerController,
        onTextSelectionChanged: onTextSelectionChanged,
      );
    } else if (provider is UrlMediaProvider) {
      return SfPdfViewer.network(
        provider.url,
        controller: pdfViewerController,
        onTextSelectionChanged: onTextSelectionChanged,
      );
    } else if (provider is AssetMediaProvider) {
      return SfPdfViewer.asset(
        provider.assetName,
        controller: pdfViewerController,
        onTextSelectionChanged: onTextSelectionChanged,
      );
    } else {
      throw StateError('Unsupported media provider $provider');
    }
  }

  void onTextSelectionChanged(PdfTextSelectionChangedDetails details) {
    if (details.selectedText == null && overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    } else if (details.selectedText != null && overlayEntry == null) {
      final OverlayState overlayState = Overlay.of(context);
      overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: details.globalSelectedRegion.center.dy - 55,
          left: details.globalSelectedRegion.bottomLeft.dx,
          child: RaisedButton(
            child: Text('Copy', style: TextStyle(fontSize: 17)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: details.selectedText));
              pdfViewerController.clearSelection();
            },
            color: Colors.white,
            elevation: 10,
          ),
        ),
      );
      overlayState.insert(overlayEntry);
    }
  }
}
