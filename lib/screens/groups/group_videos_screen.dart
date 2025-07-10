import 'dart:io';
import 'dart:convert';
import 'package:APHRC_COP/screens/messages/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../models/group_videos_model.dart';
import '../../services/community_service.dart';
import '../../services/shared_prefs_service.dart';
import '../../services/token_preference.dart';
import '../../utils/constants.dart';
import '../../utils/show_error_dialog.dart';
import 'full_screen_video.dart';

final buddyBossApiUrl = dotenv.env['WP_API_URL'];

class GroupVideos extends StatefulWidget {
  const GroupVideos({Key? key, required this.groupId}) : super(key: key);
  final int groupId;

  @override
  State<GroupVideos> createState() => _GroupVideosState();
}

class _GroupVideosState extends State<GroupVideos> {
  String? _accessToken;
  bool? _isGroupMember;
  bool _isLoading = false;
  bool _isLoadingUpload = false;
  bool _isLoadingSaveImage = false;
  List<GroupActivityVideo> activities = [];
  String? errorMessage;
  File? _selectedImage;
  String? _uploaded;
  File? _videoThumbnail;
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ValueNotifier<bool> _uploadNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _saveNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _getAccessToken() async {
    final token = await SaveAccessTokenService.getBuddyToken();
    if (mounted) {
      setState(() {
        _accessToken = token;
      });
    }
  }

  Future<void> _init() async {
    await _fetchGroupVideos(widget.groupId);
    await _getUserId();
  }

