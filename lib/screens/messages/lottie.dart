import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieEmpty extends StatelessWidget {
  const LottieEmpty({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/empty.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}

