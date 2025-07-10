import 'package:flutter/material.dart';
import '../../cells/community_card.dart';
import '../../cells/custom_bottom_nav_bar.dart';
import '../../services/community_service.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final CommunityService _communityService = CommunityService();
  List<dynamic> _communities = [];
  List<int> _joinedGroupIds = [];
  bool _isLoading = true;
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredCommunities = [];
  int _currentIndex = 3;

  // Scroll behavior
  final ScrollController _scrollController = ScrollController();
  final double _searchBarHeight = 80.0;
  bool _showSearchInAppBar = false;
  bool _showSearchInBody = true;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _fetchCommunities();
    _fetchJoinedGroups();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final currentOffset = _scrollController.offset;
    final scrollingUp = currentOffset < _lastScrollOffset;

    if (!scrollingUp && currentOffset > _searchBarHeight && !_showSearchInAppBar) {
      setState(() => _showSearchInAppBar = true);
      setState(() => _showSearchInBody = false);
    }
    else if (scrollingUp && currentOffset <= _searchBarHeight && _showSearchInAppBar) {
      setState(() => _showSearchInAppBar = false);
      setState(() => _showSearchInBody = true);
    }

    _lastScrollOffset = currentOffset;
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

  // Body search field with card-like appearance
  Widget _buildBodySearchField() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterCommunities,
        decoration: InputDecoration(
          hintText: 'Search communities...',
          hintStyle: TextStyle(color: Colors.black),
          prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: Colors.grey[600]),
            onPressed: () {
              _searchController.clear();
              _filterCommunities('');
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  // AppBar search field with minimal design
  Widget _buildAppBarSearchField() {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterCommunities,
        style: const TextStyle(color: Colors.black54),
        decoration: InputDecoration(
          hintText: 'Search communities...',
          hintStyle: const TextStyle(color: Colors.black54),
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 20, color: Colors.black54),
            onPressed: () {
              _searchController.clear();
              _filterCommunities('');
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(bottom: 10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearchInAppBar
            ? _buildAppBarSearchField()
            : const Text('Communities'),
        centerTitle: true,
        actions: _showSearchInAppBar
            ? null
            : [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCommunities,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearchInBody) _buildBodySearchField(),
          Expanded(child: _buildCommunityList()),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }


  Widget _buildCommunityList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
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
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredCommunities.length,
        itemBuilder: (context, index) {
          final community = _filteredCommunities[index];
          return CommunityCard(
            community: community,
            communityService: _communityService,
            joinedGroupIds: _joinedGroupIds,
          );
        },
      ),
    );
  }

  Future<void> _fetchJoinedGroups() async {
    try {
      final ids = await _communityService.getJoinedGroupIds();
      if (mounted) {
        setState(() {
          _joinedGroupIds = ids;
        });
      }
    } catch (e) {
      print('Error loading joined groups: $e');
    }
  }
}