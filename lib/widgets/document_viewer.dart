import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentViewer extends StatelessWidget {
  final String title;
  final String url;

  const DocumentViewer({Key? key, required this.title, required this.url}) : super(key: key);

  Future<void> _launchURL() async {
    if (!await launch(url)) {
      throw 'Could not open document';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF79C148),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Open in browser',
            onPressed: _launchURL,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 120, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Preview not available'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download / Open'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF79C148),
              ),
              onPressed: _launchURL,
            )
          ],
        ),
      ),
    );
  }
}
