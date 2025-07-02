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
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Failed to load user'),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Communities'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Communities'),
              Tab(text: 'Invitations'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.sync, color: Colors.grey),
              tooltip: 'Sync',
              onPressed: () {
                loadUserAndGroups();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Syncing groups and invitations...'),
                  ),
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

  Widget _buildGroupsList() {
    if (groups.isEmpty) {
      return _buildEmptyState(
        icon: Icons.group,
        title: "No Communities Yet",
        message: "You haven't joined any communities yet.",
        actionText: "Explore communities to join",
      );
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
                      ? const Icon(
                    Icons.group,
                    size: 28,
                    color: Colors.grey,
                  )
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
                              'group': group.toJson(),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () => leaveGroup(group.id),
                            icon: const Icon(Icons.exit_to_app, color: Colors.grey),
                            label: const Text('Leave Group', style: TextStyle(color: Colors.grey)),
                          ),
                          TextButton.icon(
                            onPressed: () => inviteToGroup(group.id),
                            icon: const Icon(Icons.person_add_alt_1, color: Colors.grey),
                            label: const Text('Invite', style: TextStyle(color: Colors.grey)),
                          ),
                        ],
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
      return _buildEmptyState(
        icon: Icons.mail_outline,
        title: "No Invitations",
        message: "You don't have any pending community invitations.",
        actionText: "Ask community admins to invite you",
      );
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
            title: Text(
              invite.groupName,
              style: const TextStyle(color: Colors.black),
            ),
            subtitle: Text(
              "Invited by ${invite.inviterName}",
              style: const TextStyle(color: Colors.black87),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.grey),
                  onPressed: () => acceptInvite(invite.groupId, invite.invitationId),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => rejectInvite(invite.groupId, invite.invitationId),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required String actionText,
    Color iconColor = Colors.grey,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: iconColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              actionText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation accepted successfully'),
        ),
      );
    } else {
      print("Failed to accept invite: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to accept invitation'),
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation declined'),
        ),
      );
    } else {
      print("Failed to reject invite: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to decline invitation'),
        ),
      );
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
      body: jsonEncode({'group_id': groupId}),
    );

    if (response.statusCode == 200) {
      await loadUserAndGroups();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have left the community'),
        ),
      );
    } else {
      print("Failed to leave group: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to leave the community'),
        ),
      );
    }
  }

  Future<void> inviteToGroup(int groupId) async {
    final inviteeController = TextEditingController();
    final messageController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Invite to Community',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: inviteeController,
                  decoration: const InputDecoration(
                    labelText: 'User Email or Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Optional Message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (inviteeController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter user details'),
                            ),
                          );
                          return;
                        }

                        await _sendGroupInvite(
                          groupId,
                          inviteeController.text,
                          messageController.text,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Send Invite'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendGroupInvite(
      int groupId,
      String invitee,
      String message,
      ) async {
    final apiUrl = dotenv.env['API_URL'];
    final token = await SaveAccessTokenService.getAccessToken();

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/groups/send/invites'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'group_id': groupId,
          'user_ids': [invitee],
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invite sent successfully'),
          ),
        );
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error['message'] ?? 'Failed to send invite'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
        ),
      );
    }
  }
}


