import 'package:dio/dio.dart';
import 'package:APHRC_COP/services/shared_prefs_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DownloadUtil {
  static Future<void> downloadFile(String url, String fileName) async {
    try {
      final dio = Dio();

      // Get token from shared preferences
      final token = await SharedPrefsService.getAccessToken();

      // Add authorization header if token exists
      final options = Options(
        headers: token != null ? {
          'Authorization': 'Bearer $token',
          // Add any other headers your API requires here
        } : null,
        responseType: ResponseType.bytes,
        followRedirects: false,
        validateStatus: (status) {
          return status != null && status < 500;
        },
      );

      final response = await dio.get<List<int>>(
        url,
        options: options,
      );

      if (response.statusCode == 200) {
        // Get downloads directory
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(response.data!);

        print('File downloaded to $filePath');
      } else {
        print('Download failed: ${response.statusCode} ${response.statusMessage}');
      }
    } catch (e) {
      print('Download error: $e');
    }
  }
}
