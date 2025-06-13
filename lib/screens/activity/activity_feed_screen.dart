import 'package:flutter/material.dart';

class ActivityFeedScreen extends StatelessWidget {
  const ActivityFeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Activity Feed'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Groups'),
              Tab(text: 'Following'),
              Tab(text: 'Mentions'),
              Tab(text: 'Followed Groups'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActivityList(),
            _buildActivityList(),
            _buildActivityList(),
            _buildActivityList(),
            _buildActivityList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Implement create new activity
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    final activities = [
      {
        'username': 'John Doe',
        'avatar': '',
        'content': 'Just shared a new research paper on climate change',
        'time': '2 hours ago',
        'type': 'post',
        'group': 'Environmental Research'
      },
      {
        'username': 'Jane Smith',
        'avatar': '',
        'content': 'Commented on your discussion about data analysis',
        'time': '5 hours ago',
        'type': 'comment',
        'group': 'Data Science'
      },
      {
        'username': 'Alex Johnson',
        'avatar': '',
        'content': 'Mentioned you in a post about upcoming conference',
        'time': '1 day ago',
        'type': 'mention',
        'group': 'Academic Conferences'
      },
      {
        'username': 'Sarah Williams',
        'avatar': '',
        'content': 'Posted new resources in the group',
        'time': '2 days ago',
        'type': 'resource',
        'group': 'Research Methods'
      },
      {
        'username': 'Michael Brown',
        'avatar': '',
        'content': 'Started a new discussion about peer review process',
        'time': '3 days ago',
        'type': 'discussion',
        'group': 'Academic Publishing'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: activity['avatar'] != null && activity['avatar']!.isNotEmpty
                          ? NetworkImage(activity['avatar']!)
                          : const AssetImage('assets/default_avatar.png') as ImageProvider,
                      radius: 20,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['username']!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          activity['time']!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(activity['content']!),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {},
                    ),
                    const Text('5'),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: () {},
                    ),
                    const Text('2'),
                    const Spacer(),
                    if (activity['group'] != null)
                      Chip(
                        label: Text(activity['group']!),
                        backgroundColor: Colors.blue[50],
                      ),
                    if (activity['type'] == 'mention')
                      const Chip(
                        label: Text('Mention'),
                        backgroundColor: Colors.green
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
}

