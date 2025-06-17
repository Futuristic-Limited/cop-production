import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../services/discussions_service.dart';
import '../../models/discussions_model.dart';
import 'discussion_detail_screen.dart';
import 'discussion_post_form.dart';

class DiscussionsScreen extends StatefulWidget {
  final String groupd;
  final String? groupId;
  const DiscussionsScreen({super.key, required this.groupd, this.groupId});

  @override
  State<DiscussionsScreen> createState() => _DiscussionsScreenState();
}

class _DiscussionsScreenState extends State<DiscussionsScreen> {
  late String groupSlug;
  List<Discussions> discussions = [];
  bool isLoading = true;
  String errorMessage = '';
  String groupd = "gfgp";
  bool _isFormVisible = true;

  @override
  void initState() {
    super.initState();
    groupd = widget.groupd;
    fetchDiscussions();
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
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load discussions.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Discussions (${discussions.length})')),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     setState(() {
      //       _isFormVisible = !_isFormVisible;
      //     });
      //   },
      //   child: Icon(_isFormVisible ? Icons.keyboard_arrow_down : Icons.edit),
      //   tooltip: _isFormVisible ? 'Minimize Form' : 'Ask a Question',
      // ),
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
        final isOwn = false;
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              _createSlideRoute(DiscussionDetailScreen(discussion: d)),
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
            child: Row(
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
                    isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.post_title ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      // Text(
                      //   d.post_content ?? '',
                      //   style: const TextStyle(fontSize: 12),
                      // ),

                      Html(data:  d.post_content ?? ''),
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










// import 'package:flutter/material.dart';
// import '../../services/discussions_service.dart';
// import '../../models/discussions_model.dart';
// import 'discussion_detail_screen.dart';
//
// class DiscussionsScreen extends StatefulWidget {
//   final String groupd;
//   const DiscussionsScreen({super.key, required this.groupd});
//   @override
//   State<DiscussionsScreen> createState() => _DiscussionsScreenState();
// }
//
// class _DiscussionsScreenState extends State<DiscussionsScreen> {
//   late String groupSlug;
//   List<Discussions> discussions = [];
//   bool isLoading = true;
//   String errorMessage = '';
//   final titleController = TextEditingController();
//   final descController = TextEditingController();
//   bool isPosting = false;
//   String groupd = "gfgp";
//   String authorId = "19";
//   bool _isFormVisible = false;
//
//   @override
//   void initState() {
//     super.initState();
//     groupd = widget.groupd;
//     fetchDiscussions();
//   }
//
//   Future<void> fetchDiscussions() async {
//     try {
//       final service = DiscussionService();
//       final response = await service.discussionList(groupd);
//       if (response != null && response.items != null) {
//         setState(() {
//           discussions = response.items!;
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMessage = response?.error ?? 'No discussions found.';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Failed to load discussions.';
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> postDiscussion() async {
//     final title = titleController.text.trim();
//     final description = descController.text.trim();
//     if (title.isEmpty || description.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter both title and description')),
//       );
//       return;
//     }
//     setState(() { isPosting = true; });
//     try {
//       final service = DiscussionService();
//       final success = await service.postDiscussion(title, description, groupd: groupd);
//       if (success) {
//         titleController.clear();
//         descController.clear();
//         await fetchDiscussions();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Discussion posted successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to post discussion')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('An error occurred posting discussion')),
//       );
//     } finally {
//       setState(() { isPosting = false; });
//     }
//   }
//
//   @override
//   void dispose() {
//     titleController.dispose();
//     descController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Discussions')),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           setState(() { _isFormVisible = !_isFormVisible; });
//         },
//         child: Icon(_isFormVisible ? Icons.keyboard_arrow_down : Icons.edit),
//         tooltip: _isFormVisible ? 'Minimize Form' : 'Ask a Question',
//       ),
//       body: Container(
//         color: const Color(0xFFEFEFEF),
//         child: Column(
//           children: [
//             Expanded(child: _buildDiscussionList()),
//             Visibility(visible: _isFormVisible, child: _buildAskQuestionForm()),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDiscussionList() {
//     if (isLoading) return const Center(child: CircularProgressIndicator());
//     if (errorMessage.isNotEmpty) return Center(child: Text(errorMessage));
//     return ListView.builder(
//       padding: const EdgeInsets.all(12),
//       itemCount: discussions.length,
//       itemBuilder: (context, index) {
//         final d = discussions[index];
//         //final isOwn = d.author_id == authorId;
//         final isOwn = false;
//         return Align(
//           alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
//           child: GestureDetector(
//             onTap: () {
//               Navigator.of(context).push(_createSlideRoute(DiscussionDetailScreen(discussion: d)));
//             },
//             child: Container(
//               constraints: const BoxConstraints(maxWidth: 300),
//               padding: const EdgeInsets.all(12),
//               margin: const EdgeInsets.symmetric(vertical: 6),
//               decoration: BoxDecoration(
//                 color: isOwn ? const Color(0xFFD0F0C0) : Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(16),
//                   topRight: const Radius.circular(16),
//                   bottomLeft: Radius.circular(isOwn ? 16 : 0),
//                   bottomRight: Radius.circular(isOwn ? 0 : 16),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 4,
//                     offset: Offset(0, 2),
//                   )
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment:
//                 isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     d.post_title ?? '',
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     d.post_content ?? '',
//                     style: const TextStyle(fontSize: 12),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     d.display_name ?? '',
//                     style: const TextStyle(fontSize: 10, color: Colors.black54),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     d.post_date ?? '',
//                     style: const TextStyle(fontSize: 10, color: Colors.black38),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   PageRouteBuilder _createSlideRoute(Widget page) {
//     return PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) => page,
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         const begin = Offset(1.0, 0.0);
//         const end = Offset.zero;
//         const curve = Curves.easeInOut;
//         var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//         return SlideTransition(position: animation.drive(tween), child: child);
//       },
//       opaque: false,
//       barrierColor: Colors.black.withOpacity(0.3),
//     );
//   }
//
//   Widget _buildAskQuestionForm() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Start New Discussion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//           const SizedBox(height: 12),
//           TextField(
//             controller: titleController,
//             decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
//           ),
//           const SizedBox(height: 12),
//           TextField(
//             controller: descController,
//             maxLines: 4,
//             decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               ElevatedButton(
//                 onPressed: isPosting ? null : postDiscussion,
//                 child: isPosting
//                     ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                     : const Text('Post'),
//               ),
//               const SizedBox(width: 12),
//               OutlinedButton(
//                 onPressed: () {
//                   titleController.clear();
//                   descController.clear();
//                 },
//                 child: const Text('Clear'),
//               )
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }






// import 'package:flutter/material.dart';
// import '../../services/discussions_service.dart';
// import '../../models/discussions_model.dart';
// import 'discussion_detail_screen.dart';
//
// class DiscussionsScreen extends StatefulWidget {
//   final String groupd;
//
//   const DiscussionsScreen({super.key, required this.groupd});
//
//   @override
//   State<DiscussionsScreen> createState() => _DiscussionsScreenState();
// }
//
// class _DiscussionsScreenState extends State<DiscussionsScreen> {
//   late String groupSlug;
//   List<Discussions> discussions = [];
//   bool isLoading = true;
//   String errorMessage = '';
//   final titleController = TextEditingController();
//   final descController = TextEditingController();
//   bool isPosting = false;
//   String groupd = "gfgp";
//   String authorId = "19";
//   bool _isFormVisible = false;
//
//   @override
//   void initState() {
//     super.initState();
//     groupd = widget.groupd;
//     fetchDiscussions();
//   }
//
//   Future<void> fetchDiscussions() async {
//     try {
//       final service = DiscussionService();
//       final response = await service.discussionList(groupd);
//       if (response != null && response.items != null) {
//         setState(() {
//           discussions = response.items!;
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMessage = response?.error ?? 'No discussions found.';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Failed to load discussions.';
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> postDiscussion() async {
//     final title = titleController.text.trim();
//     final description = descController.text.trim();
//
//     if (title.isEmpty || description.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter both title and description'),
//         ),
//       );
//       return;
//     }
//
//     setState(() {
//       isPosting = true;
//     });
//
//     try {
//       final service = DiscussionService();
//       final success = await service.postDiscussion(
//         title,
//         description,
//         groupd: groupd,
//       );
//       if (success) {
//         titleController.clear();
//         descController.clear();
//         await fetchDiscussions();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Discussion posted successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to post discussion')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('An error occurred posting discussion')),
//       );
//     } finally {
//       setState(() {
//         isPosting = false;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     titleController.dispose();
//     descController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Discussions')),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           setState(() {
//             _isFormVisible = !_isFormVisible;
//           });
//         },
//         child: Icon(_isFormVisible ? Icons.keyboard_arrow_down : Icons.edit),
//         tooltip: _isFormVisible ? 'Minimize Form' : 'Ask a Question',
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildDiscussionTableHeader(),
//             const SizedBox(height: 10),
//             Expanded(child: _buildDiscussionList()),
//             const Divider(height: 40),
//             Visibility(
//               visible: _isFormVisible,
//               child: _buildAskQuestionForm(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDiscussionTableHeader() {
//     return Row(
//       children: const [
//         Expanded(
//           flex: 4,
//           child: Text(
//             'Discussions',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//         Expanded(
//           flex: 1,
//           child: Text('Replies', style: TextStyle(fontWeight: FontWeight.bold)),
//         ),
//         Expanded(
//           flex: 2,
//           child: Text(
//             'Last Post',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDiscussionList() {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (errorMessage.isNotEmpty) {
//       return Center(child: Text(errorMessage));
//     }
//
//     return ListView.builder(
//       itemCount: discussions.length,
//       itemBuilder: (context, index) {
//         final d = discussions[index];
//         return GestureDetector(
//           onTap: () {
//             Navigator.of(
//               context,
//             ).push(_createSlideRoute(DiscussionDetailScreen(discussion: d)));
//           },
//           child: Card(
//             elevation: 6,
//             margin: const EdgeInsets.only(bottom: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//               side: const BorderSide(color: Colors.green, width: 2),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     flex: 4,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           d.post_title ?? '',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green,
//                             fontSize: 12,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'Started by: ${d.display_name ?? 'Unknown'}',
//                           style: TextStyle(
//                             color: Colors.black87,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 10,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.green,
//                         shape: BoxShape.circle,
//                       ),
//                       padding: const EdgeInsets.all(8),
//                       alignment: Alignment.center,
//                       child: Text(
//                         d.reply_count ?? '-',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 2,
//                     child: Text(
//                       d.last_reply_date ?? '',
//                       style: TextStyle(
//                         color: Colors.black87,
//                         fontWeight: FontWeight.normal,
//                         fontSize: 10,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   PageRouteBuilder _createSlideRoute(Widget page) {
//     return PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) => page,
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         const begin = Offset(1.0, 0.0);
//         const end = Offset.zero;
//         const curve = Curves.easeInOut;
//         var tween = Tween(
//           begin: begin,
//           end: end,
//         ).chain(CurveTween(curve: curve));
//         return SlideTransition(position: animation.drive(tween), child: child);
//       },
//       opaque: false,
//       barrierColor: Colors.black.withOpacity(0.3),
//     );
//   }
//
//   Widget _buildAskQuestionForm() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Ask a question or share an idea',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: titleController,
//           decoration: const InputDecoration(
//             labelText: 'Discussion Title',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: descController,
//           decoration: const InputDecoration(
//             labelText: 'Description',
//             border: OutlineInputBorder(),
//           ),
//           maxLines: 4,
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             ElevatedButton(
//               onPressed: isPosting ? null : postDiscussion,
//               child: isPosting
//                   ? const SizedBox(
//                 width: 18,
//                 height: 18,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: Colors.white,
//                 ),
//               )
//                   : const Text('Post'),
//             ),
//             const SizedBox(width: 12),
//             OutlinedButton(
//               onPressed: () {
//                 titleController.clear();
//                 descController.clear();
//               },
//               child: const Text('Discard Draft'),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
//













// import 'package:flutter/material.dart';
// import '../../services/discussions_service.dart';
// import '../../models/discussions_model.dart';
// import 'discussion_detail_screen.dart';
//
//
// class DiscussionsScreen extends StatefulWidget {
//   final String groupd;
//
//   const DiscussionsScreen({super.key, required this.groupd});
//
//   @override
//   State<DiscussionsScreen> createState() => _DiscussionsScreenState();
// }
//
// class _DiscussionsScreenState extends State<DiscussionsScreen> {
//   late String groupSlug;
//
//   List<Discussions> discussions = [];
//   bool isLoading = true;
//   String errorMessage = '';
//   final titleController = TextEditingController();
//   final descController = TextEditingController();
//   bool isPosting = false;
//   String groupd = "gfgp";
//   String authorId = "19";
//
//   @override
//   void initState() {
//     super.initState();
//     groupd = widget.groupd;
//
//     fetchDiscussions();
//   }
//
//   Future<void> fetchDiscussions() async {
//     try {
//       print(groupd);
//
//       final service = DiscussionService();
//       final response = await service.discussionList(groupd);
//       if (response != null && response.items != null) {
//         setState(() {
//           discussions = response.items!;
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMessage = response?.error ?? 'No discussions found.';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Failed to load discussions.';
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> postDiscussion() async {
//     final title = titleController.text.trim();
//     final description = descController.text.trim();
//
//     if (title.isEmpty || description.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter both title and description'),
//         ),
//       );
//       return;
//     }
//
//     setState(() {
//       isPosting = true;
//     });
//
//     try {
//       final service = DiscussionService();
//       final success = await service.postDiscussion(
//         title,
//         description,
//         groupd: groupd,
//       );
//       if (success) {
//         titleController.clear();
//         descController.clear();
//         await fetchDiscussions();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Discussion posted successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to post discussion')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('An error occurred posting discussion')),
//       );
//     } finally {
//       setState(() {
//         isPosting = false;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     titleController.dispose();
//     descController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Discussions')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildDiscussionTableHeader(),
//             const SizedBox(height: 10),
//             Expanded(child: _buildDiscussionList()),
//             const Divider(height: 40),
//             _buildAskQuestionForm(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDiscussionTableHeader() {
//     return Row(
//       children: const [
//         Expanded(
//           flex: 4,
//           child: Text(
//             'Discussions',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//         Expanded(
//           flex: 1,
//           child: Text('Replies', style: TextStyle(fontWeight: FontWeight.bold)),
//         ),
//         Expanded(
//           flex: 2,
//           child: Text(
//             'Last Post',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDiscussionList() {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (errorMessage.isNotEmpty) {
//       return Center(child: Text(errorMessage));
//     }
//
//     return ListView.builder(
//       itemCount: discussions.length,
//       itemBuilder: (context, index) {
//         final d = discussions[index];
//         return GestureDetector(
//           onTap: () {
//             Navigator.of(
//               context,
//             ).push(_createSlideRoute(DiscussionDetailScreen(discussion: d)));
//           },
//           child: Card(
//             elevation: 6,
//             margin: const EdgeInsets.only(bottom: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//               side: const BorderSide(color: Colors.green, width: 2),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     flex: 4,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           d.post_title ?? '',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green,
//                             fontSize: 12,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'Started by: ${d.display_name ?? 'Unknown'}',
//                           style: TextStyle(
//                             color: Colors.black87,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 10,
//                           ),
//                         ),
//
//                         //Text('Started by: ${d.display_name ?? 'Unknown'}'),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.green,
//                         shape: BoxShape.circle,
//                       ),
//                       padding: const EdgeInsets.all(8),
//                       alignment: Alignment.center,
//                       child: Text(
//                         d.reply_count ?? '-',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 2,
//                     child: Text(
//                       d.last_reply_date ?? '',
//                       style: TextStyle(
//                         color: Colors.black87,
//                         fontWeight: FontWeight.normal,
//                         fontSize: 10,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   PageRouteBuilder _createSlideRoute(Widget page) {
//     return PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) => page,
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         const begin = Offset(1.0, 0.0);
//         const end = Offset.zero;
//         const curve = Curves.easeInOut;
//         var tween = Tween(
//           begin: begin,
//           end: end,
//         ).chain(CurveTween(curve: curve));
//         return SlideTransition(position: animation.drive(tween), child: child);
//       },
//       opaque: false,
//       barrierColor: Colors.black.withOpacity(0.3),
//     );
//   }
//
//   Widget _buildAskQuestionForm() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Ask a question or share an idea',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: titleController,
//           decoration: const InputDecoration(
//             labelText: 'Discussion Title',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: descController,
//           decoration: const InputDecoration(
//             labelText: 'Description',
//             border: OutlineInputBorder(),
//           ),
//           maxLines: 4,
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             ElevatedButton(
//               onPressed: isPosting ? null : postDiscussion,
//               child:
//                   isPosting
//                       ? const SizedBox(
//                         width: 18,
//                         height: 18,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.white,
//                         ),
//                       )
//                       : const Text('Post'),
//             ),
//             const SizedBox(width: 12),
//             OutlinedButton(
//               onPressed: () {
//                 titleController.clear();
//                 descController.clear();
//               },
//               child: const Text('Discard Draft'),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
