import 'package:flutter/material.dart';
import '../groups/group_detail_screen.dart';
import '../../services/community_service.dart';
import '../../services/token_preference.dart';

class CommunityCard extends StatelessWidget {
  final Map<String, dynamic> community;
  final CommunityService communityService;

  const CommunityCard({
    Key? key,
    required this.community,
    required this.communityService,
  }) : super(key: key);

  void _handleJoin(BuildContext context, Map<String, dynamic> community) async {
    bool isLoggedIn = await SaveAccessTokenService.isLoggedIn();

    if (!isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    final joined = await communityService.joinCommunity(
      community['id'].toString(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joined community: ${community['name']} Successfully!'),
      ),
    );

    if (joined) {
      String? imageUrl;
      if (community['image'] is String) {
        imageUrl = community['image'];
      } else if (community['image'] is Map<String, dynamic>) {
        imageUrl = community['image']['url']?.toString();
      }

      final updatedGroup = {
        ...community,
        'id': community['id'],
        'slug': community['slug'],
        'image': imageUrl != null ? {'url': imageUrl} : null,
        'name': community['name'] ?? 'Untitled Group',
        'description': community['description'] ?? 'No description available',
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GroupDetailScreen(group: updatedGroup),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to join the group.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = community['name'] ?? 'Community';
    final avatarUrl = community['avatar_urls']?['full'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Name
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : const AssetImage('assets/default_course.jpg') as ImageProvider,
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupDetailScreen(group: community),
                    ),
                  );
                },
                child: const Text(
                  'View Group',
                  style: TextStyle(color: Color(0xFF6ABF43)),
                ),
              ),
              ElevatedButton(
                onPressed: () => _handleJoin(context, community),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFEBF2C),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Join'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
