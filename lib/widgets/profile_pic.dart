import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePic extends StatefulWidget {
  final String image;
  final Function(File file)? onImageSelected;
  final double size;

  const ProfilePic({
    super.key,
    required this.image,
    this.onImageSelected,
    this.size = 120,
  });

  @override
  State<ProfilePic> createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() => _selectedImage = file);
      _showLoadingDialog();

      await Future.delayed(const Duration(seconds: 2));

      if (context.mounted) Navigator.pop(context);
      widget.onImageSelected?.call(file);

      Fluttertoast.showToast(
        msg: "Profile picture updated!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFF00BF6D),
        textColor: Colors.white,
        fontSize: 16,
      );
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00BF6D),
        ),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _selectedImage != null
        ? FileImage(_selectedImage!)
        : (widget.image.isNotEmpty
        ? NetworkImage(widget.image)
        : const AssetImage('assets/default_avatar.png')) as ImageProvider;

    final double radius = widget.size / 2;

    return Center(
      child: SizedBox(
        height: widget.size + 20,
        width: widget.size + 20,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: radius,
              backgroundColor: Colors.white,
              backgroundImage: imageProvider,
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00BF6D),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: widget.size * 0.15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
