import 'package:flutter/material.dart';

class ForgotPasswordLink extends StatelessWidget {
  final VoidCallback onTap;

  const ForgotPasswordLink({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.lock_open, color: Color(0xFF7BC148), size: 20),
          SizedBox(width: 6),
          Text(
            'Forgot Password?',
            style: TextStyle(
              color: Color(0xFF7BC148),
              fontWeight: FontWeight.w600,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
