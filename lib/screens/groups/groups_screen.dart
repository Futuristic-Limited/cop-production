import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../config/intl.dart';
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
  int selectedSection = 2;
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    loadUserAndGroups();
  }

  Future<void> loadUserAndGroups() async {
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

  Widget _buildSideMenu() {
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
            _buildMenuItem(icon: Icons.timeline, text: 'Timeline', index: 0),
            _buildMenuItem(icon: Icons.person, text: 'Profile', index: 1),
            _buildMenuItem(icon: Icons.group, text: 'Groups', index: 2),
            _buildMenuItem(icon: Icons.videocam, text: 'Videos', index: 3),
            _buildMenuItem(icon: Icons.photo, text: 'Photos', index: 4),
            _buildMenuItem(icon: Icons.forum, text: 'Forums', index: 5),
            _buildMenuItem(icon: Icons.insert_drive_file, text: 'Documents', index: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required int index,
  }) {
    final isSelected = (index == selectedSection);
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        Navigator.of(context).pop();
        if (index == 1) {
          Navigator.pushNamed(context, '/profile');
        } else {
          setState(() {
            selectedSection = index;
            if (index != 2) selectedTabIndex = 0;
          });
        }
      },
    );
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

    final userJoinDate = user!.joined != null
        ? 'Joined ${SimpleDateFormatter.formatMonthYear(DateTime.parse(user!.joined!))}'
        : 'Join date unknown';
    final userStatus = user!.active != null ? 'Active now' : 'Inactive';

    return Scaffold(
      drawer: _buildSideMenu(),
      appBar: AppBar(
        title: Text(_titleForSection(selectedSection)),
      ),
      body: Column(
        children: [
          if (selectedSection == 2) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildUserHeader(userJoinDate, userStatus),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ToggleButtons(
                isSelected: [selectedTabIndex == 0, selectedTabIndex == 1],
                onPressed: (index) {
                  setState(() {
                    selectedTabIndex = index;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: Colors.green,
                color: Colors.black,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("My Groups"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("Invitations"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: _buildSectionBody(userJoinDate, userStatus),
          ),
        ],
      ),
    );
  }

  String _titleForSection(int index) {
    switch (index) {
      case 0:
        return 'Timeline';
      case 1:
        return 'Profile';
      case 2:
        return 'Groups';
      case 3:
        return 'Videos';
      case 4:
        return 'Photos';
      case 5:
        return 'Forums';
      case 6:
        return 'Documents';
      default:
        return '';
    }
  }

  Widget _buildSectionBody(String userJoinDate, String userStatus) {
    switch (selectedSection) {
      case 0:
        return _buildTimelinePlaceholder();
      case 1:
        return _buildProfilePlaceholder();
      case 2:
        return selectedTabIndex == 0 ? _buildGroupsList() : _buildInvitesList();
      case 3:
        return _buildVideosPlaceholder();
      case 4:
        return _buildPhotosPlaceholder();
      case 5:
        return _buildForumsPlaceholder();
      case 6:
        return _buildDocumentsPlaceholder();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTimelinePlaceholder() {
    return const Center(child: Text('Timeline content goes here'));
  }

  Widget _buildProfilePlaceholder() {
    return Center(
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/profile'),
        child: const Text('Go to Profile Screen'),
      ),
    );
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
                      Text(group.name,
                          style: TextStyle(fontSize: 16, color: Colors.black)),
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

  Widget _buildUserHeader(String joinDate, String status) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(user!.avatar ?? ''),
          onBackgroundImageError: (_, __) {},
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user!.name ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              Text(joinDate, style: const TextStyle(color: Colors.black)),
              Text(status, style: const TextStyle(color: Colors.green)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('${user!.followers ?? 0} followers', style: const TextStyle(color: Colors.black)),
                  const SizedBox(width: 16),
                  Text('${user!.following ?? 0} following', style: const TextStyle(color: Colors.black)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================== API METHODS ==================

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
