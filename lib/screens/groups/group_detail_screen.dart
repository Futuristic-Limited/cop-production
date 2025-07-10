import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../screens/discussions/index.dart';
import 'group_side_menu.dart';

class GroupDetailScreen extends StatefulWidget {
  final Map<String, dynamic> group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final TabController _tabController;

  // APHRC brand green: #8BC53F
  static const Color _aphrcGreen = Color(0xFF8BC53F);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 768;

    return Scaffold(
      //drawer: _buildSideMenu(),
      drawer: GroupSideMenu(
        group: widget.group,
        selectedIndex: _selectedIndex,
        onTabSelected: _switchTab,
      ),
      appBar: AppBar(
        title: const Text('Community Detail View'),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildAboutSection(),
          _buildDiscussionSection(isWideScreen),
          _buildFilesSection(),
          _buildFilesSection(),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    final name = widget.group['name'] ?? 'Untitled Group';
    final description = widget.group['description'];

    final descriptionText = description is Map<String, dynamic>
        ? description['rendered'] ?? 'No description available.'
        : (description ?? 'No description available.');

    // Access avatarUrl directly from the group map
    final imageUrl = widget.group['avatarUrl'] as String?;

    final createdAt = widget.group['dateCreated'] ?? '';
    final category = widget.group['category'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage:
                (imageUrl != null && imageUrl.isNotEmpty)
                    ? NetworkImage(imageUrl)
                    : null,
                backgroundColor: Colors.green.shade300,
                child: (imageUrl == null || imageUrl.isEmpty)
                    ? const Icon(Icons.group, size: 40, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (category.isNotEmpty || createdAt.isNotEmpty)
            Row(
              children: [
                if (category.isNotEmpty)
                  Chip(
                    label: Text(category),
                    backgroundColor: Colors.blue.shade50,
                  ),
                if (category.isNotEmpty && createdAt.isNotEmpty)
                  const SizedBox(width: 8),
                if (createdAt.isNotEmpty)
                  Text(
                    'Created on: $createdAt',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          const SizedBox(height: 20),
          Html(data: descriptionText),
        ],
      ),
    );
  }

  Widget _buildDiscussionSection(bool isWideScreen) {
    final groupSlug = widget.group['slug'] ?? 'default-group';
    final groupId = widget.group['groupId'] ?? '20';
    final group = widget.group;
    return DiscussionsScreen(groupd: groupSlug, groupId: groupId, groupDetails: group);
  }

  Widget _buildFilesSection() {
    final files =
        (widget.group['files'] as List<dynamic>?)?.cast<String>() ??
            ['Course Notes.pdf', 'Group Charter.docx'];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      itemCount: files.length,
      itemBuilder: (_, i) => Card(
        elevation: 3,
        child: ListTile(
          leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
          title: Text(files[i]),
          trailing: IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Download for ${files[i]} not implemented'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }






  // Widget _buildSideMenu() {
  //   return Drawer(
  //     child: SafeArea(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         children: [
  //           const DrawerHeader(
  //             child: Text(
  //               'Menu',
  //               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //             ),
  //           ),
  //           _buildMenuItem(
  //             icon: Icons.home,
  //             text: 'Home',
  //             index: 0,
  //             onTap: () {
  //               Navigator.of(context).pop();
  //               Navigator.pushNamed(context, '/home');
  //             },
  //           ),
  //           _buildMenuItem(
  //             icon: Icons.forum,
  //             text: 'Discussions',
  //             index: 1,
  //             onTap: () {
  //               Navigator.of(context).pop();
  //               Navigator.pushNamed(
  //                 context,
  //                 '/groups/discussions',
  //                 arguments: {'slug': widget.group['slug']},
  //               );
  //             },
  //           ),
  //           _buildMenuItem(
  //             icon: Icons.people,
  //             text: 'Members',
  //             index: 2,
  //             onTap: () {
  //               Navigator.of(context).pop();
  //               Navigator.pushNamed(
  //                 context,
  //                 '/groups/members',
  //                 arguments: {'groupId': widget.group['id']},
  //               );
  //             },
  //           ),
  //           _buildMenuItem(
  //             icon: Icons.folder,
  //             text: 'Files',
  //             index: 3,
  //             onTap: () => _switchTab(3),
  //           ),
  //           const Divider(),
  //           _buildMenuItem(
  //             icon: Icons.person,
  //             text: 'Profile',
  //             index: 4,
  //             onTap: () {
  //               Navigator.of(context).pop();
  //               Navigator.pushNamed(context, '/profile');
  //             },
  //           ),
  //           _buildMenuItem(
  //             icon: Icons.group,
  //             text: 'Groups',
  //             index: 5,
  //             onTap: () {
  //               Navigator.of(context).pop();
  //               Navigator.pushNamed(context, '/groups');
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }









  void _switchTab(int index) {
    Navigator.of(context).pop();
    setState(() {
      _selectedIndex = index;
      _tabController.index = index;
    });
  }

  // Widget _buildMenuItem({
  //   required IconData icon,
  //   required String text,
  //   required int index,
  //   required VoidCallback onTap,
  // }) {
  //   final isSelected = (index == _selectedIndex);
  //
  //   return ListTile(
  //     selected: isSelected,
  //     onTap: onTap,
  //     title: Row(
  //       children: [
  //         Icon(
  //           icon,
  //           color: _aphrcGreen,
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Text(
  //             text,
  //             style: TextStyle(
  //               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //               color: Colors.black,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }


}