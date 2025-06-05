import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/group_member_model.dart';
import '../../services/token_preference.dart';
import '../messages/chat_screen.dart';

class GroupMembersScreen extends StatefulWidget {
  final int groupId;

  const GroupMembersScreen({super.key, required this.groupId});

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
          'id': groupJson['id'],
          'name': groupJson['name'],
          'description': groupJson['description'],
          'avatarUrl': groupJson['avatarUrl'],
          'category': groupJson['category'],
          'dateCreated': groupJson['dateCreated'],
        };

        _members = membersJson
            .map((m) => GroupMember.fromJson(m as Map<String, dynamic>))
            .toList();

        // Initially filtered list = full list
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

  void _toggleFollowLocally(GroupMember member) {
    setState(() {
      member.isFollowing = !member.isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Members'),
      ),
      drawer: _buildSideMenu(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_errorMessage != null)
          ? Center(child: Text(_errorMessage!))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // REPLACED group description with search bar here
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
              ),
            ),
          ),
          const Divider(),
          if (_filteredMembers.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No members found.'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _filteredMembers.length,
                itemBuilder: (context, index) {
                  final member = _filteredMembers[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage:
                      CachedNetworkImageProvider(member.avatarUrl),
                      backgroundColor: Colors.grey[200],
                    ),
                    title: Text(member.displayName),
                    subtitle: Text('@${member.username}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => _toggleFollowLocally(member),
                          child: Text(
                            member.isFollowing ? 'Unfollow' : 'Follow',
                            style: TextStyle(
                              color: member.isFollowing
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.message),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BuddyBossThreadScreen(
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
                  );
                },
              ),
            ),
        ],
      ),
    );
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
            _buildMenuItem(
              icon: Icons.home,
              text: 'Home',
              index: 0,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            _buildMenuItem(
              icon: Icons.info,
              text: 'About',
              index: 1,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(
                  context,
                  '/groups/detail',
                  arguments: {'groupId': widget.groupId},
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.forum,
              text: 'Discussions',
              index: 2,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(
                  context,
                  '/groups/discussions',
                  arguments: {'groupId': widget.groupId},
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.people,
              text: 'Members',
              index: 3,
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedIndex = 3;
                });
              },
            ),
            _buildMenuItem(
              icon: Icons.folder,
              text: 'Files',
              index: 4,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(
                  context,
                  '/groups/files',
                  arguments: {'groupId': widget.groupId},
                );
              },
            ),
            // const Divider(),
            _buildMenuItem(
              icon: Icons.person,
              text: 'Profile',
              index: 5,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/profile');
              },
            ),
            _buildMenuItem(
              icon: Icons.group,
              text: 'Groups',
              index: 6,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/groups');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required int index,
    required VoidCallback onTap,
  }) {
    final bool isSelected = (index == _selectedIndex);
    return ListTile(
      selected: isSelected,
      onTap: onTap,
      title: Row(
        children: [
          Icon(icon, color: _aphrcGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
