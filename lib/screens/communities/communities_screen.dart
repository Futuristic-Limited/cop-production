import 'package:flutter/material.dart';
import '../../cells/community_card.dart';
import '../../cells/custom_bottom_nav_bar.dart';
import '../../screens/groups/group_detail_screen.dart';
import '../../services/community_service.dart';
import '../../services/token_preference.dart';
import '../../cells/community_card.dart';
import '../../cells/custom_bottom_nav_bar.dart'; // Import the CustomBottomNavBar

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final CommunityService _communityService = CommunityService();
  List<dynamic> _communities = [];
  bool _isLoading = true;
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredCommunities = [];
  int _currentIndex = 3; // Communities is the 4th item (index 3)

  @override
  void initState() {
    super.initState();
    _fetchCommunities();
  }

  Future<void> _fetchCommunities() async {
    try {
      final communities = await _communityService.fetchCommunities();
      if (mounted) {
        setState(() {
          _communities = communities;
          _filteredCommunities = communities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  void _filterCommunities(String query) {
    setState(() {
      _filteredCommunities = _communities.where((community) {
        final name = community['name']?.toString().toLowerCase() ?? '';
        final description = community['description']?['rendered']?.toString().toLowerCase() ?? '';
        return name.contains(query.toLowerCase()) ||
            description.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _refreshCommunities() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchCommunities();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // The navigation is already handled in the CustomBottomNavBar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCommunities,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCommunities,
              decoration: InputDecoration(
                hintText: 'Search communities...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterCommunities('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildCommunityList(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCommunityList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Failed to load communities'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshCommunities,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredCommunities.isEmpty) {
      return Center(
        child: _searchController.text.isEmpty
            ? const Text('No communities available')
            : const Text('No matching communities found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshCommunities,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredCommunities.length,
        itemBuilder: (context, index) {
          final community = _filteredCommunities[index];
          return CommunityCard(
            community: community,
            communityService: _communityService,
          );
        },
      ),
    );
  }
}

