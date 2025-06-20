// lib/screens/activity/create_activity_feed_post_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'api_service.dart';

class CreateActivityFeedPostScreen extends StatefulWidget {
  final String? groupId;

  const CreateActivityFeedPostScreen({
    super.key,
    this.groupId,
  });

  @override
  State<CreateActivityFeedPostScreen> createState() => _CreateActivityFeedPostScreenState();
}

class _CreateActivityFeedPostScreenState extends State<CreateActivityFeedPostScreen> {
  final TextEditingController _postController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isPosting = false;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (_postController.text.trim().isEmpty) return;

    setState(() => _isPosting = true);

    try {
      await _apiService.createPost(
        _postController.text.trim(),
        groupId: widget.groupId,
      );
      Navigator.pop(context, true); // Return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _submitPost,
            child: _isPosting
                ? const CircularProgressIndicator()
                : const Text('Post'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.groupId != null)
              const Text('Posting to group', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _postController,
              decoration: InputDecoration(
                hintText: 'What are you working on?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 5,
              minLines: 3,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () => _addImage(),
                  tooltip: 'Add image',
                ),
                IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: () => _addLink(),
                  tooltip: 'Add link',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addImage() {
    // Implement image attachment logic
  }

  void _addLink() {
    // Implement link attachment logic
  }
}


