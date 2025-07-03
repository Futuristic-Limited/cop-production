import 'dart:convert';

import 'package:APHRC_COP/models/message_model.dart';
import 'package:APHRC_COP/screens/messages/chat_screen.dart';
import 'package:APHRC_COP/screens/messages/lottie.dart';
import 'package:APHRC_COP/services/shared_prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key, this.title});
  final String? title;

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<User> _filteredUsers = [];

  bool _isLoading = false; // shows spinner while a search is running
  bool _hasSearched = false; // true after the first query is fired

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged); // call API as user types
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /* ────────────────────────────────────────────────────────────
   * Fetch users that match the `search` string.
   * Only called when user types in the search field.
   * ─────────────────────────────────────────────────────────── */
  Future<void> fetchUsers({required String search}) async {
    // Start the spinner
    setState(() {
      _isLoading = true;
    });

    final token = await SharedPrefsService.getAccessToken();
    final apiUrl = dotenv.env['API_URL'];

    if (token == null || apiUrl == null) {
      setState(() {
        _filteredUsers = [];
        _isLoading = false;
        _hasSearched = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Access token or API URL not found')),
      );
      return;
    }

    try {
      final uri = Uri.parse(
        '$apiUrl/messages/get_all_users',
      ).replace(queryParameters: {'search': search});

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final usersJson = json.decode(response.body)['users'] as List<dynamic>;
        final users = usersJson.map((e) => User.fromJson(e)).toList();

        setState(() {
          _filteredUsers = users;
          _isLoading = false;
          _hasSearched = true;
        });
      } else {
        setState(() {
          _filteredUsers = [];
          _isLoading = false;
          _hasSearched = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed (${response.statusCode}) to fetch users'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return; // prevents setState after dispose
      setState(() {
        _filteredUsers = [];
        _isLoading = false;
        _hasSearched = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching users: $e')));
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      // Clear results & placeholder state
      setState(() {
        _filteredUsers = [];
        _hasSearched = false;
      });
      return;
    }

    fetchUsers(search: query);
  }

  Future<String?> fetchThread(int user1Id, int user2Id) async {
    final token = await SharedPrefsService.getAccessToken();
    final apiUrl = dotenv.env['API_URL'];

    if (token == null || apiUrl == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/messages/find_thread/$user1Id/$user2Id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['threadId']?.toString();
      }
    } catch (_) {
      /* ignore */
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'New Conversation')),
      body: Column(
        children: [
          // ── Search Field ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search members…',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.green,
                    width: 2,
                  ), // Active (focused) border
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                    width: 1,
                  ), // Inactive border
                ),
              ),
            ),
          ),
          // ── Content Area ───────────────────────────────────────
          Expanded(
            child:
            _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF3B3C3B)),
              ),
            )
                : _filteredUsers.isEmpty
                ? Center(
              child:
              _hasSearched
                  ? LottieEmpty(
                title:
                'Member “${_searchController.text}” Not found!',
              )
                  : LottieEmpty(title: 'Please search for members'),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.senderAvatar),
                  ),
                  title: Text(user.fullName),
                  onTap: () async {
                    final currentUserId =
                    await SharedPrefsService.getUserId();
                    if (currentUserId == null) return;

                    final threadId = await fetchThread(
                      int.parse(currentUserId),
                      int.parse(user.id),
                    );

                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => BuddyBossThreadScreen(
                          threadId: int.parse(threadId ?? '0'),
                          userId: int.parse(user.id),
                          profilePicture: user.senderAvatar,
                          userName: user.fullName,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}