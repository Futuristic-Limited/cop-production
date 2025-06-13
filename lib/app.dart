import 'dart:async';
import 'package:APHRC_COP/screens/communities/communities_screen.dart';
import 'package:flutter/material.dart';
import 'package:APHRC_COP/services/shared_prefs_service.dart';
import 'package:APHRC_COP/screens/groups/group_members_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/home_screen_logged_in.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/messages/messages_screen.dart';
import 'screens/groups/groups_screen.dart';
import 'screens/courses/courses_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/auth/verify_reset_otp_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/home/landing_page.dart';
import 'package:APHRC_COP/screens/email_invites/email_invites_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/groups/group_detail_screen.dart';
import 'package:APHRC_COP/files/UserUploadsScreen.dart';
import 'screens/discussions/index.dart';
import 'screens/events/events_screen.dart';
import 'screens/guidelines/guidelines_screen.dart';
import 'screens/home/my_dashboard.dart';
import 'screens/activity/activity_feed_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  Timer? _idleTimer;

  @override
  void initState() {
    super.initState();
    _resetIdleTimer();
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(minutes: 1410), _handleUserInactivity);
  }

  void _handleUserInactivity() async {
    if (!mounted || navigatorKey.currentContext == null) return;

    // Clear user session (logout)
    await SharedPrefsService.logout();

    // Then navigate to login screen and remove all previous routes
    Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil(
      '/login',
          (route) => false,
    );
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _resetIdleTimer(),
      onPointerMove: (_) => _resetIdleTimer(),
      onPointerHover: (_) => _resetIdleTimer(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'APHRC COP',
        theme: ThemeData(primarySwatch: Colors.green),
        home: const AnimatedSplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/communities': (context) => const CommunitiesScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/messages': (context) => const MessagesScreen(),
          '/groups': (context) => const GroupsScreen(),
          '/courses': (context) => const CoursesScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/verify-reset-otp': (context) => const VerifyResetOtpScreen(),
          '/reset-password': (context) => const ResetPasswordScreen(),
          '/email_invites': (context) => const SendEmailInvitesScreen(),
          '/events': (context) => const EventsScreen(),
          '/guidelines': (context) => const GuidelinesScreen(),
          '/landing': (context) => const LandingPage(),
          '/files': (context) => const UserUploadsScreen(),
          '/feed': (context) => const HomeScreen(),
          '/home/community': (context) => const HomeScreenLoggedIn(stype: "community"),
          '/home/account': (context) => const HomeScreenLoggedIn(stype: "account"),
          '/home/tools': (context) => const HomeScreenLoggedIn(stype: "tools"),
          '/activity/feeds': (context) => const ActivityFeedScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/group-detail') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => GroupDetailScreen(group: args['group']),
            );
          }

          if (settings.name == '/groups/members') {
            final args = settings.arguments as Map<String, dynamic>;
            final groupId = args['groupId'];
            return MaterialPageRoute(
              builder: (_) => GroupMembersScreen(groupId: groupId),
            );
          }

          if (settings.name == '/groups/discussions') {
            final args = settings.arguments as Map<String, dynamic>;
            final group = args['slug'];
            return MaterialPageRoute(
              builder: (_) => DiscussionsScreen(groupd: group),
            );
          }

          // Uncomment if needed
          // if (settings.name == '/home/community') {
          //   final args = settings.arguments as Map<String, dynamic>;
          //   final stype = args['type'];
          //   return MaterialPageRoute(
          //     builder: (_) => MyDashboardScreen(stype: stype),
          //   );
          // }

          return null; // fallback
        },
      ),
    );
  }
}



