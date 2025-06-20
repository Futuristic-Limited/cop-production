import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/group_member_model.dart';
import '../../services/token_preference.dart';
import '../messages/chat_screen.dart';
import '../groups/group_side_menu.dart'; // Import the side menu

class GroupMembersScreen extends StatefulWidget {
  final int groupId;

  const GroupMembersScreen({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupMembersScreen> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersScreen> {
  int _selectedIndex = 2;
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _groupData;
  List<GroupMember> _members = [];
  List<GroupMember> _filteredMembers = [];
  TextEditingController _searchController = TextEditingController();
  static const Color _aphrcGreen = Color(0xFF8BC53F);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Add scaffold key

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchGroupMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMembers = _members.where((member) {
        return member.displayName.toLowerCase().contains(query) ||
            member.username.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Add tab switching function
  void _switchTab(int index) {
    Navigator.of(context).pop();
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _fetchGroupMembers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final apiUrl = dotenv.env['API_URL'];
    final token = await SaveAccessTokenService.getAccessToken();

    if (apiUrl == null || apiUrl.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'API_URL not set in .env.';
      });
      return;
    }

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Access token not found.';
      });
      return;
    }

    try {
      final url = Uri.parse('$apiUrl/groups/members/${widget.groupId}');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final groupJson = data['group'] as Map<String, dynamic>?;
        final membersJson = data['members'] as List<dynamic>?;

        if (groupJson == null || membersJson == null) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Malformed response from server.';
          });
          return;
        }

        _groupData = {
          'id': int.tryParse(groupJson['id'].toString()) ?? 0,
          'name': groupJson['name'],
          'description': groupJson['description'],
          'avatarUrl': groupJson['avatarUrl'],
          'category': groupJson['category'],
          'slug': groupJson['slug'],
          'dateCreated': groupJson['dateCreated'],
        };

        _members = membersJson
            .map((m) => GroupMember.fromJson(m as Map<String, dynamic>))
            .toList();

        _filteredMembers = _members;

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load members (${response.statusCode}).';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching members: $e';
      });
    }
  }

  Future<bool> _followUser(int targetUserId) async {
    final apiUrl = dotenv.env['API_URL'];
    final token = await SaveAccessTokenService.getAccessToken();
    if (apiUrl == null || token == null) return false;

    final url = Uri.parse('$apiUrl/follow/$targetUserId');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to follow user: ${response.statusCode}, ${response.body}');
      return false;
    }
  }

  Future<bool> _unfollowUser(int targetUserId) async {
    final apiUrl = dotenv.env['API_URL'];
    final token = await SaveAccessTokenService.getAccessToken();
    if (apiUrl == null || token == null) return false;

    final url = Uri.parse('$apiUrl/unfollow/$targetUserId');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to unfollow user: ${response.statusCode}, ${response.body}');
      return false;
    }
  }

  void _toggleFollowStatus(GroupMember member) async {
    final bool currentlyFollowing = member.followStatus == 'unfollow';

    // Optimistic update
    setState(() {
      member.followStatus = currentlyFollowing ? 'follow' : 'unfollow';
    });

    bool success = false;

    if (!currentlyFollowing) {
      // User wants to follow
      success = await _followUser(member.id);
    } else {
      // User wants to unfollow
      success = await _unfollowUser(member.id);
    }

    if (!success) {
      // Revert state if API call fails
      setState(() {
        member.followStatus = currentlyFollowing ? 'unfollow' : 'follow';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to ${currentlyFollowing ? 'unfollow' : 'follow'} user.',
          ),
        ),
      );
    }
  }

  String _getFollowLabel(String status) {
    return status == 'unfollow' ? 'Unfollow' : 'Follow';
  }

  Color _getFollowColor(String status) {
    return status == 'unfollow' ? Colors.red : _aphrcGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Add scaffold key
      drawer: GroupSideMenu(
        group: _groupData ?? {}, // Provide empty map if null
        selectedIndex: _selectedIndex,
        onTabSelected: _switchTab,
      ),
      appBar: AppBar(
        title: const Text('Group Members'),
        backgroundColor: _aphrcGreen,
        foregroundColor: Colors.white,
        leading: IconButton( // Add menu button
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_errorMessage != null)
          ? Center(child: Text(_errorMessage!))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search members...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          const Divider(),
          if (_filteredMembers.isEmpty)
            const Expanded(
              child: Center(child: Text('No members found.')),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _filteredMembers.length,
                itemBuilder: (context, index) {
                  final member = _filteredMembers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      leading: CircleAvatar(
                        radius: 24,
                        child: ClipOval(
                          child: (member.avatarUrl.isNotEmpty)
                              ? CachedNetworkImage(
                            imageUrl: member.avatarUrl,
                            placeholder: (context, url) => Image.asset('assets/default_avatar.png'),
                            errorWidget: (context, url, error) => Image.asset('assets/default_avatar.png'),
                            fit: BoxFit.cover,
                            width: 48,
                            height: 48,
                          )
                              : Image.asset('assets/default_avatar.png'),
                        ),
                      ),
                      title: Text(
                        member.displayName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('@${member.username}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: _getFollowColor(
                                  member.followStatus)
                                  .withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () =>
                                _toggleFollowStatus(member),
                            child: Text(
                              _getFollowLabel(member.followStatus),
                              style: TextStyle(
                                color: _getFollowColor(
                                    member.followStatus),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.message,
                                color: _aphrcGreen),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BuddyBossThreadScreen(
                                        threadId: 0,
                                        userId: member.id,
                                        userName: member.displayName,
                                        profilePicture: member.avatarUrl,
                                      ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}


