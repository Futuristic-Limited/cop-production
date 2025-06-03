import 'package:flutter/material.dart';

class MyListTiles extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? OnTap;

  const MyListTiles({
    super.key,
    required this.icon,
    required this.text,
    required this.OnTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      onTap: OnTap,
      hoverColor: Colors.grey.shade100,
    );
  }
}
