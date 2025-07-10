import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");


  final oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'];
  if (oneSignalAppId == null || oneSignalAppId.isEmpty) {
    throw Exception("ONESIGNAL_APP_ID not found in .env");
  }


  OneSignal.initialize(oneSignalAppId);
  OneSignal.Notifications.requestPermission(true);

  runApp(const MyApp());
}
