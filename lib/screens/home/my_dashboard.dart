import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import 'package:APHRC_COP/files/UserUploadsScreen.dart';
import '../notifications/notifications_screen.dart';
import '../messages/messages_screen.dart';
import '../groups/groups_screen.dart';

// void main() {
//   runApp(MaterialApp(
//     home: MyDashboardScreen(stype: 'home'),
//   ));
// }

class MyDashboardScreen extends StatefulWidget {
  final dynamic stype;

  const MyDashboardScreen({super.key, required this.stype});

  @override
  State<MyDashboardScreen> createState() => _MyDashboardScreenState();
}

class _MyDashboardScreenState extends State<MyDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<_TabItem> _tabs;
  late Widget _activeScreen;

  @override
  void initState() {
    super.initState();

    _tabs = _getTabsByType(widget.stype);
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);

    _activeScreen = _buildScreen(0);
  }

  List<_TabItem> _getTabsByType(String type) {
    switch (type) {
      case 'home':
        return [
          _TabItem(icon: Icons.home, label: 'Home'),
          _TabItem(icon: Icons.group, label: 'Groups'),
          _TabItem(icon: Icons.message, label: 'Messages'),
        ];
      case 'account':
        return [
          _TabItem(icon: Icons.person, label: 'Profile'),
          _TabItem(icon: Icons.settings, label: 'Settings'),
          _TabItem(icon: Icons.logout, label: 'Logout'),
        ];
      case 'tools':
        return [
          _TabItem(icon: Icons.folder, label: 'Files'),
          _TabItem(icon: Icons.notifications, label: 'Notifications'),
        ];
      default:
        return [
          _TabItem(icon: Icons.groups, label: 'My Communities'),
          _TabItem(icon: Icons.timeline, label: 'Activity'),
          _TabItem(icon: Icons.notifications, label: 'Notifications'),
        ];
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _activeScreen = _buildScreen(_tabController.index);
      });
    }
  }

  Widget _buildScreen(int index) {
    String label = _tabs[index].label;

    switch (label) {
      //case 'Home':
        //return ProfileScreen();
      case 'Groups':
        return GroupsScreen();
      case 'Messages':
        return MessagesScreen();
      case 'Profile':
        return ProfileScreen();
      case 'Settings':
        return SettingsScreen();
      case 'Logout':
        return Center(child: Text('No screen for "$label"'));
      case 'Files':
        return UserUploadsScreen();
      case 'Notifications':
        return NotificationsScreen();
      case 'My Communities':
        return Center(child: Text('No screen for "$label"'));
      case 'Activity':
        return Center(child: Text('No screen for "$label"'));
      default:
        return Center(child: Text('No screen for "$label"'));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24, left: 12, right: 12, bottom: 8),
            child: TabBar(
              controller: _tabController,
              tabs: _tabs
                  .map((tab) => Tab(
                icon: Icon(tab.icon),
                text: tab.label,
              ))
                  .toList(),
              labelColor: const Color(0xFF6ABF43),
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: const Color(0xFF6ABF43),
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 13,
              ),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
          ),
          Expanded(
            child: _activeScreen,
          ),
        ],
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;

  _TabItem({required this.icon, required this.label});
}

// --- Sample Screens ---
//
// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(child: Text('Home Screen', style: TextStyle(fontSize: 24)));
//   }
// }
//
// class GroupsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(child: Text('Groups Screen', style: TextStyle(fontSize: 24)));
//   }
// }
//
// class MessagesScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(child: Text('Messages Screen', style: TextStyle(fontSize: 24)));
//   }
// }
//
// class ProfileScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(child: Text('Profile Screen', style: TextStyle(fontSize: 24)));
//   }
// }
//
// class SettingsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(child: Text('Settings Screen', style: TextStyle(fontSize: 24)));
//   }
// }
//
// class LogoutScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(child: Text('Logout Screen', style: TextStyle(fontSize: 24)));
//   }
// }
//
// class FilesScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(child: Text('Files Screen', style: TextStyle(fontSize: 24)));
//   }
// }
//
// class NotificationsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(child: Text('Notifications Screen', style: TextStyle(fontSize: 24)));
//   }
// }
//
// class CommunitiesScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(child: Text('My Communities Screen', style: TextStyle(fontSize: 24)));
//   }
// }
//
// class ActivityScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(child: Text('Activity Screen', style: TextStyle(fontSize: 24)));
//   }
// }
//
















