import 'package:flutter/material.dart';
import '../../models/buddyboss_thread.dart';
import '../../utils/download.dart';

class MessageDocumentGallery extends StatefulWidget {
  final List<BpMedia> documents;
  final String accessToken;

  const MessageDocumentGallery({
    super.key,
    required this.documents,
    required this.accessToken,
  });

  @override
  State<MessageDocumentGallery> createState() => _MessageDocumentGalleryState();
}

class _MessageDocumentGalleryState extends State<MessageDocumentGallery> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.documents.map((doc) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.insert_drive_file,
                color: Colors.blue,
              ),
              title: Text(
                doc.title ?? 'Document',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                final filename = doc.title ?? 'document.pdf';
                downloadAndOpenFile(doc.url!, filename, widget.accessToken);
              },
            ),
          ],
        );
      }).toList(),
    );
  }
}
