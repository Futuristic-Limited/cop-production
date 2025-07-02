import 'package:flutter/material.dart';
import '../../models/discussions_model.dart';
import '../../services/discussions_service.dart';
import 'package:flutter_html/flutter_html.dart';
import 'comment_reply.dart';

class DiscussionDetailScreen extends StatefulWidget {
  final Discussions discussion;

  const DiscussionDetailScreen({super.key, required this.discussion, required Map<String, Object?> group});

  @override
  State<DiscussionDetailScreen> createState() => _DiscussionDetailScreenState();
}

class _DiscussionDetailScreenState extends State<DiscussionDetailScreen> {
  List<Discussions> replies = [];
  bool isLoading = true;
  String errorMessage = '';
  final titleController = TextEditingController();
  final descController = TextEditingController();
  bool isPosting = false;
  bool isFormVisible = false;

  @override
  void initState() {
    super.initState();
    fetchReplies();
  }

  Future<void> fetchReplies() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final service = DiscussionService();
      final response = await service.discussionReplies(widget.discussion.ID!);
      if (response != null && response.items != null) {
        setState(() {
          replies = response.items!;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response?.error ?? 'No replies found.';
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        errorMessage = 'Failed to load replies.';
        isLoading = false;
      });
    }
  }

  Future<void> submitReply() async {
    setState(() => isPosting = true);
    final success = await DiscussionService().postDiscussion(
      //titleController.text,
      "discussion",
      descController.text,
      post_parent: widget.discussion.ID!,
      discussion: widget.discussion,
    );
    setState(() => isPosting = false);
    if (success) {
      titleController.clear();
      descController.clear();
      fetchReplies();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post reply')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: screenWidth,
          height: double.infinity,
          color: Colors.white,
          child: Column(
            children: [
              AppBar(
                automaticallyImplyLeading: true,
                title: const Text('Replies'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20), // 5px left and right margin
                padding: const EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      widget.discussion.post_date ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Expanded(
                          child: Text(
                            'Creator',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Topic',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.discussion.display_name ?? '',
                            style: const TextStyle(color: Colors.black87, fontSize: 12),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.discussion.post_title ?? '',
                            style: const TextStyle(color: Colors.black87, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 10),
                  ],
                ),
              ),



              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: replies.length,
                  itemBuilder: (context, index) => _buildReplyCard(replies[index], 0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(isFormVisible ? Icons.keyboard_arrow_down : Icons.edit),
                        onPressed: () {
                          setState(() {
                            isFormVisible = !isFormVisible;
                          });
                        },
                      ),
                    ),
                    Visibility(
                      visible: isFormVisible,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: _buildAskQuestionForm(),
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
    );
  }

  Widget _buildReplyCard(Discussions reply, int indentLevel) {
    final double leftMargin = indentLevel * 24.0;
    return Container(
      margin: EdgeInsets.only(left: leftMargin, bottom: 16),
      child: Card(
        elevation: 6,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(reply.post_date ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF7BC148))),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('#${reply.ID}', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blueGrey.shade200,
                    child: Text(
                      reply.display_name?.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(reply.display_name ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerLeft, child: Html(data: reply.post_content ?? '')),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (context) => CommentReply(discussion: widget.discussion, post_parent: reply.ID!),
                    );
                    if (result == true) {
                      fetchReplies();
                    }
                  },
                  child: const Text('Reply'),
                ),
              ),
              if (reply.children.isNotEmpty)
                ...reply.children.map((childReply) => _buildReplyCard(childReply, indentLevel + 1))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAskQuestionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Comment on discussion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        // TextField(
        //   controller: titleController,
        //   decoration: const InputDecoration(labelText: 'Discussion Title', border: OutlineInputBorder()),
        // ),
        const SizedBox(height: 12),
        TextField(
          controller: descController,
          decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
          maxLines: 4,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton(
              onPressed: isPosting ? null : submitReply,
              child: isPosting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Post'),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {
                titleController.clear();
                descController.clear();
              },
              child: const Text('Discard Draft'),
            ),
          ],
        )
      ],
    );
  }
}

