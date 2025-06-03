import 'package:flutter/material.dart';
import '../screens/groups/group_detail_screen.dart';
import '../../services/community_service.dart';
import '../../services/token_preference.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart'; // You might not need this import

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
      // Redirect to login if user is not logged in
      Navigator.pushNamed(context, '/login'); // Adjust this route if needed
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

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GroupDetailScreen(group: updatedGroup),
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to join the group.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = community['name'] ?? 'Community';
    final description = community['description']['rendered'] ?? '';
    final avatarUrl = community['avatar_urls']?['full'] ?? '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : const AssetImage('assets/default_course.jpg')
                          as ImageProvider,
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Html(data: description),
            const SizedBox(height: 10),
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
                  child: const Text('Read More'),
                ),
                ElevatedButton(
                  onPressed: () => _handleJoin(context, community),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Join Group'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
