import 'package:flutter/material.dart';
import '../../services/discussions_service.dart';
import '../../models/discussions_model.dart';
import 'discussion_detail_screen.dart';


// class DiscussionsScreen extends StatefulWidget {
//   const DiscussionsScreen({super.key});
//
//   @override
//   State<DiscussionsScreen> createState() => _DiscussionsScreenState();
// }
//
// class _DiscussionsScreenState extends State<DiscussionsScreen> {
class DiscussionsScreen extends StatefulWidget {
  final String groupd;

  const DiscussionsScreen({super.key, required this.groupd});

  @override
  State<DiscussionsScreen> createState() => _DiscussionsScreenState();
}

class _DiscussionsScreenState extends State<DiscussionsScreen> {
  late String groupSlug;

  List<Discussions> discussions = [];
  bool isLoading = true;
  String errorMessage = '';
  final titleController = TextEditingController();
  final descController = TextEditingController();
  bool isPosting = false;
  String groupd = "gfgp";
  String authorId = "19";

  @override
  void initState() {
    super.initState();
    groupd = widget.groupd;

    fetchDiscussions();
  }

  Future<void> fetchDiscussions() async {
    try {


      print(groupd);

      final service = DiscussionService();
      final response = await service.discussionList(groupd);
      if (response != null && response.items != null) {
        setState(() {
          discussions = response.items!;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response?.error ?? 'No discussions found.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load discussions.';
        isLoading = false;
      });
    }
  }

  Future<void> postDiscussion() async {
    final title = titleController.text.trim();
    final description = descController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both title and description')),
      );
      return;
    }

    setState(() {
      isPosting = true;
    });

    try {
      final service = DiscussionService();
      final success = await service.postDiscussion(title, description, groupd: groupd );
      if (success) {
        titleController.clear();
        descController.clear();
        await fetchDiscussions();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Discussion posted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post discussion')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred posting discussion')),
      );
    } finally {
      setState(() {
        isPosting = false;
      });
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discussions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDiscussionTableHeader(),
            const SizedBox(height: 10),
            Expanded(child: _buildDiscussionList()),
            const Divider(height: 40),
            _buildAskQuestionForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscussionTableHeader() {
    return Row(
      children: const [
        Expanded(flex: 4, child: Text('Discussions', style: TextStyle(fontWeight: FontWeight.bold , fontSize: 12))),
        Expanded(flex: 1, child: Text('Replies', style: TextStyle(fontWeight: FontWeight.bold , fontSize: 12))),
        Expanded(flex: 2, child: Text('Last Post', style: TextStyle(fontWeight: FontWeight.bold , fontSize: 12))),
      ],
    );
  }

  Widget _buildDiscussionList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    return ListView.builder(
      itemCount: discussions.length,
      itemBuilder: (context, index) {
        final d = discussions[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(_createSlideRoute(DiscussionDetailScreen(discussion: d)));
          },
          child: Card(
            elevation: 6,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.green, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.post_title ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Started by: ${d.display_name ?? 'Unknown'}', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 10)),

                        //Text('Started by: ${d.display_name ?? 'Unknown'}'),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text(
                        '${d.reply_count ?? '-'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(flex: 2, child: Text(d.last_reply_date ?? '',style: TextStyle(color: Colors.black87, fontWeight: FontWeight.normal, fontSize: 10))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PageRouteBuilder _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.3),
    );
  }

  Widget _buildAskQuestionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ask a question or share an idea', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Discussion Title',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton(
              onPressed: isPosting ? null : postDiscussion,
              child: isPosting
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
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
