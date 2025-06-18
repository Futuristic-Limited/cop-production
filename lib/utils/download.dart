import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> downloadAndOpenFile({
  required String url,
  required String fileName,
  required String token,
  required BuildContext context, // For showing dialogs/snackbars
  Function(double)? onProgress, // Optional progress callback
}) async {
  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Downloading document...'),
          ],
        ),
      ),
    );

    // Check permissions with BuildContext
    final hasPermission = await _checkAndRequestStoragePermission(context);
    if (!hasPermission) {
      print('Permission not found');
      if (context.mounted) Navigator.pop(context);
      return;
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      Navigator.pop(context); // Remove loading dialog
      throw Exception('Failed to download file (HTTP ${response.statusCode})');
    }

    // Get downloads directory (more permanent than temp)
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    // Write file with progress reporting
    await file.writeAsBytes(
      response.bodyBytes,
      mode: FileMode.write,
      flush: true,
    );

    // Close loading dialog
    if (context.mounted) Navigator.pop(context);

    // Open the file
    final openResult = await OpenFile.open(filePath);

    if (openResult.type != ResultType.done) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: ${openResult.message}')),
        );
      }
    }
  } catch (e) {
    // Close loading dialog if still open
    if (context.mounted) Navigator.pop(context);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
    rethrow;
  }
}

Future<bool> _checkAndRequestStoragePermission(BuildContext context) async {
  if (!Platform.isAndroid) return true; // iOS doesn't need these permissions

  // For Android 13+ (API 33+)
  var permission = await Permission.manageExternalStorage.isGranted;
  print('Getting the permission, $permission');
  if (await Permission.manageExternalStorage.isGranted) {
    return true;
  }

  // For Android 10-12
  var permission2 = await Permission.storage.isGranted;
  print('Getting the permission two, $permission2');
  if (await Permission.storage.isGranted) {
    return true;
  }

  // Request the appropriate permission
  final status = await Permission.storage.request();
  if (status.isGranted) return true;

  // If first request was denied, show explanation
  if (status.isPermanentlyDenied) {
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
              'Storage access is required to save downloaded files.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }
  }

  return false;
}