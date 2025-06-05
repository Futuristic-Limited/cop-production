import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/messages/messages_screen.dart';
import 'screens/groups/groups_screen.dart';
import 'screens/courses/courses_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/auth/verify_reset_otp_screen.dart';
import 'screens/auth/reset_password_screen.dart';
//import 'screens/home/landing_page.dart';
import 'package:APHRC_COP/screens/email_invites/email_invites_screen.dart';
import 'screens/splash/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APHRC COP',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const AnimatedSplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/messages': (context) => const MessagesScreen(),
        '/groups': (context) => const GroupsScreen(),
        '/courses': (context) => const CoursesScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        // '/landing': (context) => const LandingPage(),
        '/verify-reset-otp': (context) => const VerifyResetOtpScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/email_invites': (context) => const SendEmailInvitesScreen(),
      },
    );
  }
}
