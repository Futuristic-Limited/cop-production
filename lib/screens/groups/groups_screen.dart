import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../config/intl.dart';
import '../../models/user_model.dart';
import '../../models/groups_model.dart';
import '../../models/group_invite_model.dart';
import '../../services/token_preference.dart'; // <- UPDATED HERE

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
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    loadUserAndGroups();
  }

  Future<void> loadUserAndGroups() async {
    print("Starting to load user and groups...");
    try {
      final userData = await fetchUser();
      print("User data fetched successfully.");

      final invites = await fetchGroupInvites();
      print("Group invites fetched successfully.");

      setState(() {
        user = userData;
        groups = userData.joinedGroups ?? [];
        invitations = invites;
        isLoading = false;
      });
    } catch (e, stacktrace) {
      print("Error in loadUserAndGroups: $e");
      print("Stacktrace:\n$stacktrace");
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

    final userJoinDate = user!.joined != null
        ? 'Joined ${SimpleDateFormatter.formatMonthYear(DateTime.parse(user!.joined!))}'
        : 'Join date unknown';

    final userStatus = user!.active != null ? 'Active now' : 'Inactive';

    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Groups'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Timeline'),
              Tab(text: 'Profile'),
              Tab(text: 'Groups'),
              Tab(text: 'Videos'),
              Tab(text: 'Photos'),
              Tab(text: 'Forums'),
              Tab(text: 'Documents'),
            ],
          ),
        ),
        body: Column(
          children: [
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
                fillColor: Theme.of(context).primaryColor,
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
            Expanded(
              child: selectedTabIndex == 0
                  ? _buildGroupsList()
                  : _buildInvitesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(String joinDate, String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(user!.avatar ?? ''),
              onBackgroundImageError: (_, __) {
                print("Error loading user avatar image");
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user!.name ?? '',
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(joinDate),
                  Text(status, style: const TextStyle(color: Colors.green)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('${user!.followers ?? 0} followers',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 16),
                      Text('${user!.following ?? 0} following',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Order By:'),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<String>(
                isExpanded: true,
                value: sortBy,
                items: const [
                  DropdownMenuItem(
                    value: 'Recently Active',
                    child: Text('Recently Active'),
                  ),
                  DropdownMenuItem(
                    value: 'Most Members',
                    child: Text('Most Members'),
                  ),
                  DropdownMenuItem(
                    value: 'Newly Created',
                    child: Text('Newly Created'),
                  ),
                  DropdownMenuItem(
                    value: 'Alphabetical',
                    child: Text('Alphabetical'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    sortBy = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
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
                      ? const Icon(Icons.group, size: 28)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.name,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(group.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      Text(
                        '${group.memberCount ?? 0} members · ${group.lastActive ?? "Recently active"}',
                        style: TextStyle(color: Colors.grey[600]),
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
              onBackgroundImageError: (_, __) {
                print("Error loading invite group image");
              },
            ),
            title: Text(invite.groupName),
            subtitle: Text("Invited by ${invite.inviterName}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () =>
                      acceptInvite(invite.groupId, invite.invitationId),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () =>
                      rejectInvite(invite.groupId, invite.invitationId),
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
      child: Center(child: Text(text)),
    );
  }

  // ================== API METHODS ==================

  Future<User> fetchUser() async {
    final apiUrl = dotenv.env['API_URL'];
    final token = await SaveAccessTokenService.getAccessToken(); // <- UPDATED

    print("Fetching user from $apiUrl/groups/index");

    final response = await http.get(
      Uri.parse('$apiUrl/groups/index'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print("User fetch status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("User data: ${jsonEncode(data)}");
      return User.fromJson(data['user']);
    } else {
      print("Error response: ${response.body}");
      throw Exception('Failed to load user');
    }
  }

  Future<List<GroupInvite>> fetchGroupInvites() async {
    final apiUrl = dotenv.env['API_URL'];
    final token = await SaveAccessTokenService.getAccessToken(); // <- UPDATED

    print("Fetching group invites from $apiUrl/groups/invite/pending");

    final response = await http.get(
      Uri.parse('$apiUrl/groups/invite/pending'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print("Invites fetch status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Invite data: ${jsonEncode(data)}");
      final invites = data['invites'] as List<dynamic>;
      return invites.map((json) => GroupInvite.fromJson(json)).toList();
    } else {
      print("Error response: ${response.body}");
      throw Exception('Failed to load invites');
    }
  }

  Future<void> acceptInvite(int groupId, int invitationId) async {
    final apiUrl = dotenv.env['API_URL'];
    final token = await SaveAccessTokenService.getAccessToken(); // <- UPDATED

    print("Accepting invite: groupId=$groupId, invitationId=$invitationId");

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

    print("Accept invite response status: ${response.statusCode}");

    if (response.statusCode == 200) {
      print("Invite accepted successfully.");
      loadUserAndGroups();
    } else {
      print("Failed to accept invite. Response: ${response.body}");
    }
  }

  Future<void> rejectInvite(int groupId, int invitationId) async {
    final apiUrl = dotenv.env['API_URL'];
    final token = await SaveAccessTokenService.getAccessToken(); // <- UPDATED

    print("Rejecting invite: groupId=$groupId, invitationId=$invitationId");

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

    print("Reject invite response status: ${response.statusCode}");

    if (response.statusCode == 200) {
      print("Invite rejected successfully.");
      loadUserAndGroups();
    } else {
      print("Failed to reject invite. Response: ${response.body}");
    }
  }
}