import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../screens/discussions/index.dart';

class GroupDetailScreen extends StatefulWidget {
  final Map<String, dynamic> group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  int _selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 768;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Group Detail View'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'About'),
              Tab(text: 'Discussions'),
              Tab(text: 'Members'),
              Tab(text: 'Files'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAboutSection(),
            _buildDiscussionSection(isWideScreen),
            _buildMembersSection(),
            _buildFilesSection(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    final name = widget.group['name'] ?? 'Untitled Group';
    final description = widget.group['description'];

    final descriptionText =
    description is Map<String, dynamic>
        ? description['rendered'] ?? 'No description available.'
        : (description ?? 'No description available.');

    final Map<String, dynamic>? imageMap =
    widget.group['image'] as Map<String, dynamic>?;
    final imageUrl =
    imageMap != null && imageMap['url'] != null
        ? imageMap['url'].toString()
        : null;

    final createdAt = widget.group['created_at'] ?? '';
    final category = widget.group['category'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
    return DiscussionsScreen(groupd: groupSlug);
  }

  Widget _buildMembersSection() {
    final members =
        (widget.group['members'] as List<dynamic>?)?.cast<String>() ??
            ['Benard Kiptoo', 'Jane Doe', 'John Smith'];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      itemCount: members.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder:
          (_, i) => ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(members[i]),
        trailing: const Icon(Icons.message),
      ),
    );
  }

  Widget _buildFilesSection() {
    final files =
        (widget.group['files'] as List<dynamic>?)?.cast<String>() ??
            ['Course Notes.pdf', 'Group Charter.docx'];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      itemCount: files.length,
      itemBuilder:
          (_, i) => Card(
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
// import '../../screens/discussions/index.dart';
//
// class GroupDetailScreen extends StatefulWidget {
//   final Map<String, dynamic> group;
//
//   const GroupDetailScreen({super.key, required this.group});
//
//   @override
//   State<GroupDetailScreen> createState() => _GroupDetailScreenState();
// }
//
// class _GroupDetailScreenState extends State<GroupDetailScreen> {
//   int _selectedIndex = 3;
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isWideScreen = screenWidth >= 768;
//
//     return DefaultTabController(
//       length: 4,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Group Detail View'),
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'About'),
//               Tab(text: 'Discussions'),
//               Tab(text: 'Members'),
//               Tab(text: 'Files'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             _buildAboutSection(),
//             _buildDiscussionSection(isWideScreen),
//             _buildMembersSection(),
//             _buildFilesSection(),
//           ],
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: _selectedIndex,
//           onTap: _onItemTapped,
//           items: const [
//             BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//             BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
//             BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
//             BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAboutSection() {
//     final name = widget.group['name'] ?? 'Untitled Group';
//     final description = widget.group['description'];
//
//     final descriptionText =
//         description is Map<String, dynamic>
//             ? description['rendered'] ?? 'No description available.'
//             : (description ?? 'No description available.');
//
//     final Map<String, dynamic>? imageMap =
//         widget.group['image'] as Map<String, dynamic>?;
//     final imageUrl =
//         imageMap != null && imageMap['url'] != null
//             ? imageMap['url'].toString()
//             : null;
//
//     final createdAt = widget.group['created_at'] ?? '';
//     final category = widget.group['category'] ?? '';
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (imageUrl != null && imageUrl.isNotEmpty)
//             Center(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.network(
//                   imageUrl,
//                   width: 200,
//                   height: 200,
//                   fit: BoxFit.cover,
//                   errorBuilder:
//                       (context, error, stackTrace) => Container(
//                         width: 200,
//                         height: 200,
//                         color: Colors.grey.shade200,
//                         child: const Center(
//                           child: Icon(Icons.broken_image, size: 48),
//                         ),
//                       ),
//                 ),
//               ),
//             ),
//           const SizedBox(height: 20),
//           Text(
//             name,
//             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),
//           if (category.isNotEmpty || createdAt.isNotEmpty)
//             Row(
//               children: [
//                 if (category.isNotEmpty)
//                   Chip(
//                     label: Text(category),
//                     backgroundColor: Colors.blue.shade50,
//                   ),
//                 if (category.isNotEmpty && createdAt.isNotEmpty)
//                   const SizedBox(width: 8),
//                 if (createdAt.isNotEmpty)
//                   Text(
//                     'Created on: $createdAt',
//                     style: const TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//               ],
//             ),
//           const SizedBox(height: 20),
//           Html(data: descriptionText),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDiscussionSection(bool isWideScreen) {
//     // Example static discussions. Replace with dynamic if you have real data.
//     final discussions =
//         widget.group['discussions'] as List<dynamic>? ??
//         [
//           {
//             'title': "#Self introductions section",
//             'author': "Benard",
//             'time': "3 months ago",
//             'replies': 3,
//           },
//           {
//             'title': "#General Questions",
//             'author': "Benard",
//             'time': "3 months, 1 week ago",
//             'replies': 0,
//           },
//         ];
//
//     return ListView.builder(
//       padding: EdgeInsets.symmetric(
//         horizontal: isWideScreen ? 32 : 16,
//         vertical: 20,
//       ),
//       itemCount: discussions.length,
//       itemBuilder: (context, index) {
//         final d = discussions[index] as Map<String, dynamic>;
//         return Card(
//           margin: const EdgeInsets.only(bottom: 12),
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: ListTile(
//             title: Text(
//               d['title'] ?? 'Untitled',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             subtitle: Text("Started by ${d['author'] ?? 'Unknown'}"),
//             trailing: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   "${d['replies'] ?? 0} replies",
//                   style: const TextStyle(fontSize: 12),
//                 ),
//                 Text(
//                   d['time'] ?? '',
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildMembersSection() {
//     // If you pass members list in the group data, use that. Otherwise static list.
//     final members =
//         (widget.group['members'] as List<dynamic>?)?.cast<String>() ??
//         ['Benard Kiptoo', 'Jane Doe', 'John Smith'];
//
//     return ListView.separated(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//       itemCount: members.length,
//       separatorBuilder: (_, __) => const Divider(),
//       itemBuilder:
//           (_, i) => ListTile(
//             leading: const CircleAvatar(child: Icon(Icons.person)),
//             title: Text(members[i]),
//             trailing: const Icon(Icons.message),
//           ),
//     );
//   }
//
//   Widget _buildFilesSection() {
//     // If you pass files list in the group data, use that. Otherwise static list.
//     final files =
//         (widget.group['files'] as List<dynamic>?)?.cast<String>() ??
//         ['Course Notes.pdf', 'Group Charter.docx'];
//
//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//       itemCount: files.length,
//       itemBuilder:
//           (_, i) => Card(
//             elevation: 3,
//             child: ListTile(
//               leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
//               title: Text(files[i]),
//               trailing: IconButton(
//                 icon: const Icon(Icons.download),
//                 onPressed: () {
//                   // TODO: Implement file download logic
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Download for ${files[i]} not implemented'),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//     );
//   }
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//       // TODO: Add navigation if necessary
//     });
//   }
// }