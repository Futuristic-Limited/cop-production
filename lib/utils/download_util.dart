import 'package:dio/dio.dart';
import 'package:APHRC_COP/services/shared_prefs_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

final apiUrl = (dotenv.env['WP_API_URL'] ?? 'https://futuristicdevlabs.digital/cop')
    .replaceAll(RegExp(r'/+$'), '');

void debugPrintApiUrl() {
  print('✅ Base API URL: $apiUrl');
}

class DownloadUtil {
  /// Download a file using media ID and save it with the provided file name
  static Future<void> downloadFileById(int mediaId, String fileName) async {
    try {
      final dio = Dio();
      final token = await SharedPrefsService.getAccessToken();

      if (token == null) {
        print('❌ Download aborted: User is not authenticated.');
        return;
      }

      final url = '$apiUrl/user/download/$mediaId';
      print('📥 Downloading from: $url');

      final options = Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
        responseType: ResponseType.bytes,
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      );

      final response = await dio.get<List<int>>(url, options: options);

      if (response.statusCode == 200 && response.data != null) {
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/$fileName';
        final file = File(filePath);

        await file.writeAsBytes(response.data!);
        print('✅ File downloaded successfully to: $filePath');
      } else {
        print('❌ Failed to download file. Status: ${response.statusCode}');
        print('↪️ Message: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ Exception during download: $e');
    }
  }
}
