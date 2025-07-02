import 'package:flutter/material.dart';
import '../screens/discussions/index.dart';
import '../screens/groups/group_detail_screen.dart';
import '../../services/community_service.dart';
import '../../services/token_preference.dart';

class CommunityCard extends StatelessWidget {
  final Map<String, dynamic> community;
  final CommunityService communityService;
  final List<int> joinedGroupIds;

  const CommunityCard({
    Key? key,
    required this.community,
    required this.communityService,
    required this.joinedGroupIds,
  }) : super(key: key);

  bool get isJoined {
    final groupId = int.tryParse(community['id']?.toString() ?? '');
    return groupId != null && joinedGroupIds.contains(groupId);
  }

  void _handleJoin(BuildContext context, Map<String, dynamic> community) async {
    final isLoggedIn = await SaveAccessTokenService.isLoggedIn();
    if (!isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2.0,
            ),
            const SizedBox(width: 12),
            Text('Joining ${community['name'] ?? 'group'}...'),
          ],
        ),
        duration: const Duration(seconds: 30), // Long duration to allow for operation
      ),
    );

    try {
      final joined = await communityService.joinCommunity(
        community['id'].toString(),
      );

      // Dismiss the loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (joined) {
        final updatedGroup = {
          ...community,
          'image': _getImageUrl(community),
          'name': community['name'] ?? 'Untitled Group',
          'description': community['description'] ?? 'No description available',
          'slug': community['slug'] ?? 'No slug available'
        };

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully joined ${community['name'] ?? 'the group'}!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            // builder: (_) => GroupDetailScreen(group: updatedGroup),
            builder: (_) => DiscussionsScreen(groupd: community['slug'], groupId: community['id'].toString(), groupDetails: community),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to join the group. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Dismiss the loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String? _getImageUrl(Map<String, dynamic> community) {
    if (community['image'] is String) {
      return community['image'];
    } else if (community['image'] is Map<String, dynamic>) {
      return community['image']['url']?.toString();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final name = community['name'] ?? 'Community';
    final avatarUrl = community['avatar_urls']?['full'] ?? '';
    final String descriptionRaw = community['description']?['rendered'] ?? '';
    final String description = _stripHtml(descriptionRaw).trim();
    final String shortDescription =
    description.length > 100
        ? '${description.substring(0, 100)}...'
        : description;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6ABF43).withOpacity(0.3), // Green shadow
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFFE8F5E9),
                backgroundImage:
                avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : const AssetImage('assets/default_course.jpg')
                as ImageProvider,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF388E3C),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      shortDescription,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GroupDetailScreen(group: community),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4CAF50),
                            side: const BorderSide(color: Color(0xFF4CAF50)),
                          ),
                          child: const Text("Read More"),
                        ),
                        const SizedBox(width: 8),
                        if (isJoined)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Member",
                              style: TextStyle(color: Colors.green),
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: () => _handleJoin(context, community),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF66BB6A),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(80, 35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Join"),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _stripHtml(String htmlText) {
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }
}
//
