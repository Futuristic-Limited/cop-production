import 'package:flutter/material.dart';
import '../groups/groups_screen.dart';
import '../notifications/notifications_screen.dart';

class CustomizedDashboard extends StatefulWidget {
  const CustomizedDashboard({super.key});

  @override
  State<CustomizedDashboard> createState() => _CustomizedDashboardState();
}

class _CustomizedDashboardState extends State<CustomizedDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final Color primaryColor = const Color(0xFF6ABF43);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Tab Bar with icons
          // Container(
          //   alignment: Alignment.centerLeft,
          //   margin: const EdgeInsets.symmetric(horizontal: 12),
          //   child: TabBar(
          //     controller: _tabController,
          //     labelColor: primaryColor,
          //     unselectedLabelColor: Colors.grey[700],
          //     indicatorColor: primaryColor,
          //     indicatorWeight: 3,
          //     isScrollable: true,
          //     tabs: const [
          //       Tab(icon: Icon(Icons.group), text: 'Communities'),
          //       Tab(icon: Icon(Icons.timeline), text: 'Activity'),
          //       Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
          //     ],
          //   ),
          // ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),

          // Tab content (actual screens)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                GroupsScreen(),
                GroupsScreen(),
                NotificationsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:badges/badges.dart' as badges;
// import 'my_community_card.dart';
// import '../../services/community_service.dart';
//
// class CustomizedDashboard extends StatefulWidget {
//   const CustomizedDashboard({super.key});
//
//   @override
//   State<CustomizedDashboard> createState() => _CustomizedDashboardState();
// }
//
// class _CustomizedDashboardState extends State<CustomizedDashboard>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool isLoading = true;
//   final CommunityService communityService = CommunityService();
//   List<dynamic> communities = [];
//
//   final List<String> _tabs = ['My Communities', 'Activity', 'Notifications'];
//
//   @override
//   void initState() {
//     super.initState();
//     loadCommunities();
//     _tabController = TabController(length: _tabs.length, vsync: this);
//   }
//
//   Future<void> loadCommunities() async {
//     try {
//       final data = await communityService.fetchCommunities();
//       setState(() {
//         communities = data;
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading communities: $e');
//       setState(() => isLoading = false);
//     }
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
//           children: [
//       // Custom Tab Bar
//       Container(
//       decoration: BoxDecoration(
//       color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//       BoxShadow(
//       color: Color(0xFF6ABF43).withOpacity(1),
//       spreadRadius: 2,
//       blurRadius: 8,
//       offset: const Offset(0, 2),
//       )],
//     ),
//     margin: const EdgeInsets.all(12),
//     child: TabBar(
//     controller: _tabController,
//     tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
//     labelColor: Colors.white,
//     unselectedLabelColor: const Color(0xFF6ABF43),
//     indicator: BoxDecoration(
//     borderRadius: BorderRadius.circular(15),
//     color: const Color(0xFFFEBF2C),
//     ),
//     indicatorSize: TabBarIndicatorSize.tab,
//     padding: const EdgeInsets.all(4),
//     labelPadding: const EdgeInsets.symmetric(horizontal: 8),
//     ),
//     ),
//
//     // Tab Content
//     Expanded(
//     child: TabBarView(
//     controller: _tabController,
//     children: [
//
//     _buildCommunitiesTab(),
//
//     // Activity Tab
//     _buildActivityTab(),
//
//     // Notifications Tab
//     _buildNotificationsTab(),
//     ],
//     ),
//     ),
//     ],
//     ),
//     );
//   }
//
//   Widget _buildCommunitiesTab() {
//     return
//     Expanded(
//     child:
//     isLoading
//     ? const Center(child: CircularProgressIndicator())
//         :Expanded(
//     child: ListView.builder(
//     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//     itemCount: communities.length,
//     itemBuilder: (context, index) => Padding(
//     padding: const EdgeInsets.only(bottom: 10),
//     child: CommunityCard(
//     community: communities[index],
//     communityService: communityService,
//     ),
//     ),
//     ),
//     ),
//
//     );
//   }
//
//
//
//   Widget _buildActivityTab() {
//     final activities = [
//       Activity(
//         type: 'New Post',
//         community: 'Tech Enthusiasts',
//         content: 'Check out this new Flutter package!',
//         time: '2 hours ago',
//         isUnread: true,
//       ),
//       Activity(
//         type: 'Event',
//         community: 'Art Collective',
//         content: 'Gallery opening this weekend',
//         time: '1 day ago',
//         isUnread: false,
//       ),
//       Activity(
//         type: 'Discussion',
//         community: 'Fitness Group',
//         content: 'New workout routine shared',
//         time: '30 minutes ago',
//         isUnread: true,
//       ),
//     ];
//
//     return ListView.builder(
//       padding: const EdgeInsets.all(12),
//       itemCount: activities.length,
//       itemBuilder: (context, index) {
//         final activity = activities[index];
//         return _buildActivityItem(activity);
//       },
//     );
//   }
//
//   Widget _buildActivityItem(Activity activity) {
//     return Card(
//       elevation: 1,
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       color: activity.isUnread ? Colors.blue[50] : Colors.white,
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(16),
//         leading: Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: const Color(0xFF6ABF43).withOpacity(0.2),
//             borderRadius: BorderRadius.circular(25),
//           ),
//           child: Icon(
//             _getActivityIcon(activity.type),
//             color: const Color(0xFF6ABF43),
//           ),
//         ),
//         title: Text(
//           activity.type,
//           style: TextStyle(
//             fontWeight: activity.isUnread ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               activity.community,
//               style: const TextStyle(color: Colors.grey),
//             ),
//             const SizedBox(height: 4),
//             Text(activity.content),
//           ],
//         ),
//         trailing: Text(
//           activity.time,
//           style: const TextStyle(fontSize: 12, color: Colors.grey),
//         ),
//         onTap: () {
//           setState(() {
//             activity.isUnread = false;
//           });
//         },
//       ),
//     );
//   }
//
//   IconData _getActivityIcon(String type) {
//     switch (type) {
//       case 'New Post':
//         return Icons.post_add;
//       case 'Event':
//         return Icons.event;
//       case 'Discussion':
//         return Icons.forum;
//       default:
//         return Icons.notifications;
//     }
//   }
//
//   Widget _buildNotificationsTab() {
//     final notifications = [
//       NotificationItem(
//         title: 'New member joined',
//         message: 'John Doe joined Tech Enthusiasts',
//         time: '10 min ago',
//         isPending: false,
//       ),
//       NotificationItem(
//         title: 'Join request',
//         message: '3 people want to join Art Collective',
//         time: '2 hours ago',
//         isPending: true,
//       ),
//       NotificationItem(
//         title: 'Community update',
//         message: 'New rules added to Fitness Group',
//         time: '1 day ago',
//         isPending: false,
//       ),
//     ];
//
//     return ListView.builder(
//       padding: const EdgeInsets.all(12),
//       itemCount: notifications.length,
//       itemBuilder: (context, index) {
//         final notification = notifications[index];
//         return _buildNotificationItem(notification);
//       },
//     );
//   }
//
//   Widget _buildNotificationItem(NotificationItem notification) {
//     return Card(
//       elevation: 1,
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       color: notification.isPending ? Colors.orange[50] : Colors.white,
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(16),
//         leading: Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: notification.isPending
//                 ? Colors.orange.withOpacity(0.2)
//                 : const Color(0xFF6ABF43).withOpacity(0.2),
//             borderRadius: BorderRadius.circular(25),
//           ),
//           child: Icon(
//             notification.isPending ? Icons.pending : Icons.notifications,
//             color: notification.isPending ? Colors.orange : const Color(0xFF6ABF43),
//           ),
//         ),
//         title: Text(
//           notification.title,
//           style: TextStyle(
//             fontWeight: notification.isPending ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(notification.message),
//             const SizedBox(height: 4),
//             Text(
//               notification.time,
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//         trailing: notification.isPending
//             ? ElevatedButton(
//           onPressed: () {
//             // Handle approval
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF6ABF43),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//           ),
//           child: const Text(
//             'Review',
//             style: TextStyle(color: Colors.white),
//           ),
//         )
//             : null,
//       ),
//     );
//   }
// }
//
//
//
// class Activity {
//   final String type;
//   final String community;
//   final String content;
//   final String time;
//   bool isUnread;
//
//   Activity({
//     required this.type,
//     required this.community,
//     required this.content,
//     required this.time,
//     required this.isUnread,
//   });
// }
//
// class NotificationItem {
//   final String title;
//   final String message;
//   final String time;
//   final bool isPending;
//
//   NotificationItem({
//     required this.title,
//     required this.message,
//     required this.time,
//     required this.isPending,
//   });
// }