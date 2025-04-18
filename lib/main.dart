import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Snap Viewer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PDFSnapViewerPage(),
    );
  }
}

class PDFSnapViewerPage extends StatefulWidget {
  @override
  _PDFSnapViewerPageState createState() => _PDFSnapViewerPageState();
}

class _PDFSnapViewerPageState extends State<PDFSnapViewerPage> {
  String? _filePath;
  bool? _isLandscape;

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final isLandscape = await _checkOrientation(filePath);
      setState(() {
        _filePath = filePath;
        _isLandscape = isLandscape;
      });
    }
  }

  /// Check if the first page is landscape
  Future<bool> _checkOrientation(String path) async {
    final fileBytes = await File(path).readAsBytes();
    final doc = PdfDocument(inputBytes: fileBytes);
    final page = doc.pages[0];
    final isLandscape = page.size.width > page.size.height;
    doc.dispose();
    return isLandscape;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Snap Viewer'),
        actions: [
          IconButton(
            icon: Icon(Icons.folder_open),
            onPressed: _pickPDF,
          )
        ],
      ),
      body: _filePath == null
          ? Center(child: Text('Pick a PDF using the folder icon.'))
          : SfPdfViewer.file(
              File(_filePath!),
              canShowScrollHead: false,
              canShowScrollStatus: false,
              pageLayoutMode: _isLandscape == true
                  ? PdfPageLayoutMode.single  // Full height
                  : PdfPageLayoutMode.continuous, // Snap width
            ),
    );
  }
}
