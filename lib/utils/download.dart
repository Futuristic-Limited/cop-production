import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Future<void> downloadAndOpenFile(
  String url,
  String fileName,
  String token,
) async {
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      await OpenFile.open(filePath);
    } else {
      throw Exception('Failed to download file: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
