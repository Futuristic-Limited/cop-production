import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

class PostFormWidget extends StatefulWidget {
  final String groupId;
  final Function onPostSuccess;

  const PostFormWidget({
    Key? key,
    required this.groupId,
    required this.onPostSuccess,
  }) : super(key: key);

  @override
  State<PostFormWidget> createState() => _PostFormWidgetState();
}

class _PostFormWidgetState extends State<PostFormWidget> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _mediaFiles = [];
  bool _isPosting = false;
  bool _isExpanded = true;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _mediaFiles.add(File(picked.path)));
    }
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _mediaFiles.add(File(picked.path)));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _mediaFiles.addAll(result.paths.whereType<String>().map((path) => File(path)));
      });
    }
  }

  Future<void> _postDiscussion() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty && desc.isEmpty && _mediaFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title, description or add a file')),
      );
      return;
    }

    setState(() => _isPosting = true);

    final uri = Uri.parse('$apiBaseUrl/discussions-save-media');
    var request = http.MultipartRequest('POST', uri)
      ..fields['post_title'] = title
      ..fields['post_description'] = desc
      ..fields['id'] = widget.groupId;
    for (var file in _mediaFiles) {
      request.files.add(await http.MultipartFile.fromPath('media[]', file.path));
    }

    final response = await request.send();
    setState(() => _isPosting = false);

    if (response.statusCode == 200) {
      _titleController.clear();
      _descController.clear();
      setState(() => _mediaFiles.clear());
      widget.onPostSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_mediaFiles.isNotEmpty)
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _mediaFiles.length,
                        itemBuilder: (_, i) {
                          final file = _mediaFiles[i];
                          final isImage = file.path.endsWith('.png') ||
                              file.path.endsWith('.jpg') ||
                              file.path.endsWith('.jpeg');
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(6),
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: isImage
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(file, fit: BoxFit.cover),
                                )
                                    : const Icon(Icons.insert_drive_file),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => setState(() => _mediaFiles.removeAt(i)),
                                  child: const CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.black54,
                                    child: Icon(Icons.close, color: Colors.white, size: 12),
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _titleController,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: "Add a title...",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 40,
                        maxHeight: 150,
                      ),
                      child: Scrollbar(
                        child: TextField(
                          controller: _descController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: "",
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image, color: Colors.green),
                        onPressed: _pickImage,
                      ),
                      IconButton(
                        icon: const Icon(Icons.videocam, color: Colors.purple),
                        onPressed: _pickVideo,
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_file, color: Colors.orange),
                        onPressed: _pickFile,
                      ),
                      const Spacer(),
                      _isPosting
                          ? const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                          : IconButton(
                        icon: const Icon(Icons.send, color: Colors.teal),
                        onPressed: _postDiscussion,
                        tooltip: 'Send',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                width: double.infinity,
                color: Colors.grey.shade200,
                child: Icon(
                  _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }
}


// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:http/http.dart' as http;
// import '../../config/api_config.dart';
//
// class PostFormWidget extends StatefulWidget {
//   final String groupId;
//   final Function onPostSuccess;
//
//   const PostFormWidget({
//     Key? key,
//     required this.groupId,
//     required this.onPostSuccess,
//   }) : super(key: key);
//
//   @override
//   State<PostFormWidget> createState() => _PostFormWidgetState();
// }
//
// class _PostFormWidgetState extends State<PostFormWidget> {
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _descController = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   List<File> _mediaFiles = [];
//   bool _isPosting = false;
//   bool _isExpanded = true;
//
//   Future<void> _pickImage() async {
//     final picked = await _picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() => _mediaFiles.add(File(picked.path)));
//     }
//   }
//
//   Future<void> _pickVideo() async {
//     final picked = await _picker.pickVideo(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() => _mediaFiles.add(File(picked.path)));
//     }
//   }
//
//   Future<void> _pickFile() async {
//     final result = await FilePicker.platform.pickFiles(allowMultiple: true);
//     if (result != null) {
//       setState(() {
//         _mediaFiles.addAll(result.paths.whereType<String>().map((path) => File(path)));
//       });
//     }
//   }
//
//   Future<void> _postDiscussion() async {
//     final title = _titleController.text.trim();
//     final desc = _descController.text.trim();
//
//     if ((title.isEmpty && desc.isEmpty) && _mediaFiles.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter title, description or add a file')),
//       );
//       return;
//     }
//
//     setState(() => _isPosting = true);
//
//     final uri = Uri.parse('$apiBaseUrl/discussions-save-media');
//     var request = http.MultipartRequest('POST', uri)
//       ..fields['post_title'] = title
//       ..fields['post_description'] = desc
//       ..fields['id'] = widget.groupId;
//     for (var file in _mediaFiles) {
//       request.files.add(await http.MultipartFile.fromPath('media[]', file.path));
//     }
//
//
//
//     final response = await request.send();
//     setState(() => _isPosting = false);
//
//     print("=======================");
//     print("Status code: ${response.statusCode}");
//     print("Headers: ${response.headers}");
//     print("Body: ${response.stream}");
//     print("=======================");
//
//     if (response.statusCode == 200) {
//       _titleController.clear();
//       _descController.clear();
//       setState(() => _mediaFiles.clear());
//       widget.onPostSuccess();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Posted successfully')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Post failed')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (_isExpanded)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//               decoration: const BoxDecoration(
//                 color: Color(0xFFF0F0F0),
//                 boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Media preview
//                   if (_mediaFiles.isNotEmpty)
//                     SizedBox(
//                       height: 80,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: _mediaFiles.length,
//                         itemBuilder: (_, i) {
//                           final file = _mediaFiles[i];
//                           final isImage = file.path.endsWith('.png') ||
//                               file.path.endsWith('.jpg') ||
//                               file.path.endsWith('.jpeg');
//                           return Stack(
//                             children: [
//                               Container(
//                                 margin: const EdgeInsets.all(6),
//                                 width: 70,
//                                 height: 70,
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: Colors.grey),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: isImage
//                                     ? ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: Image.file(file, fit: BoxFit.cover),
//                                 )
//                                     : const Icon(Icons.insert_drive_file),
//                               ),
//                               Positioned(
//                                 top: 0,
//                                 right: 0,
//                                 child: GestureDetector(
//                                   onTap: () => setState(() => _mediaFiles.removeAt(i)),
//                                   child: const CircleAvatar(
//                                     radius: 10,
//                                     backgroundColor: Colors.black54,
//                                     child: Icon(Icons.close, color: Colors.white, size: 12),
//                                   ),
//                                 ),
//                               )
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//
//                   // Media Picker Buttons Row
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.image, color: Colors.green),
//                         onPressed: _pickImage,
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.videocam, color: Colors.purple),
//                         onPressed: _pickVideo,
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.attach_file, color: Colors.orange),
//                         onPressed: _pickFile,
//                       ),
//                     ],
//                   ),
//
//                   // Title Field (below media icons)
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     margin: const EdgeInsets.symmetric(vertical: 6),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: Colors.grey.shade300),
//                     ),
//                     child: TextField(
//                       controller: _titleController,
//                       maxLines: 1,
//                       style: const TextStyle(fontSize: 16),
//                       decoration: const InputDecoration(
//                         hintText: "Enter title...",
//                         border: InputBorder.none,
//                         isDense: true,
//                         contentPadding: EdgeInsets.zero,
//                       ),
//                     ),
//
//                   ),
//
//                   // Description Field + Send Button
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Expanded(
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                           margin: const EdgeInsets.symmetric(vertical: 6),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(color: Colors.grey.shade300),
//                           ),
//                           child: ConstrainedBox(
//                             constraints: const BoxConstraints(
//                               minHeight: 40,
//                               maxHeight: 120,
//                             ),
//                             child: Scrollbar(
//                               child: TextField(
//                                 controller: _descController,
//                                 maxLines: null,
//                                 keyboardType: TextInputType.multiline,
//                                 style: const TextStyle(fontSize: 16),
//                                 decoration: const InputDecoration(
//                                   hintText: "Type a message...",
//                                   border: InputBorder.none,
//                                   isDense: true,
//                                   contentPadding: EdgeInsets.zero,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       _isPosting
//                           ? const Padding(
//                         padding: EdgeInsets.only(left: 10, right: 10, bottom: 12),
//                         child: SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         ),
//                       )
//                           : IconButton(
//                         icon: const Icon(Icons.send, color: Colors.teal),
//                         onPressed: _postDiscussion,
//                         tooltip: 'Send',
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//           // Toggle Visibility Arrow
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: GestureDetector(
//               onTap: () => setState(() => _isExpanded = !_isExpanded),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 6),
//                 width: double.infinity,
//                 color: Colors.grey.shade200,
//                 child: Icon(
//                   _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descController.dispose();
//     super.dispose();
//   }
// }
