import 'package:flutter/material.dart';
import '../../services/discussions_service.dart';
import '../../models/discussions_model.dart';

class CommentReply extends StatefulWidget {
  final String post_parent;
  final Discussions discussion;

  const CommentReply({super.key, required this.discussion, required this.post_parent});

  @override
  State<CommentReply> createState() => _CommentReplyState();
}

class _CommentReplyState extends State<CommentReply> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  bool isSubmitting = false;

  Future<void> submitReply() async {
    setState(() => isSubmitting = true);

    final success = await DiscussionService().postDiscussion(
      //titleController.text,
      "my title",
      descController.text,
      post_parent: widget.post_parent,
      discussion: widget.discussion,
    );

    setState(() => isSubmitting = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post reply')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxDialogHeight = MediaQuery.of(context).size.height * 0.5;

    return AlertDialog(
      title: const Text('Reply to discussion'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: maxDialogHeight,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TextField(
              //   controller: titleController,
              //   decoration: const InputDecoration(labelText: 'Title'),
              // ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isSubmitting ? null : submitReply,
          child: isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Reply'),
        )
      ],
    );
  }
}
