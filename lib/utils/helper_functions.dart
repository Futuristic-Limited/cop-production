// Helper function to format date
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';

import '../models/group_documents_model.dart';

String formatDate(DateTime date) {
  return DateFormat('MMM dd, yyyy').format(date);
}

// Helper function to get appropriate icon for document type
IconData getDocumentIcon(String type) {
  switch (type.toLowerCase()) {
    case 'pdf':
      return Icons.picture_as_pdf;
    case 'doc':
    case 'docx':
      return Icons.description;
    case 'xls':
    case 'xlsx':
      return Icons.table_chart;
    case 'ppt':
    case 'pptx':
      return Icons.slideshow;
    default:
      return Icons.insert_drive_file;
  }
}

// Helper function to get color based on document type
Color getDocumentColor(String type) {
  switch (type.toLowerCase()) {
    case 'pdf':
      return Colors.red;
    case 'doc':
    case 'docx':
      return Colors.blue;
    case 'xls':
    case 'xlsx':
      return Colors.green;
    case 'ppt':
    case 'pptx':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

MediaType getContentType(String filePath) {
  final mimeType = lookupMimeType(filePath);
  if (mimeType != null) {
    final parts = mimeType.split('/');
    return MediaType(parts[0], parts[1]);
  }
  return MediaType('application', 'octet-stream');
}


// Function to handle download
void downloadDocument(DocumentItem document) {
  // Implement your download logic here
  print('Downloading ${document.title}');
}