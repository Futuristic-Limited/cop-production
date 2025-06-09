import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:APHRC_COP/services/user_upload_service.dart';
import 'package:APHRC_COP/utils/download_util.dart';
import 'package:APHRC_COP/widgets/photo_viewer.dart';
import 'package:APHRC_COP/widgets/video_player_popup.dart';
import 'package:APHRC_COP/widgets/document_viewer.dart';

class UserUploadsScreen extends StatefulWidget {
  const UserUploadsScreen({Key? key}) : super(key: key);

  @override
  State<UserUploadsScreen> createState() => _UserUploadsScreenState();
}

class _UserUploadsScreenState extends State<UserUploadsScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _uploadsFuture;
  List<Map<String, dynamic>> _allUploads = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _uploadsFuture = UserUploadService.fetchUserUploads();
  }

  bool isImage(String mime) => mime.startsWith('image/');
  bool isVideo(String mime) => mime.startsWith('video/');
  bool isDocument(String mime) =>
      mime == 'application/pdf' ||
          mime.contains('msword') ||
          mime.contains('officedocument');

  List<Map<String, dynamic>> filterUploads(String type) {
    return _allUploads.where((upload) {
      final mime = upload['post_mime_type'];
      final title = upload['post_title']?.toString().toLowerCase() ?? '';
      final matchesSearch = title.contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      return (type == 'photo' && isImage(mime)) ||
          (type == 'video' && isVideo(mime)) ||
          (type == 'doc' && isDocument(mime));
    }).toList();
  }

  Widget buildGridItem(Map<String, dynamic> upload, String type) {
    final id = int.tryParse(upload['ID'].toString()) ?? 0;
    final title = upload['post_title'] ?? 'Untitled';
    final mime = upload['post_mime_type'];
    final url = upload['guid'];

    return GestureDetector(
      onTap: () async {
        if (type == 'photo') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PhotoViewerScreen(imageId: id, title: title),
            ),
          );
        } else if (type == 'video') {
          showDialog(
            context: context,
            builder: (_) => VideoPlayerPopup(videoUrl: url),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DocumentViewer(title: title, url: url),
            ),
          );
        }
      },
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Center(
              child: type == 'photo'
                  ? FutureBuilder<Uint8List?>(
                future: UserUploadService.getUserImage(id)
                    .then((r) => r.bodyBytes),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    );
                  } else {
                    return const Icon(
                      Icons.image,
                      size: 48,
                      color: Colors.grey,
                    );
                  }
                },
              )
                  : Icon(
                type == 'video' ? Icons.video_library : Icons.insert_drive_file,
                size: 48,
                color: Colors.green,
              ),
            ),
            // Title Overlay at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 28, // leave space above download button
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                color: Colors.black54,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Download button bottom right
            Positioned(
              bottom: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.download, size: 20),
                onPressed: () async {
                  await DownloadUtil.downloadFile(url, title);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Downloading $title...')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabContent(String type) {
    final filtered = filterUploads(type);
    if (filtered.isEmpty) {
      return const Center(child: Text('No uploads found.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filtered.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, index) {
        return buildGridItem(filtered[index], type);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          title: const Text('Files'),
          backgroundColor: const Color(0xFF79C148),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.image), text: "Photos"),
              Tab(icon: Icon(Icons.insert_drive_file), text: "Documents"),
              Tab(icon: Icon(Icons.video_library), text: "Videos"),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: TextField(
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
                decoration: const InputDecoration(
                  hintText: "Search by title...",
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _uploadsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No uploads found.'));
                  }

                  _allUploads = snapshot.data!;
                  return const TabBarView(
                    children: [
                      // Filtered views
                      _TabView(type: 'photo'),
                      _TabView(type: 'doc'),
                      _TabView(type: 'video'),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabView extends StatelessWidget {
  final String type;
  const _TabView({required this.type});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (_) {
        final state = context.findAncestorStateOfType<_UserUploadsScreenState>();
        return state?.buildTabContent(type) ?? const SizedBox();
      },
    );
  }
}
