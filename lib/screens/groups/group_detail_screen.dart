import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      drawer: GroupSideMenu(
        group: widget.group,
        selectedIndex: _selectedIndex,
        onTabSelected: _switchTab,
      ),
      appBar: AppBar(
        title: Text(widget.group['name'] ?? 'Community Detail'),
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
    final membersCount = widget.group['members_count'] ?? '0';
    final status = widget.group['status'] ?? 'public';
    final role = widget.group['role'] ?? '';
    final isMember = widget.group['is_member'] ?? false;

    final coverImageHeight = MediaQuery.of(context).size.height * 0.25;
    const cardOverlap = 60.0;

    return SingleChildScrollView(
      child: Stack(
        children: [
          // Cover Image at the top (25% of screen height)
          Container(
            height: coverImageHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                  widget.group['cover_url'] ??
                      'https://upload.wikimedia.org/wikipedia/commons/3/3f/Placeholder_view_vector.svg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content with overlapping card
          Column(
            children: [
              // Empty space for the cover image (minus the overlap)
              SizedBox(height: coverImageHeight - cardOverlap),

              // Main content area
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Card with group info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row with Avatar and Basic Info
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Group Avatar
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: CachedNetworkImageProvider(
                                    widget.group['avatar_urls']['thumb'] ??
                                        'https://via.placeholder.com/150',
                                  ),
                                  backgroundColor: Colors.grey.shade300,
                                ),
                                const SizedBox(width: 16),
                                // Group Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          _buildInfoChip(
                                            icon: Icons.people_outline,
                                            text: '$membersCount ${widget.group['plural_role'] ?? 'Members'}',
                                          ),
                                          _buildInfoChip(
                                            icon: status == 'public' ? Icons.public : Icons.lock_outline,
                                            text: status,
                                          ),
                                          if (isMember)
                                            Chip(
                                              label: Text(
                                                role,
                                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                              backgroundColor: _aphrcGreen,
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),

                  // Description Section (no card)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Html(
                          data: descriptionText,
                          style: {
                            "body": Style(
                              fontSize: FontSize(16.0),
                              color: Colors.black87,
                              margin: Margins.zero,
                            ),
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Chip(
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      backgroundColor: Colors.grey[200],
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _aphrcGreen),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionSection(bool isWideScreen) {
    final groupSlug = widget.group['slug'] ?? 'default-group';
    final groupId = widget.group['id']?.toString() ?? '20';
    final group = widget.group;
    return DiscussionsScreen(
      groupd: groupSlug,
      groupId: groupId,
      groupDetails: group,
    );
  }

  Widget _buildFilesSection() {
    final files =
        (widget.group['files'] as List<dynamic>?)?.cast<String>() ??
            ['Course Notes.pdf', 'Group Charter.docx'];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: files.length,
      itemBuilder: (_, i) => Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
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

  void _switchTab(int index) {
    Navigator.of(context).pop();
    setState(() {
      _selectedIndex = index;
      _tabController.index = index;
    });
  }
}