  Future<void> _getUserId() async {
    if (!mounted) return;

    try {
      final userId = await SharedPrefsService.getUserId();
      final token = await SharedPrefsService.getAccessToken();
      CommunityService Community = new CommunityService();
      final isMember = await Community.checkUserGroupMembership(token!, userId!, widget.groupId
      );
      if (mounted) {
        setState(() {
          _isGroupMember = isMember;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => 'Failed to check membership: ${e.toString()}');
      }
    } finally {
      if (mounted) {
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

  Future<void> _generateVideoThumbnail(File videoFile) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 250,
        quality: 75,
      );

      if (thumbnailPath != null && mounted) {
        setState(() {
          _videoThumbnail = File(thumbnailPath);
        });
      }
    } catch (e) {
      debugPrint("Failed to generate video thumbnail: $e");
    }
  }

  Future<void> _fetchGroupVideos(int groupId) async {
    await _getAccessToken();
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          errorMessage = null;
        });
      }

      final response = await http.get(
        Uri.parse('$buddyBossApiUrl/wp-json/buddyboss/v1/video?group_id=$groupId'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Accept': 'application/json',
        },
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final List<dynamic> jsonData = jsonDecode(response.body);
          setState(() {
            activities = jsonData.map((item) => GroupActivityVideo.fromJson(item)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Failed to load videos: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadAndAdd() async {
    final result = await _uploadPhoto();
    if (!mounted) return;

    if (result != null) {
      if (mounted) {
        setState(() {
          _uploaded = result['id'].toString();
        });
      }
    } else {
      if (mounted) {
        await showErrorDialog(context, 'Something went wrong!');
      }
    }
  }

  Future<Map<String, dynamic>?> _uploadPhoto() async {
    if (_selectedImage == null || _accessToken == null) return null;

    _uploadNotifier.value = true;
    if (mounted) setState(() => _isLoadingUpload = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$buddyBossApiUrl/wp-json/buddyboss/v1/video/upload'),
      );

      request.headers['Authorization'] = 'Bearer $_accessToken';
      final contentType = _getContentType(_selectedImage!.path);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          _selectedImage!.path,
          contentType: contentType,
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 201) {
        _uploadNotifier.value = false;
        if (mounted) setState(() => _isLoadingUpload = false);
        return {'id': jsonData['upload_id']};
      } else {
        _uploadNotifier.value = false;
        if (mounted) setState(() => _isLoadingUpload = false);
        return null;
      }
    } catch (e) {
      _uploadNotifier.value = false;
      if (mounted) setState(() => _isLoadingUpload = false);
      return null;
    }
  }

  Future<void> _saveActivityPhoto() async {
    final Map<String, dynamic> payload = {
      'content': _descriptionController.text.trim(),
      'upload_ids': [_uploaded],
      'group_id': widget.groupId,
      'privacy': "public",
    };
    _saveNotifier.value = true;
    if (mounted) {
      setState(() {
        _isLoadingSaveImage = true;
      });
    }

    try {
      final response = await http.post(
        Uri.parse('${buddyBossApiUrl}wp-json/buddyboss/v1/video'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          await _fetchGroupVideos(widget.groupId);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unexpected error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _saveNotifier.value = false;
      if (mounted) {
        setState(() {
          _isLoadingSaveImage = false;
          _selectedImage = null;
          _uploaded = null;
          _descriptionController.clear();
        });
      }
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickVideo(source: source);
      if (pickedFile != null) {
        if (mounted) Navigator.pop(context);
        setState(() {
          _selectedImage = File(pickedFile.path);
          _uploaded = null;
        });
        await _generateVideoThumbnail(_selectedImage!);
        await Future.delayed(const Duration(milliseconds: 50));
        if (mounted) _showUploadBottomSheet(context);
        await _uploadAndAdd();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUpload = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking video: $e')),
        );
      }
    }
  }

  void _showUploadBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (context) {
        return ValueListenableBuilder<bool>(
          valueListenable: _uploadNotifier,
          builder: (context, _, __) {
            return SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      if (_selectedImage != null) ...[
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return SizedBox(
                              height: constraints.maxWidth * 0.4,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: _videoThumbnail != null
                                          ? Image.file(
                                        _videoThumbnail!,
                                        fit: BoxFit.cover,
                                      )
                                          : Container(
                                        color: Colors.black,
                                        child: const Center(
                                          child: Icon(
                                            Icons.play_circle_fill,
                                            color: Colors.white70,
                                            size: 60,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  if (!_isLoadingUpload)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedImage = null;
                                            _videoThumbnail = null;
                                            _uploaded = null;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                                        ),
                                      ),
                                    ),

                                  if (_isLoadingUpload)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(uploadVideoText),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        cursorColor: AppColors.aphrcGreen,
                        style: const TextStyle(color: AppColors.aphrcGreen),
                        decoration: InputDecoration(
                          labelText: videoTextFieldPlaceholder,
                          labelStyle: const TextStyle(color: AppColors.aphrcGreen),
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.aphrcGreen, width: 2),
                          ),
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 16),
                      if (_selectedImage == null) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.aphrcGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.video_call_outlined),
                                label: const Text('Video'),
                                onPressed: () => _pickVideo(ImageSource.gallery),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.aphrcGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.video_call),
                                label: const Text('Record'),
                                onPressed: () => _pickVideo(ImageSource.camera),
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (_selectedImage != null) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _saveNotifier,
                            builder: (context, isSaving, _) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.aphrcGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: (_isLoadingUpload || isSaving) ? null : _saveActivityPhoto,
                                child: isSaving
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text('Upload Video'),
                              );
                            },
                          ),
                        )
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Videos'),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : activities.isEmpty || activities.every((a) => a.media.url.isEmpty)
              ? LottieEmpty(title: 'Upload videos')
              : _buildVideoGrid(),
          // Membership restriction message
          if (_isGroupMember == false)
            Positioned(
              bottom: 80, // Positioned above the FAB
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.orange[100]?.withOpacity(0.9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.group_off, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Only group members can upload videos',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isGroupMember == true
            ? () => _showUploadBottomSheet(context)
            : null,
        backgroundColor: _isGroupMember == true
            ? AppColors.aphrcGreen
            : Colors.grey[400],
        foregroundColor: Colors.white,
        tooltip: _isGroupMember == true
            ? 'Upload video'
            : 'Join group to upload videos',
        child: const Icon(Icons.video_call),
      ),
    );
  }

  Widget _buildVideoGrid() {
    // Get unique group name (assuming activities has at least one item)
    final groupName = activities.isNotEmpty ? activities.first.groupName : 'Group';

    return Column(
      children: [
        // Group name badge (same style as photo grid)
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 32, // 16px padding on each side
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.aphrcGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.aphrcGreen,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group, size: 16, color: AppColors.aphrcGreen),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$groupName community videos',
                  style: TextStyle(
                    color: AppColors.aphrcGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        // Video grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              final media = activity.media;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenVideo(
                        videoUrl: media.url,
                        userName: activity.userLogin,
                        groupName: activity.groupName,
                        downloadUrl: media.downloadUrl,
                      ),
                    ),
                  );
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      // Video thumbnail
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: media.thumb,
                          fit: BoxFit.cover,
                          httpHeaders: {
                            'Authorization': 'Bearer $_accessToken',
                          },
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                      ),

                      // Play icon overlay
                      const Positioned.fill(
                        child: Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            size: 48,
                            color: Colors.white70,
                          ),
                        ),
                      ),

                      // Duration label
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                activity.userLogin,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                media.duration,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _saveNotifier.dispose();
    _uploadNotifier.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}