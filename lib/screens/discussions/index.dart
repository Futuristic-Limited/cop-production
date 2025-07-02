import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../services/discussions_service.dart';
import '../../models/discussions_model.dart';
import '../../services/shared_prefs_service.dart';
import '../groups/group_side_menu.dart';
import 'discussion_detail_screen.dart';
import 'discussion_post_form.dart';

class DiscussionsScreen extends StatefulWidget {
  final String groupd;
  final String? groupId;
  final Map<String, dynamic> groupDetails;

  const DiscussionsScreen({
    super.key,
    required this.groupd,
    this.groupId,
    required this.groupDetails,
  });

  @override
  State<DiscussionsScreen> createState() => _DiscussionsScreenState();
}

class _DiscussionsScreenState extends State<DiscussionsScreen> {
  late String groupSlug;
  List<Discussions> discussions = [];
  bool isLoading = true;
  String errorMessage = '';
  String groupd = "gfgp";
  bool _isFormVisible = false;
  int? _editingIndex;
  final TextEditingController _editController = TextEditingController();
  String currentUserId = "";
  String currentUserRole = "bbp_participant";
  int _selectedIndex = 0; // Add this
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _switchTab(int index) {
    Navigator.of(context).pop();
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    groupd = widget.groupd;
    fetchDiscussions();

    DiscussionService.getUserId().then((value) {
      setState(() {
        currentUserId = value!;
      });
    });

    SharedPrefsService.getUserRole().then((value) {
      setState(() {
        currentUserRole = value!;
      });

    });
  }

  Future<void> fetchDiscussions() async {
    try {
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

      if(currentUserRole == 'administrator' || currentUserRole == 'author' ||
      currentUserRole == 'bbp_moderator'
      ){
        _isFormVisible = true;
      }else{
        _isFormVisible = false;
      }


    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load discussions.';
        isLoading = false;
      });
    }
  }

  void _showEditPopup(int index) {
    _editingIndex = index;
    _editController.text = discussions[index].post_content ?? '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Edit Post',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _editController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (_editingIndex != null) {
                          final success = await DiscussionService.discussionEdit(
                            discussions[_editingIndex!].ID.toString(),
                            _editController.text,
                          );
                          if (success) {
                            fetchDiscussions();
                          }
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Post',
                        style: TextStyle(color: Colors.white),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Add this
      drawer: GroupSideMenu( // Add this drawer
        group: widget.groupDetails,
        selectedIndex: _selectedIndex,
        onTabSelected: _switchTab,
      ),
      appBar: AppBar(
        title: Text('Discussions (${discussions.length})'),
        leading: IconButton( // Add menu button
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: Container(
        color: const Color(0xFFEFEFEF),
        child: Column(
          children: [
            Expanded(child: _buildDiscussionList()),
            Visibility(
              visible: _isFormVisible,
              child: PostFormWidget(
                groupId: widget.groupd,
                communityId: widget.groupId ?? "",
                onPostSuccess: fetchDiscussions,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscussionList() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage.isNotEmpty) return Center(child: Text(errorMessage));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: discussions.length,
      itemBuilder: (context, index) {
        final d = discussions[index];

        bool isOwn = d.post_author.toString() == currentUserId.toString();

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              _createSlideRoute(
                DiscussionDetailScreen(
                  discussion: d,
                  group: {
                    'slug': widget.groupd,
                    'groupId': widget.groupId,
                    'group': widget.groupDetails
                  },
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isOwn ? const Color(0xFFD0F0C0) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blueGrey,
                      child: Text(
                        (d.display_name?.isNotEmpty ?? false)
                            ? d.display_name![0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        isOwn ? CrossAxisAlignment.start : CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.post_title ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),

                          //const SizedBox(height: 4),
                          Html(data: d.post_content ?? ''),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                d.display_name ?? '',
                                style: const TextStyle(fontSize: 10, color: Colors.black54),
                              ),
                              const Spacer(),
                              Text(
                                d.post_date ?? '',
                                style: const TextStyle(fontSize: 10, color: Colors.black38),
                              ),
                              if (d.reply_count != null && d.reply_count != '0') ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF7BC148),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    d.reply_count!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'replys',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black38,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isOwn)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showEditPopup(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
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
}


