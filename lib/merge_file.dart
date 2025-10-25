import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/services.dart';

Future<File?> mergePDFs({
  required BuildContext context,
  required List<File> files,
  required double left,
  required double right,
  required double top,
  required double bottom,
}) async {
  final Directory root = await getApplicationDocumentsDirectory();
  final PdfDocument mergedPdf = PdfDocument();
  final PdfSection section = mergedPdf.sections!.add();
  section.pageSettings = PdfPageSettings(PdfPageSize.a4);

  const double spacingBetweenPdfs = 10;
  double maxContentWidth = PdfPageSize.a4.width - left - right;
  double maxContentHeight = PdfPageSize.a4.height - top - bottom;

  PdfPage? currentPage;
  double currentHeight = top;

  for (File file in files) {
    final Uint8List bytes = await file.readAsBytes();
    PdfDocument? inputPdf;

    // Try opening without password
    try {
      inputPdf = PdfDocument(inputBytes: bytes);
    } catch (e) {
      // Check if it's due to encryption
      if (e.toString().contains('password')) {
        String? password;

        while (true) {
          if (context.mounted) {
            password = await _askForPassword(
              context,
              file.path.split('/').last,
            );
          }

          if (password == null) {
            // User cancelled
            mergedPdf.dispose();
            return null;
          }

          try {
            inputPdf = PdfDocument(inputBytes: bytes, password: password);
            break; // success
          } catch (e) {
            if (context.mounted) {
              await _showErrorDialog(
                context,
                'Incorrect password. Please try again.',
              );
            }
          }
        }
      } else {
        rethrow; // Some other error
      }
    }

    for (int i = 0; i < inputPdf.pages.count; i++) {
      final PdfPage inputPage = inputPdf.pages[i];
      final Size originalSize = inputPage.getClientSize();
      double drawWidth = originalSize.width;
      double drawHeight = originalSize.height;

      if (drawWidth > maxContentWidth || drawHeight > maxContentHeight) {
        final widthRatio = maxContentWidth / drawWidth;
        final heightRatio = maxContentHeight / drawHeight;
        final shrinkRatio = widthRatio < heightRatio ? widthRatio : heightRatio;

        drawWidth *= shrinkRatio;
        drawHeight *= shrinkRatio;
      }

      if (currentPage == null ||
          currentHeight + drawHeight > PdfPageSize.a4.height - bottom) {
        currentPage = section.pages.add();
        currentHeight = top;
      }

      final template = inputPage.createTemplate();
      currentPage.graphics.drawPdfTemplate(
        template,
        Offset(left, currentHeight),
        Size(drawWidth, drawHeight),
      );

      currentHeight += drawHeight + spacingBetweenPdfs;
    }

    inputPdf.dispose();
  }

  final List<int> finalBytes = mergedPdf.saveSync();
  mergedPdf.dispose();

  final File outputFile = File("${root.path}/MergedMultiPage.pdf");
  await outputFile.writeAsBytes(finalBytes);
  return outputFile;
}

Future<String?> _askForPassword(BuildContext context, String filePath) async {
  String password = '';
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Password Required',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter password for:'),
            Text(filePath, style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              obscureText: true,
              autofocus: true,
              onChanged: (value) => password = value,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(null),
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(password),
          ),
        ],
      );
    },
  );
}

Future<void> _showErrorDialog(BuildContext context, String message) async {
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      );
    },
  );
}