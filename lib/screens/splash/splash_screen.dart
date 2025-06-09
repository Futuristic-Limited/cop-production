import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/shared_prefs_service.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Timer(const Duration(seconds: 4), () async {
      bool isLoggedIn = await SharedPrefsService.isLoggedIn();
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          isLoggedIn ? '/home' : '/landing',
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF79C148), // APHRC green
      body: Stack(
        children: [
          const BubbleBackground(),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x6679C148), Color(0xFF79C148)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/logo_aphrc_1.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // App Name
                    const Text(
                      'APHRC COP',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        fontFamily: 'Roboto',
                        height: 1.3,
                      ),
                    ),




                    const SizedBox(height: 8),

                    // Tagline – elegant and centered
                    const Text(
                      'Empowering Communities\nAdvancing African Research',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontStyle: FontStyle.italic,
                        color: Colors.white60,
                        height: 1.4,
                        letterSpacing: 0.4,
                        fontFamily: 'Roboto',
                      ),
                    ),

                    const SizedBox(height: 32),

                    const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class BubbleBackground extends StatefulWidget {
  const BubbleBackground({super.key});

  @override
  State<BubbleBackground> createState() => _BubbleBackgroundState();
}

class _BubbleBackgroundState extends State<BubbleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _bubbleController;
  final List<Bubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    for (int i = 0; i < 25; i++) {
      _bubbles.add(Bubble());
    }
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bubbleController,
      builder: (context, child) {
        return CustomPaint(
          painter: BubblePainter(_bubbles, _bubbleController.value),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

class Bubble {
  late double x, y, radius, speed;
  late Color color;

  Bubble() {
    final rand = Random();
    x = rand.nextDouble();
    y = rand.nextDouble();
    radius = rand.nextDouble() * 10 + 4;
    speed = rand.nextDouble() * 0.004 + 0.002;
    color = Colors.white.withOpacity(0.08 + rand.nextDouble() * 0.2);
  }
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double progress;

  BubblePainter(this.bubbles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var bubble in bubbles) {
      double dx = bubble.x * size.width;
      double dy = size.height -
          ((bubble.y + bubble.speed * progress * 1000) % size.height);
      paint.color = bubble.color;
      canvas.drawCircle(Offset(dx, dy), bubble.radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
