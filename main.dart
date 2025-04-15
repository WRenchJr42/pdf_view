import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
  // Optionally, lock to portrait initially:
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Viewer App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PDFViewerPage(),
    );
  }
}

class PDFViewerPage extends StatefulWidget {
  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? pdfPath; // Stores the path of the selected PDF file.
  bool isPortrait = true;

  Future<void> _pickPDF() async {
    // Open the file picker to select a PDF file.
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        pdfPath = result.files.single.path;
      });
    }
  }

  void _toggleOrientation() async {
    // Toggle between portrait and landscape orientations.
    if (isPortrait) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
    setState(() {
      isPortrait = !isPortrait;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        actions: [
          IconButton(
            icon: Icon(Icons.screen_rotation),
            onPressed: _toggleOrientation,
            tooltip: 'Toggle Orientation',
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickPDF,
        tooltip: 'Select PDF',
        child: Icon(Icons.folder_open),
      ),
      body: pdfPath == null
          ? Center(child: Text('No PDF selected.'))
          : PDFView(
              filePath: pdfPath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              onError: (error) => print('Error: $error'),
              onRender: (pages) {
                print('PDF rendered with $pages pages.');
              },
              onViewCreated: (PDFViewController pdfViewController) {
                // You can store the controller if needed for additional operations.
              },
              onPageError: (page, error) =>
                  print('Error on page $page: $error'),
              onPageChanged: (current, total) =>
                  print('Page change: $current/$total'),
            ),
    );
  }
}
