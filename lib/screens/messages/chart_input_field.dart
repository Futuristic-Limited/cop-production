import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatInputField extends StatefulWidget {
  final Function(String) onSendMessage;

  const ChatInputField({super.key, required this.onSendMessage});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  File? _pickedFile;

  void _pickFile() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedFile = File(picked.path);
      });
    }
  }

  void _takePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _pickedFile = File(picked.path);
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty && _pickedFile == null) return;
    widget.onSendMessage(_controller.text.trim());
    _controller.clear();
    setState(() {
      _pickedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_pickedFile != null)
          Container(
            margin: const EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: Stack(
              children: [
                Image.file(
                  _pickedFile!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      setState(() => _pickedFile = null);
                    },
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white, // Moved the color here
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: _pickFile,
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: _takePicture,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                  ),
                  onTap: () => {},
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

