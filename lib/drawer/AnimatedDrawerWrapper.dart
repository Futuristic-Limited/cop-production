import 'package:flutter/material.dart';
import '../../cells/custom_drawer.dart';

class AnimatedDrawerWrapper extends StatefulWidget {
  final bool isLoggedIn;
  final VoidCallback onLogout;

  const AnimatedDrawerWrapper({
    super.key,
    required this.isLoggedIn,
    required this.onLogout,
  });

  @override
  State<AnimatedDrawerWrapper> createState() => _AnimatedDrawerWrapperState();
}

class _AnimatedDrawerWrapperState extends State<AnimatedDrawerWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    )..forward();

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: CustomDrawer(
        isLoggedIn: widget.isLoggedIn,
        onLogout: widget.onLogout,
      ),
    );
  }
}
