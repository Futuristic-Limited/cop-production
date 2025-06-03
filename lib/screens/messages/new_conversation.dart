import 'dart:convert';

import 'package:APHRC_COP/models/message_model.dart';
import 'package:APHRC_COP/screens/messages/chat_screen.dart';
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
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    fetchUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchUsers({String search = ''}) async {
    final token = await SharedPrefsService.getAccessToken();
    final apiUrl = dotenv.env['API_URL'];

    if (token == null) {
      setState(() {
        _allUsers = [];
        _filteredUsers = [];
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Access token not found')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse(
        '$apiUrl/messages/get_all_users',
      ).replace(queryParameters: {if (search.isNotEmpty) 'search': search});

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final usersJson = jsonData['users'] as List<dynamic>;
        final users = usersJson.map((e) => User.fromJson(e)).toList();

        setState(() {
          _allUsers = users;
          _filteredUsers = users;
          _isLoading = false;
        });
      } else {
        setState(() {
          _allUsers = [];
          _filteredUsers = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch users (${response.statusCode})'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return; // prevents calling setState after dispose
      setState(() {
        _allUsers = [];
        _filteredUsers = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching users: $e')));
    }
  }

  Future<String?> fetchThread(int user1Id, int user2Id) async {
    final token = await SharedPrefsService.getAccessToken();
    final apiUrl = dotenv.env['API_URL'];

    if (token == null) {
      return null;
    }

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
        print('Raw threadId from API: ${data['threadId']}');
        print('Type: ${data['threadId'].runtimeType}');

        return data['threadId']?.toString();
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching thread: $e');
      return null;
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    fetchUsers(search: query);
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _filteredUsers = _allUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Color.fromARGB(137, 11, 11, 11),
            ),
          ),
          style: const TextStyle(
            color: Color.fromARGB(255, 6, 6, 6),
            fontSize: 18,
          ),
          cursorColor: const Color.fromARGB(255, 10, 10, 10),
        )
            : Text(widget.title ?? 'New Conversation'),
        actions: [
          _isSearching
              ? IconButton(
            icon: const Icon(Icons.close),
            onPressed: _stopSearch,
          )
              : IconButton(
            icon: const Icon(Icons.search),
            onPressed: _startSearch,
          ),
        ],
      ),
      body:
      _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 28, 196, 107),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Searching users...',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
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
              final user1 = await SharedPrefsService.getUserId();
              if (user1 == null) {
                // Handle null case
                return;
              }

              final threadId = await fetchThread(
                int.parse(user1),
                int.parse(user.id),
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ThreadScreen(
                    threadId:
                    threadId?.toString(), // new conversation
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
    );
  }
}

