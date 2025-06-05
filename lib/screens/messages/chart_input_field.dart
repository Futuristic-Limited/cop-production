import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

// !keep to see if being tracked by git
// ios/Runner/Info.plist
// android/app/src/main/AndroidManifest.xml
class ChatInputField extends StatefulWidget {
  final Function(String message, List<File> attachments) onSendMessage;
  final int maxVideoDurationSeconds;
  final int maxFileSizeMB;

  const ChatInputField({
    super.key,
    required this.onSendMessage,
    this.maxVideoDurationSeconds = 120,
    this.maxFileSizeMB = 50,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  List<File> _pickedFiles = [];
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedFiles.add(File(picked.path)));
    }
  }

  Future<void> _takePicture() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _pickedFiles.add(File(picked.path)));
    }
  }

  Future<void> _pickVideo() async {
    try {
      final picked = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: Duration(seconds: widget.maxVideoDurationSeconds),
      );
      if (picked != null) {
        final file = File(picked.path);
        if (await _validateVideo(file)) {
          setState(() => _pickedFiles.add(file));
        }
      }
    } catch (e) {
      await _showErrorDialog('Failed to pick video: ${e.toString()}');
    }
  }

  Future<void> _recordVideo() async {
    try {
      final picked = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: Duration(seconds: widget.maxVideoDurationSeconds),
      );
      if (picked != null) {
        final file = File(picked.path);
        if (await _validateVideo(file)) {
          setState(() => _pickedFiles.add(file));
        }
      }
    } catch (e) {
      await _showErrorDialog('Failed to record video: ${e.toString()}');
    }
  }

  Future<bool> _validateVideo(File file) async {
    try {
      // Check file size
      final sizeInMB = await file.length() / (1024 * 1024);
      if (sizeInMB > widget.maxFileSizeMB) {
        await _showErrorDialog(
          'Video too large (${sizeInMB.toStringAsFixed(1)}MB). '
          'Maximum allowed: ${widget.maxFileSizeMB}MB',
        );
        return false;
      }

      return true;
    } catch (e) {
      await _showErrorDialog('Failed to validate video: ${e.toString()}');
      return false;
    }
  }

  Future<void> _pickAnyFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result != null) {
      setState(() {
        _pickedFiles.addAll(result.paths.map((path) => File(path!)).toList());
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() => _pickedFiles.removeAt(index));
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty && _pickedFiles.isEmpty) return;
    widget.onSendMessage(_controller.text.trim(), _pickedFiles);
    _controller.clear();
    setState(() => _pickedFiles.clear());
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Photo Library'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePicture();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_library),
                  title: const Text('Video Library'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickVideo();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: const Text('Record Video'),
                  onTap: () {
                    Navigator.pop(context);
                    _recordVideo();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: const Text('Other Files'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAnyFile();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<Widget> _buildVideoThumbnail(File videoFile) async {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoFile.path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 100,
      quality: 75,
    );

    return thumbnailPath != null
        ? Image.file(
          File(thumbnailPath),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        )
        : Container(
          width: 100,
          height: 100,
          color: Colors.grey[200],
          child: const Icon(Icons.videocam, size: 40),
        );
  }

  Widget _buildAttachmentPreview(File file, int index) {
    final isImage = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
    ].any((ext) => file.path.toLowerCase().endsWith(ext));
    final isVideo = [
      '.mp4',
      '.mov',
      '.avi',
    ].any((ext) => file.path.toLowerCase().endsWith(ext));

    return Container(
      margin: const EdgeInsets.all(4),
      child: Stack(
        children: [
          if (isImage)
            Image.file(file, width: 100, height: 100, fit: BoxFit.cover)
          else if (isVideo)
            FutureBuilder(
              future: _buildVideoThumbnail(file),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return snapshot.data ??
                      Container(
                        width: 100,
                        height: 100,
                        color: const Color.fromARGB(255, 141, 95, 95),
                        child: const Icon(Icons.videocam, size: 40),
                      );
                }
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const CircularProgressIndicator(),
                );
              },
            )
          else
            Container(
              width: 100,
              height: 100,
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.insert_drive_file, size: 40),
                  Text(
                    file.path.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
              onPressed: () => _removeAttachment(index),
            ),
          ),
          if (isVideo)
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_pickedFiles.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pickedFiles.length,
              itemBuilder: (context, index) {
                return _buildAttachmentPreview(_pickedFiles[index], index);
              },
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _showAttachmentOptions,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.green),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
