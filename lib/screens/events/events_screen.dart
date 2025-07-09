import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../../models/events_model.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Event> events = [];
  List<Event> upcomingEvents = [];
  List<Event> pastEvents = [];
  bool isLoading = true;
  int selectedTabIndex = 0; // 0=All, 1=Upcoming, 2=Past
  String searchQuery = '';
  Timer? _searchTimer;

  // For swipe navigation
  final PageController _pageController = PageController();
  final List<String> _tabTitles = ['All Events', 'Upcoming', 'Past'];

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadEvents() async {
    setState(() {
      isLoading = true;
    });

    try {
      final allEvents = await fetchAllEvents();
      final upcoming = await fetchUpcomingEvents();
      final past = await fetchPastEvents();

      setState(() {
        events = allEvents;
        upcomingEvents = upcoming;
        pastEvents = past;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading events: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load events')),
      );
    }
  }

  void _handleSearch(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          searchQuery = query;
        });
        _executeSearch(query);
      });
    });
  }

  Future<void> _executeSearch(String query) async {
    if (query.isEmpty) {
      loadEvents();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final results = await fetchSearchEvents(query);
      setState(() {
        events = results;
        isLoading = false;
      });
    } catch (e) {
      print("Error searching events: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to search events')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: EventSearchDelegate(
                  onSearch: _handleSearch,
                  currentQuery: searchQuery,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadEvents,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Column(
            children: [
              // Custom tab indicator
              Container(
                height: 48.0,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 0; i < _tabTitles.length; i++)
                      GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: selectedTabIndex == i
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                width: 2.0,
                              ),
                            ),
                          ),
                          child: Text(
                            _tabTitles[i],
                            style: TextStyle(
                              color: selectedTabIndex == i
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            selectedTabIndex = index;
          });
        },
        children: [
          // All Events
          _buildEventList(events,
              searchQuery.isNotEmpty
                  ? 'No results for "$searchQuery"'
                  : 'No events found'
          ),
          // Upcoming Events
          _buildEventList(upcomingEvents, 'No upcoming events'),
          // Past Events
          _buildEventList(pastEvents, 'No past events'),
        ],
      ),
    );
  }

  Widget _buildEventList(List<Event> eventList, String emptyMessage) {
    if (eventList.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: eventList.length,
      itemBuilder: (context, index) {
        final event = eventList[index];
        return _EventCard(event: event);
      },
    );
  }

  Future<List<Event>> fetchAllEvents() async {
    final apiUrl = dotenv.env['API_URL'];
    final response = await http.get(
      Uri.parse('$apiUrl/events'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List).map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<List<Event>> fetchUpcomingEvents() async {
    final apiUrl = dotenv.env['API_URL'];
    final response = await http.get(
      Uri.parse('$apiUrl/events/upcoming'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List).map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load upcoming events');
    }
  }

  Future<List<Event>> fetchPastEvents() async {
    final apiUrl = dotenv.env['API_URL'];
    final response = await http.get(
      Uri.parse('$apiUrl/events/past'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List).map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load past events');
    }
  }

  Future<List<Event>> fetchSearchEvents(String query) async {
    final apiUrl = dotenv.env['API_URL'];
    final response = await http.get(
      Uri.parse('$apiUrl/events/search?search=${Uri.encodeQueryComponent(query)}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List).map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search events');
    }
  }
}

class _EventCard extends StatelessWidget {
  final Event event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final startDate = event.startDate != null
        ? DateTime.parse(event.startDate!)
        : null;
    final endDate = event.endDate != null
        ? DateTime.parse(event.endDate!)
        : null;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _EventDetailScreen(event: event),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.featuredImage != null)
              Image.network(
                event.featuredImage!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (startDate != null)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, y').format(startDate),
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (endDate != null && !_isSameDay(startDate, endDate))
                          Text(
                            ' - ${DateFormat('MMM d, y').format(endDate)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                      ],
                    ),
                  if (startDate != null && endDate != null)
                    const SizedBox(height: 4),
                  if (startDate != null)
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('h:mm a').format(startDate),
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (endDate != null)
                          Text(
                            ' - ${DateFormat('h:mm a').format(endDate)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                      ],
                    ),
                  if (event.venue != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          event.venue!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    event.excerpt ?? event.content ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class _EventDetailScreen extends StatelessWidget {
  final Event event;

  const _EventDetailScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    final startDate = event.startDate != null
        ? DateTime.parse(event.startDate!)
        : null;
    final endDate = event.endDate != null
        ? DateTime.parse(event.endDate!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.featuredImage != null)
              Image.network(
                event.featuredImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (startDate != null) ...[
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      text: _buildDateRangeText(startDate, endDate),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.access_time,
                      text: _buildTimeRangeText(startDate, endDate),
                    ),
                  ],
                  if (event.venue != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.location_on,
                      text: event.venue!,
                    ),
                  ],
                  if (event.organizer != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.person,
                      text: 'Organizer: ${event.organizer!}',
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.content ?? 'No description available',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  String _buildDateRangeText(DateTime start, DateTime? end) {
    if (end == null || _isSameDay(start, end)) {
      return DateFormat('EEEE, MMMM d, y').format(start);
    } else {
      return '${DateFormat('EEEE, MMMM d, y').format(start)} - ${DateFormat('EEEE, MMMM d, y').format(end)}';
    }
  }

  String _buildTimeRangeText(DateTime start, DateTime? end) {
    final startTime = DateFormat('h:mm a').format(start);
    if (end == null) {
      return 'Starts at $startTime';
    } else {
      return '$startTime - ${DateFormat('h:mm a').format(end)}';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class EventSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;
  final String currentQuery;

  EventSearchDelegate({
    required this.onSearch,
    required this.currentQuery,
  });

  @override
  String get searchFieldLabel => 'Search events...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            onSearch(query);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, currentQuery);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    Future.microtask(() {
      close(context, query);
    });

    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}


