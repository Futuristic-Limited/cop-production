import 'package:flutter/material.dart';

class FullScreenPhoto extends StatefulWidget {
  final String imageUrl;
  final String? userName;
  final String? groupName;
  final String? downloadUrl;

  const FullScreenPhoto({
    Key? key,
    required this.imageUrl,
    this.userName,
    this.groupName,
    this.downloadUrl,
  }) : super(key: key);

  @override
  _FullScreenPhotoState createState() => _FullScreenPhotoState();
}

class _FullScreenPhotoState extends State<FullScreenPhoto> {
  bool _showOverlay = true;
  late TransformationController _transformationController;
  late InteractiveViewer _interactiveViewer;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _interactiveViewer = InteractiveViewer(
      transformationController: _transformationController,
      boundaryMargin: EdgeInsets.all(20),
      minScale: 0.1,
      maxScale: 4.0,
      child: Image.network(
        widget.imageUrl,
        fit: BoxFit.contain,
      ),
    );
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  void _downloadImage() {
    if (widget.downloadUrl == null) return;
    // Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download started')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleOverlay,
        child: Stack(
          children: [
            Center(child: _interactiveViewer),

            // Top Controls
            if (_showOverlay)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                child: Row(
                  children: [
                    // Download Button
                    if (widget.downloadUrl != null)
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.white),
                        onPressed: _downloadImage,
                      ),
                    // Close Button
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

            // Bottom Info
            if (_showOverlay && (widget.userName != null || widget.groupName != null))
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // User Avatar Placeholder
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            widget.userName?.isNotEmpty == true
                                ? widget.userName![0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // User and Group Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.userName != null)
                              Text(
                                widget.userName!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (widget.groupName != null)
                              Text(
                                widget.groupName!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                          ],
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
  }
}