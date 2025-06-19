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
  final Map<String, bool> _downloadingStates = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          widget.documents.map((doc) {
            // Skip if URL is null or empty
            if (doc.url == null || doc.url!.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.insert_drive_file,
                      color: Colors.grey[400],
                    ),
                    title: Text(
                      doc.title ?? 'Unavailable Document',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    subtitle: const Text('Document unavailable'),
                    trailing: Icon(Icons.error_outline, color: Colors.red[400]),
                    onTap: null, // Disable tap for unavailable documents
                  ),
                ],
              );
            }

            final isDownloading = _downloadingStates[doc.url] ?? false;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      isDownloading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(
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
                  trailing:
                      isDownloading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : null,
                  onTap:
                      isDownloading
                          ? null
                          : () async {
                            final filename = doc.title ?? 'document.pdf';

                            setState(() {
                              _downloadingStates[doc.url!] = true;
                            });

                            try {
                              await downloadAndOpenFile(
                                url: doc.url!,
                                fileName: filename,
                                token: widget.accessToken,
                                context: context,
                              );
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to download: ${e.toString()}',
                                    ),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _downloadingStates[doc.url!] = false;
                                });
                              }
                            }
                          },
                ),
              ],
            );
          }).toList(),
    );
  }
}