// import 'package:flutter/material.dart';
//
// class MyDashboardScreen extends StatefulWidget {
//   final dynamic stype;
//
//   const MyDashboardScreen({super.key, required this.stype});
//
//   @override
//   State<MyDashboardScreen> createState() => _MyDashboardScreenState();
// }
//
// class _MyDashboardScreenState extends State<MyDashboardScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late List<_TabItem> _tabs;
//   late Widget _activeScreen;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _tabs = _getTabsByType(widget.stype);
//     _tabController = TabController(length: _tabs.length, vsync: this);
//     _tabController.addListener(_handleTabSelection);
//
//     _activeScreen = _buildScreen(0);
//   }
//
//   List<_TabItem> _getTabsByType(String type) {
//     switch (type) {
//       case 'home':
//         return [
//           _TabItem(icon: Icons.home, label: 'Home'),
//           _TabItem(icon: Icons.group, label: 'Groups'),
//           _TabItem(icon: Icons.message, label: 'Messages'),
//         ];
//       case 'account':
//         return [
//           _TabItem(icon: Icons.person, label: 'Profile'),
//           _TabItem(icon: Icons.settings, label: 'Settings'),
//           _TabItem(icon: Icons.logout, label: 'Logout'),
//         ];
//       case 'tools':
//         return [
//           _TabItem(icon: Icons.folder, label: 'Files'),
//           _TabItem(icon: Icons.notifications, label: 'Notifications'),
//         ];
//       default:
//         return [
//           _TabItem(icon: Icons.groups, label: 'My Communities'),
//           _TabItem(icon: Icons.timeline, label: 'Activity'),
//           _TabItem(icon: Icons.notifications, label: 'Notifications'),
//         ];
//     }
//   }
//
//   void _handleTabSelection() {
//     if (_tabController.indexIsChanging) {
//       setState(() {
//         _activeScreen = _buildScreen(_tabController.index);
//       });
//     }
//   }
//
//   Widget _buildScreen(int index) {
//     return Center(
//       child: Text(
//         'Content for ${_tabs[index].label}',
//         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 24, left: 12, right: 12, bottom: 8),
//             child: TabBar(
//               controller: _tabController,
//               tabs: _tabs
//                   .map(
//                     (tab) => Tab(
//                   icon: Icon(tab.icon),
//                   text: tab.label,
//                 ),
//               )
//                   .toList(),
//               labelColor: const Color(0xFF6ABF43),
//               unselectedLabelColor: Colors.grey[600],
//               indicatorColor: const Color(0xFF6ABF43),
//               indicatorWeight: 3,
//               indicatorSize: TabBarIndicatorSize.label,
//               labelStyle: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 13,
//               ),
//               unselectedLabelStyle: const TextStyle(
//                 fontWeight: FontWeight.normal,
//                 fontSize: 13,
//               ),
//               overlayColor: MaterialStateProperty.all(Colors.transparent),
//             ),
//           ),
//           //const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
//           Expanded(
//             child: _activeScreen,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _TabItem {
//   final IconData icon;
//   final String label;
//
//   _TabItem({required this.icon, required this.label});
// }



// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:badges/badges.dart' as badges;
// import 'my_community_card.dart';
// import '../../services/community_service.dart';
//
// class MyDashboardScreen extends StatefulWidget {
//   final dynamic stype;
//
//   const MyDashboardScreen({super.key, required this.stype});
//
//   @override
//   State<MyDashboardScreen> createState() => _CustomizedDashboardState();
// }
//
// class _CustomizedDashboardState extends State<MyDashboardScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool isLoading = true;
//   final CommunityService communityService = CommunityService();
//   List<dynamic> communities = [];
//
//   late  List<String> _tabs = ['My Communities', 'Activity', 'Notifications'];
//
//   @override
//   void initState() {
//     super.initState();
//     //loadCommunities();
//     switch (widget.stype) {
//       case 'home':
//         _tabs = ['Home', 'Groups', 'Messages'];
//         break;
//       case 'account':
//         _tabs = ['Profile', 'Settings', 'Logout'];
//         break;
//       case 'tools':
//         _tabs = ['Files', 'Notifications'];
//         break;
//       default:
//         _tabs = ['My Communities', 'Activity', 'Notifications'];
//     }
//
//     _tabController = TabController(length: _tabs.length, vsync: this);
//   }
//
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: Column(
//         children: [
//           // Custom Tab Bar
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Color(0xFF6ABF43).withOpacity(1),
//                   spreadRadius: 2,
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 )],
//             ),
//             margin: const EdgeInsets.all(12),
//             child: TabBar(
//               controller: _tabController,
//               tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
//               labelColor: Colors.white,
//               unselectedLabelColor: const Color(0xFF6ABF43),
//               indicator: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 color: const Color(0xFFFEBF2C),
//               ),
//               indicatorSize: TabBarIndicatorSize.tab,
//               padding: const EdgeInsets.all(4),
//               labelPadding: const EdgeInsets.symmetric(horizontal: 8),
//             ),
//           ),
//
//           // Tab Content
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//
//                 //_buildCommunitiesTab(),
//
//                 // Activity Tab
//                 //_buildActivityTab(),
//
//                 // Notifications Tab
//                // _buildNotificationsTab(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
// }
//
//
//
