import 'dart:io';
import 'dart:convert';
import 'package:APHRC_COP/screens/messages/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../../models/group_photos_model.dart';
import '../../services/token_preference.dart';
import '../../utils/constants.dart';
import '../../utils/show_error_dialog.dart';
import 'full_screen_photo.dart';

final buddyBossApiUrl = dotenv.env['WP_API_URL'];

class GroupPhotos extends StatefulWidget {
  const GroupPhotos({Key? key, required this.groupId}) : super(key: key);
  final int groupId;

  @override
  State<GroupPhotos> createState() => _GroupPhotosState();
}

class _GroupPhotosState extends State<GroupPhotos> {
  String? _accessToken;
  bool _isLoading = false;
  bool _isLoadingUpload = false;
  bool _isLoadingSaveImage = false;
  List<GroupActivity> activities = [];
  String? errorMessage;
  File? _selectedImage;
  String? _uploaded;
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
    await _fetchGroupPhotos(widget.groupId);
  }

  MediaType _getContentType(String filePath) {
    final mimeType = lookupMimeType(filePath);
    if (mimeType != null) {
      final parts = mimeType.split('/');
      return MediaType(parts[0], parts[1]);
    }
    return MediaType('application', 'octet-stream');
  }

  Future<void> _fetchGroupPhotos(int groupId) async {
    await _getAccessToken();
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          errorMessage = null;
        });
      }

      final response = await http.get(
        Uri.parse('$buddyBossApiUrl/wp-json/buddyboss/v1/activity?component=groups&primary_id=$groupId&type=activity_update'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Accept': 'application/json',
        },
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final List<dynamic> jsonData = jsonDecode(response.body);
          setState(() {
            activities = jsonData.map((item) => GroupActivity.fromJson(item)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Failed to load activities: ${response.statusCode}';
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
        Uri.parse('$buddyBossApiUrl/wp-json/wp/v2/media'),
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
        return {'id': jsonData['id']};
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
    _saveNotifier.value = true; // Start loading
    if (mounted) {
      setState(() {
        _isLoadingSaveImage = true;
      });
    }

    try {
      final response = await http.post(
        Uri.parse('${buddyBossApiUrl}wp-json/buddyboss/v1/media'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          await _fetchGroupPhotos(widget.groupId);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if(response.statusCode == 403){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You are not a member of the group'),
              backgroundColor: Colors.red,
            ),
          );
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unexpected error'),
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
    }finally {
      _saveNotifier.value = false; // Stop loading
      if (mounted) setState(() {
        _isLoadingSaveImage = false;
        _selectedImage = null;
        _uploaded = null;
        _descriptionController.clear();
      });
      // Navigator.pop(context); // Close the bottom sheet
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        if (mounted) Navigator.pop(context);
        setState(() {
          _selectedImage = File(pickedFile.path);
          _uploaded = null;
        });
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
          SnackBar(content: Text('Error picking image: $e')),
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
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
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
                                          child: const Icon(Icons.close,
                                              color: Colors.white,
                                              size: 20),
                                        ),
                                      ),
                                    ),
                
                                  if (_isLoadingUpload)
                                    Container(
                                      color: Colors.black54,
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
                      Text(uploadPhotoText),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        cursorColor: AppColors.aphrcGreen,
                        style: const TextStyle(color: AppColors.aphrcGreen),
                        decoration: InputDecoration(
                          labelText: 'Write something about your photo',
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
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Gallery'),
                                onPressed: () => _pickImage(ImageSource.gallery),
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
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Camera'),
                                onPressed: () => _pickImage(ImageSource.camera),
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
                                    : const Text('Upload Photo'),
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
        title: const Text('Group Photos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : activities.every((a) => a.media.isEmpty)
          ? LottieEmpty(title: 'Upload documents')
          : _buildPhotoGrid(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadBottomSheet(context),
        backgroundColor: AppColors.aphrcGreen,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    final allMedia = activities
        .expand((activity) => activity.media)
        .toList();

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: allMedia.length,
      itemBuilder: (context, index) {
        final media = allMedia[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenPhoto(imageUrl: media.url),
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
                Image.network(
                  media.url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.broken_image)),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    color: Colors.black54,
                    child: Text(
                      media.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
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

  @override
  void dispose() {
    _saveNotifier.dispose();
    _uploadNotifier.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}