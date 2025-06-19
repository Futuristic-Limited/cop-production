import 'dart:convert';
import 'dart:io';
import 'package:APHRC_COP/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import '../../services/get_group_forum_id.dart';
import '../../services/token_preference.dart';

final apiUrl = dotenv.env['WP_API_URL'];

class PostFormWidget extends StatefulWidget {
  final String groupId;
  final String communityId;
  final Function onPostSuccess;

  const PostFormWidget({
    Key? key,
    required this.groupId,
    required this.communityId,
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
  String? _accessToken;
  bool _isUploading = false;
  final List<String> _uploaded = [];
  int? _forum;
  int? _communityId;
  final List<int> imageIds = [];
  final List<int> videoIds = [];
  final List<int> documentIds = [];
  ForumService forum = new ForumService();

  @override
  void initState() {
    // TODO: implement initState
    _getForumId();
    _getAccessToken();
    super.initState();
  }

  Future<void> _getForumId() async {
    try {
      // First fetch all groups (since slug filter isn't working)
      final allGroups = await forum.fetchCommunities(widget.groupId);

      // Then filter locally by slug
      final matchedGroups = allGroups.where((group) =>
      group['slug'] == widget.groupId // Assuming widget.groupId contains the slug
      ).toList();

      if (matchedGroups.isNotEmpty) {
        final firstGroup = matchedGroups[0];
        final groupId = firstGroup['id'];
        final forumId = firstGroup['forum_id'] ?? firstGroup['forum'];
        setState(() {
          _forum = forumId;
          _communityId = groupId;
        });
        // You might want to set these values in your state
      } else {
        print('No group found with slug: ${widget.groupId}');
      }
    } catch (e) {
      print('Error fetching group: $e');
    }
  }


  Future<void> _getAccessToken() async {
    final token = await SaveAccessTokenService.getBuddyToken();
    if (mounted) {
      setState(() {
        _accessToken = token;
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _mediaFiles.add(File(picked.path)));
      await _uploadAndAdd(File(picked.path));
    }
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _mediaFiles.add(File(picked.path)));
      await _uploadAndAdd(File(picked.path));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _mediaFiles.addAll(result.paths.whereType<String>().map((path) => File(path)));
      });
      // Upload and add attachments
      for (final file in result.paths.map((path) => File(path!)).toList()) {
        await _uploadAndAdd(file);
      }
    }
  }

  MediaType _getContentType(String filePath) {
    final mimeType = lookupMimeType(filePath);
    if (mimeType != null) {
      final parts = mimeType.split('/');
      return MediaType(parts[0], parts[1]);
    }
    return MediaType('application', 'octet-stream');
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadAndAdd(File file) async {
    final result = await _uploadMedia(file);
    if (!mounted) return;


    final idResult = result?['id'];

    if (idResult != null) {
      setState(() {
        if (idResult is List) {
          _uploaded.addAll(idResult.map((id) => id.toString()));
        } else {
          _uploaded.add(idResult.toString());
        }
      });

      print('_uploaded updated: $_uploaded');
    } else {
      if (!mounted) return;
      await _showErrorDialog('Failed to upload ${file.path.split('/').last}.');
    }
  }



  Future<Map<String, dynamic>?> _uploadMedia(File file) async {
    try {
      setState(() {
        _isUploading = true;
      });

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${apiUrl}wp-json/wp/v2/media'),
      );

      request.headers['Authorization'] = 'Bearer $_accessToken';

      final contentType = _getContentType(file.path);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: contentType,
        ),
      );

      final response = await request.send();
      if (response.statusCode == 201) {
        print('File uploaded successfully');
        setState(() {
          _isUploading = false;
        });
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);
        return {'id': jsonData['id']};
      }

      return null;
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<void> _postDiscussion() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if ((title.isEmpty && desc.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title, description or add a file')),
      );
      return;
    }

    for (int i = 0; i < _mediaFiles.length; i++) {
      final filePath = _mediaFiles[i].path;
      final extension = filePath.split('.').last.toLowerCase();
      final uploadedId = int.parse(_uploaded[i]);

      if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
        imageIds.add(uploadedId);
      } else if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
        videoIds.add(uploadedId);
      } else if (['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx'].contains(extension)) {
        documentIds.add(uploadedId);
      }
    }

    final Map<String, dynamic> payload = {
      'title': title,
      'content': desc,
      'group': _communityId,
      'parent': _forum,
      'status': 'publish',
      if (imageIds.isNotEmpty) 'bbp_media': imageIds,
      if (videoIds.isNotEmpty) 'bbp_videos': videoIds,
      if (documentIds.isNotEmpty) 'bbp_documents': documentIds,
    };

    setState(() => _isPosting = true);

    final response = await http.post(
      Uri.parse('$apiUrl/wp-json/buddyboss/v1/topics'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
    print('Response After posting the discussion, ${response.statusCode}');
    if (response.statusCode == 200) {
      _titleController.clear();
      _descController.clear();
      setState(() {
        _mediaFiles.clear();
        _isPosting = false;
      });
      widget.onPostSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posted successfully')),
      );
    }else if(response.statusCode == 400){
      setState(() => _isPosting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post already exist with similar content.')),
      );
    }
    else {
      setState(() => _isPosting = false);
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Media preview with loading overlay
                  if (_mediaFiles.isNotEmpty)
                    Container(
                      height: 80,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _mediaFiles.length,
                        itemBuilder: (_, i) {
                          final file = _mediaFiles[i];
                          final isImage = file.path.endsWith('.png') ||
                              file.path.endsWith('.jpg') ||
                              file.path.endsWith('.jpeg');
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: isImage
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(file, fit: BoxFit.cover),
                                  )
                                      : const Center(child: Icon(Icons.insert_drive_file)),
                                ),

                                // Uploading overlay
                                if (_isUploading)
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),

                                // Close button (hidden during upload)
                                if (!_isUploading)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => setState(() => _mediaFiles.removeAt(i)),
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black54,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  // Title Field
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _titleController,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: "Enter title...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  // Description Field
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 40,
                        maxHeight: 120,
                      ),
                      child: Scrollbar(
                        child: TextField(
                          controller: _descController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: "Type a message...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Action Row (File upload + Send button)
                  Container(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // File upload icons
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.image,
                                  color: Colors.green, size: 24),
                              onPressed: _isUploading ? null : _pickImage,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.videocam,
                                  color: Colors.purple, size: 24),
                              onPressed: _isUploading ? null : _pickVideo,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.attach_file,
                                  color: Colors.orange, size: 24),
                              onPressed: _isUploading ? null : _pickFile,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),

                        // Send button
                        _isPosting
                            ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                            : IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.aphrcGreen,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          onPressed: _postDiscussion,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Toggle Visibility Arrow
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(_isExpanded ? 0 : 12),
                  bottomRight: Radius.circular(_isExpanded ? 0 : 12),
                ),
              ),
              child: Icon(
                _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                color: Colors.grey[600],
                size: 24,
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
