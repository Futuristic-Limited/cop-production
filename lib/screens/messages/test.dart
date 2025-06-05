// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';

// class ChatInputField extends StatefulWidget {
//   final Function(String message, List<File> attachments) onSendMessage;
//   final int maxVideoDurationSeconds; // Maximum allowed duration in seconds
//   final int maxFileSizeMB; // Maximum allowed file size in MB

//   const ChatInputField({
//     super.key,
//     required this.onSendMessage,
//     this.maxVideoDurationSeconds = 120, // Default 2 minutes
//     this.maxFileSizeMB = 50, // Default 50MB
//   });

//   @override
//   State<ChatInputField> createState() => _ChatInputFieldState();
// }

// class _ChatInputFieldState extends State<ChatInputField> {
//   final TextEditingController _controller = TextEditingController();
//   List<File> _pickedFiles = [];
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _showErrorDialog(String message) async {
//     await showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Error'),
//             content: Text(message),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//     );
//   }

//   Future<bool> _validateVideo(File file) async {
//     try {
//       // Check file size
//       final sizeInMB = await file.length() / (1024 * 1024);
//       if (sizeInMB > widget.maxFileSizeMB) {
//         await _showErrorDialog(
//           'Video too large (${sizeInMB.toStringAsFixed(1)}MB). '
//           'Maximum allowed: ${widget.maxFileSizeMB}MB',
//         );
//         return false;
//       }

//       return true;
//     } catch (e) {
//       await _showErrorDialog('Failed to validate video: ${e.toString()}');
//       return false;
//     }
//   }

//   // Alternative duration check without video_player
//   Future<bool> _checkVideoDuration(File file) async {
//     try {
//       // This is a placeholder - actual implementation would use video_player package
//       // or platform-specific code to get duration
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   Future<void> _pickVideo() async {
//     try {
//       final picked = await _picker.pickVideo(
//         source: ImageSource.gallery,
//         maxDuration: Duration(seconds: widget.maxVideoDurationSeconds),
//       );
//       if (picked != null) {
//         final file = File(picked.path);
//         if (await _validateVideo(file)) {
//           setState(() => _pickedFiles.add(file));
//         }
//       }
//     } catch (e) {
//       await _showErrorDialog('Failed to pick video: ${e.toString()}');
//     }
//   }

//   Future<void> _recordVideo() async {
//     try {
//       final picked = await _picker.pickVideo(
//         source: ImageSource.camera,
//         maxDuration: Duration(seconds: widget.maxVideoDurationSeconds),
//       );
//       if (picked != null) {
//         final file = File(picked.path);
//         if (await _validateVideo(file)) {
//           setState(() => _pickedFiles.add(file));
//         }
//       }
//     } catch (e) {
//       await _showErrorDialog('Failed to record video: ${e.toString()}');
//     }
//   }

//   Future<Widget> _buildVideoThumbnail(File videoFile) async {
//     try {
//       final thumbnailPath = await VideoThumbnail.thumbnailFile(
//         video: videoFile.path,
//         imageFormat: ImageFormat.JPEG,
//         maxHeight: 100,
//         quality: 75,
//         timeMs: 1000, // Get thumbnail at 1 second mark
//       );

//       if (thumbnailPath != null) {
//         return Image.file(
//           File(thumbnailPath),
//           width: 100,
//           height: 100,
//           fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) => _buildFallbackThumbnail(),
//         );
//       }
//       return _buildFallbackThumbnail();
//     } catch (e) {
//       debugPrint('Thumbnail generation failed: $e');
//       return _buildFallbackThumbnail();
//     }
//   }

//   Widget _buildFallbackThumbnail() {
//     return Container(
//       width: 100,
//       height: 100,
//       color: Colors.grey[200],
//       child: const Icon(Icons.videocam, size: 40),
//     );
//   }

//   Widget _buildAttachmentPreview(File file, int index) {
//     final isImage = [
//       '.jpg',
//       '.jpeg',
//       '.png',
//       '.gif',
//     ].any((ext) => file.path.toLowerCase().endsWith(ext));
//     final isVideo = [
//       '.mp4',
//       '.mov',
//       '.avi',
//     ].any((ext) => file.path.toLowerCase().endsWith(ext));

//     return Container(
//       margin: const EdgeInsets.all(4),
//       child: Stack(
//         children: [
//           if (isImage)
//             Image.file(
//               file,
//               width: 100,
//               height: 100,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => _buildFallbackThumbnail(),
//             )
//           else if (isVideo)
//             FutureBuilder(
//               future: _buildVideoThumbnail(file),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   return snapshot.data ?? _buildFallbackThumbnail();
//                 }
//                 return _buildFallbackThumbnail();
//               },
//             )
//           else
//             Container(
//               width: 100,
//               height: 100,
//               color: Colors.grey[200],
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.insert_drive_file, size: 40),
//                   Text(
//                     file.path.split('/').last,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           Positioned(
//             top: 0,
//             right: 0,
//             child: IconButton(
//               icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
//               onPressed: () => _removeAttachment(index),
//             ),
//           ),
//           if (isVideo)
//             const Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Icon(
//                 Icons.play_circle_filled,
//                 color: Colors.white,
//                 size: 30,
//               ),
//             ),
//           if (isVideo)
//             Positioned(
//               bottom: 5,
//               right: 5,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: Colors.black54,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: FutureBuilder(
//                   future: _getVideoDuration(file),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasData) {
//                       return Text(
//                         _formatDuration(snapshot.data!),
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                         ),
//                       );
//                     }
//                     return const SizedBox();
//                   },
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Future<Duration> _getVideoDuration(File file) async {
//     // Note: This requires the video_player package
//     // For actual implementation you would use:
//     // final controller = VideoPlayerController.file(file);
//     // await controller.initialize();
//     // final duration = controller.value.duration;
//     // controller.dispose();
//     // return duration;

//     // Placeholder implementation
//     return const Duration(seconds: 0);
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final hours = twoDigits(duration.inHours);
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return "$hours:$minutes:$seconds";
//   }

//   // ... (keep the rest of your existing methods)
// }
