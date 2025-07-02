import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");


  OneSignal.initialize('53cf696a-7965-4976-bc38-9a9cc224dcae');
  OneSignal.Notifications.requestPermission(true);

  runApp(const MyApp());
}
