import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/user_model.dart';
import '../../models/groups_model.dart';
import '../../models/group_invite_model.dart';
import '../../services/token_preference.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  User? user;
  List<Group> groups = [];
  List<GroupInvite> invitations = [];
  bool isLoading = true;
  String sortBy = 'Recently Active';
  int selectedSection = 3;

  @override
  void initState() {
    super.initState();
    loadUserAndGroups();
  }

  Future<void> loadUserAndGroups() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userData = await fetchUser();
      final invites = await fetchGroupInvites();

      setState(() {
        user = userData;
        groups = userData.joinedGroups ?? [];
        invitations = invites;
        isLoading = false;
      });
    } catch (e) {
      print("Error in loadUserAndGroups: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Failed to load user')),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titleForSection(selectedSection)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Groups'),
              Tab(text: 'Invitations'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: 'Sync',
              onPressed: () {
                loadUserAndGroups();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Syncing groups and invitations...')),
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildGroupsList(),
            _buildInvitesList(),
          ],
        ),
      ),
    );
  }

  String _titleForSection(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Timeline';
      case 2:
        return 'Profile';
      case 3:
        return 'My Groups';
      case 4:
        return 'Videos';
      case 5:
        return 'Photos';
      case 6:
        return 'Forums';
      case 7:
        return 'Documents';
      default:
        return '';
    }
  }

  Widget _buildSectionBody(String userJoinDate, String userStatus) {
    switch (selectedSection) {
      case 0:
        return _buildHomePlaceholder();
      case 1:
        return _buildTimelinePlaceholder();
      case 2:
        return _buildProfilePlaceholder();
      case 3:
        return _buildGroupsList();
      case 4:
        return _buildVideosPlaceholder();
      case 5:
        return _buildPhotosPlaceholder();
      case 6:
        return _buildForumsPlaceholder();
      case 7:
        return _buildDocumentsPlaceholder();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHomePlaceholder() {
    Future.microtask(() {
      if (ModalRoute.of(context)?.settings.name != '/home') {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
    return const SizedBox.shrink();
  }

  Widget _buildTimelinePlaceholder() {
    return const Center(child: Text('Timeline content goes here'));
  }

  Widget _buildProfilePlaceholder() {
    Future.microtask(() {
      if (ModalRoute.of(context)?.settings.name != '/profile') {
        Navigator.pushReplacementNamed(context, '/profile');
      }
    });
    return const SizedBox.shrink();
  }

  Widget _buildVideosPlaceholder() {
    return const Center(child: Text('Videos content goes here'));
  }

  Widget _buildPhotosPlaceholder() {
    return const Center(child: Text('Photos content goes here'));
  }

  Widget _buildForumsPlaceholder() {
    return const Center(child: Text('Forums content goes here'));
  }

  Widget _buildDocumentsPlaceholder() {
    return const Center(child: Text('Documents content goes here'));
  }

  Widget _buildGroupsList() {
    if (groups.isEmpty) {
      return _emptyMessage("You haven't joined any groups yet.");
    }

    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: group.avatarUrl != null
                      ? NetworkImage(group.avatarUrl!)
                      : null,
                  child: group.avatarUrl == null
                      ? const Icon(Icons.group, size: 28, color: Colors.green)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/groups/discussions',
                            arguments: {
                              'slug': group.toJson()["slug"],
                              'groupId': group.toJson()["id"].toString(),
                              'group': group.toJson()
                            },
                          );
                        },
                        child: Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        group.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => leaveGroup(group.id),
                        icon: const Icon(Icons.exit_to_app, color: Colors.red),
                        label: const Text('Leave Group', style: TextStyle(color: Colors.red)),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvitesList() {
    if (invitations.isEmpty) {
      return _emptyMessage("You have no group invitations.");
    }

    return ListView.builder(
      itemCount: invitations.length,
      itemBuilder: (context, index) {
        final invite = invitations[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(invite.groupImage),
              onBackgroundImageError: (_, __) {},
            ),
            title: Text(invite.groupName, style: const TextStyle(color: Colors.black)),
            subtitle: Text("Invited by ${invite.inviterName}", style: const TextStyle(color: Colors.black87)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => acceptInvite(invite.groupId, invite.invitationId),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => rejectInvite(invite.groupId, invite.invitationId),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyMessage(String text) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(child: Text(text, style: const TextStyle(color: Colors.black))),
    );
  }

  Future<User> fetchUser() async {
    final apiUrl = dotenv.env['API_URL'];
    final token = await SaveAccessTokenService.getAccessToken();

    final response = await http.get(
      Uri.parse('$apiUrl/groups/index'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<List<GroupInvite>> fetchGroupInvites() async {
    final apiUrl = dotenv.env['API_URL'];
    final token = await SaveAccessTokenService.getAccessToken();

    final response = await http.get(
      Uri.parse('$apiUrl/groups/invite/pending'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final invites = data['invites'] as List<dynamic>;
      return invites.map((json) => GroupInvite.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load invites');
    }
  }

  Future<void> acceptInvite(int groupId, int invitationId) async {
    final apiUrl = dotenv.env['API_URL'];
    final token = await SaveAccessTokenService.getAccessToken();

    final response = await http.post(
      Uri.parse('$apiUrl/groups/invite/accept'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'group_id': groupId,
        'invitation_id': invitationId,
      }),
    );

    if (response.statusCode == 200) {
      loadUserAndGroups();
    } else {
      print("Failed to accept invite: ${response.body}");
    }
  }

  Future<void> rejectInvite(int groupId, int invitationId) async {
    final apiUrl = dotenv.env['API_URL'];
    final token = await SaveAccessTokenService.getAccessToken();

    final response = await http.post(
      Uri.parse('$apiUrl/groups/invite/reject'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'group_id': groupId,
        'invitation_id': invitationId,
      }),
    );

    if (response.statusCode == 200) {
      loadUserAndGroups();
    } else {
      print("Failed to reject invite: ${response.body}");
    }
  }

  Future<void> leaveGroup(int groupId) async {
    final apiUrl = dotenv.env['API_URL'];
    final token = await SaveAccessTokenService.getAccessToken();

    final response = await http.post(
      Uri.parse('$apiUrl/member/leave/group'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'group_id': groupId,
      }),
    );

    if (response.statusCode == 200) {
      await loadUserAndGroups();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have left the group')),
      );
    } else {
      print("Failed to leave group: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to leave the group')),
      );
    }
  }
}


