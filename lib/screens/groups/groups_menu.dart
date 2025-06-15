// widgets/group_menu_drawer.dart
import 'package:flutter/material.dart';

class GroupMenuDrawer extends StatelessWidget {
  final Map<String, dynamic> group;
  final int selectedIndex;
  final Function(int) onTabSwitch;
  final TabController? tabController;

  const GroupMenuDrawer({
    super.key,
    required this.group,
    required this.selectedIndex,
    required this.onTabSwitch,
    this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            _buildMenuItem(
              icon: Icons.home,
              text: 'Home',
              index: 0,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/home');
              },
            ),
            _buildMenuItem(
              icon: Icons.info,
              text: 'Group Details',
              index: 1,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(
                  context,
                  '/group-detail',
                  arguments: {'group': group},
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.forum,
              text: 'Discussions',
              index: 2,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(
                  context,
                  '/groups/discussions',
                  arguments: {'slug': group['slug']},
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.people,
              text: 'Members',
              index: 3,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(
                  context,
                  '/groups/members',
                  arguments: {'groupId': group['id']},
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.folder,
              text: 'Files',
              index: 4,
              onTap: () {
                Navigator.of(context).pop();
                if (tabController != null) {
                  onTabSwitch(4);
                }
              },
            ),
            const Divider(),
            _buildMenuItem(
              icon: Icons.person,
              text: 'Profile',
              index: 5,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/profile');
              },
            ),
            _buildMenuItem(
              icon: Icons.group,
              text: 'Groups',
              index: 6,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/groups');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required int index,
    required VoidCallback onTap,
  }) {
    final isSelected = (index == selectedIndex);
    const Color _aphrcGreen = Color(0xFF8BC53F);

    return ListTile(
      selected: isSelected,
      onTap: onTap,
      title: Row(
        children: [
          Icon(
            icon,
            color: _aphrcGreen,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


