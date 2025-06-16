import 'dart:io';
import 'dart:convert';
import 'package:APHRC_COP/screens/messages/lottie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../models/group_documents_model.dart';
import '../../services/token_preference.dart';
import '../../utils/constants.dart';
import '../../utils/download.dart';
import '../../utils/helper_functions.dart';
import '../../utils/show_error_dialog.dart';

final buddyBossApiUrl = dotenv.env['WP_API_URL'];

class GroupDocuments extends StatefulWidget {
  const GroupDocuments({Key? key, required this.groupId}) : super(key: key);
  final int groupId;

  @override
  State<GroupDocuments> createState() => _GroupPhotosState();
}

class _GroupPhotosState extends State<GroupDocuments> {
  String? _accessToken;
  bool _isLoading = false;
  bool _isLoadingUpload = false;
  bool _isLoadingSaveImage = false;
  List<GroupActivityDocument> activities = [];
  String? errorMessage;
  File? _selectedImage;
  String? _uploaded;
  final TextEditingController _descriptionController = TextEditingController();
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
    await _fetchGroupDocuments(widget.groupId);
  }

  MediaType _getContentType(String filePath) {
    final mimeType = lookupMimeType(filePath);
    if (mimeType != null) {
      final parts = mimeType.split('/');
      return MediaType(parts[0], parts[1]);
    }
    return MediaType('application', 'octet-stream');
  }

  Future<void> _fetchGroupDocuments(int groupId) async {
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
            activities = jsonData.map((item) => GroupActivityDocument.fromJson(item)).toList();
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
    final result = await _uploadDocument();
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

  Future<Map<String, dynamic>?> _uploadDocument() async {
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

  Future<void> _saveActivityDocument() async {
    final Map<String, dynamic> payload = {
      'content': _descriptionController.text.trim(),
      'document_ids': [_uploaded],
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
        Uri.parse('${buddyBossApiUrl}wp-json/buddyboss/v1/document'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      if (mounted) {
        print('Response from the API create the document, ${response.body}');
        if (response.statusCode == 200) {
          print('Response from the API, ${response.body}');
          await _fetchGroupDocuments(widget.groupId);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
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

  void _showDocumentUploadBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (context) {
        return SingleChildScrollView(
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
                  ListTile(
                    leading: Icon(
                      getDocumentIcon(_selectedImage!.path.split('.').last),
                      size: 36,
                      color: getDocumentColor(_selectedImage!.path.split('.').last),
                    ),
                    title: Text(
                      _selectedImage!.path.split('/').last,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() => _selectedImage = null);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                Text(uploadDocumentText),
                const SizedBox(height: 8),

                TextField(
                  controller: _descriptionController,
                  cursorColor: AppColors.aphrcGreen,
                  style: const TextStyle(color: AppColors.aphrcGreen),
                  decoration: InputDecoration(
                    labelText: 'Add description for this document',
                    labelStyle: const TextStyle(color: AppColors.aphrcGreen),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: AppColors.aphrcGreen,
                          width: 2),
                    ),
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 16),

                if (_selectedImage == null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.aphrcGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.insert_drive_file),
                      label: const Text('Select Document'),
                      onPressed: _pickDocument,
                    ),
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
                          onPressed: isSaving ? null : _saveActivityDocument,
                          child: isSaving
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text('Upload Document'),
                        );
                      },
                    ),
                  )
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'],
      );

      if (result != null && result.files.single.path != null) {
        if (mounted) Navigator.pop(context);
        setState(() {
          _selectedImage = File(result.files.single.path!);
          _uploaded = null;
        });
        await Future.delayed(const Duration(milliseconds: 50));
        if (mounted) _showDocumentUploadBottomSheet(context);
        await _uploadAndAdd();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking document: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Documents'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : activities.every((a) => a.documents.isEmpty)
          ? LottieEmpty(title: 'Upload documents')
          : _buildDocumentList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDocumentUploadBottomSheet(context),
        backgroundColor: AppColors.aphrcGreen,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_outlined),
      ),
    );
  }

  Widget _buildDocumentList() {
    final allDocuments = activities
        .expand((activity) => activity.documents)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: allDocuments.length,
      itemBuilder: (context, index) {
        final document = allDocuments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.aphrcGreen),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            leading: Icon(
              getDocumentIcon(document.extension),
              size: 36,
              color: getDocumentColor(document.extension),
            ),
            title: Text(
              document.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.aphrcGreen,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(
              children: [
                Text(
                  document.userLogin,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatDate(document.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8), // spacing between date and size
                Text(
                  document.size, // assuming size is like "2 MB" or "150 KB"
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),


              trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (value) async {
                switch (value) {
                  case 'download':
                    try {
                      await downloadAndOpenFile(
                      url: document.url,
                      fileName: document.title,
                      token: _accessToken ?? '',
                      context: context, // Make sure you have access to BuildContext here
                      );
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to download: ${e.toString()}')),
                        );
                      }
                    }
                    break;
                  case 'copy_url':
                  // Implement copy URL functionality
                    break;
                  case 'rename':
                  // Implement rename functionality
                    break;
                  case 'delete':
                  // Implement delete functionality
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'download',
                  child: Row(
                    children: [
                      Icon(Icons.download, size: 20),
                      SizedBox(width: 8),
                      Text('Download'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'copy_url',
                  child: Row(
                    children: [
                      Icon(Icons.link, size: 20),
                      SizedBox(width: 8),
                      Text('Copy URL'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'rename',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Rename'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
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

  @override
  void dispose() {
    _saveNotifier.dispose();
    _uploadNotifier.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
