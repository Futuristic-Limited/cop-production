import 'package:flutter/material.dart';
import '../models/follower_model.dart';

class FollowerStats extends StatelessWidget {
  static const Color aphrcGreen = Color(0xFF79C148);

  final FollowerData? stats;

  const FollowerStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final followers = stats?.followers ?? 0;
    final following = stats?.following ?? 0;
    final posts = stats?.posts ?? 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: aphrcGreen.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem(label: "Followers", count: followers),
            _statItem(label: "Following", count: following),
            _statItem(label: "Posts", count: posts),
          ],
        ),
      ),
    );
  }

  Widget _statItem({required String label, required int count}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: aphrcGreen,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
