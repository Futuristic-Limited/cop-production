import 'package:flutter/material.dart';

class GroupSideMenu extends StatefulWidget {
  final Map<String, dynamic> group;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const GroupSideMenu({
    super.key,
    required this.group,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  State<GroupSideMenu> createState() => _GroupSideMenuState();
}

class _GroupSideMenuState extends State<GroupSideMenu> with TickerProviderStateMixin {
  late final AnimationController _drawerController;
  late final List<Animation<Offset>> _drawerAnimations;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    const itemCount = 6;
    _drawerAnimations = List.generate(
      itemCount,
          (index) => Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _drawerController,
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
        ),
      ),
    );

    _drawerController.forward();
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 18.0, left: 12.0, right: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 6,
                          offset: Offset(2, 2),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: const Opacity(
                      opacity: 0.85,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage('assets/logo_aphrc_1.png'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Community Hub',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _animatedMenuItem(
                      icon: Icons.home,
                      text: 'Home',
                      index: 0,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/home');
                      },
                    ),
                    _animatedMenuItem(
                      icon: Icons.forum,
                      text: 'Discussions',
                      index: 1,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(
                          context,
                          '/groups/discussions',
                          arguments: {'slug': widget.group['slug']},
                        );
                      },
                    ),
                    _animatedMenuItem(
                      icon: Icons.people,
                      text: 'Members',
                      index: 2,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(
                          context,
                          '/groups/members',
                          arguments: {'groupId': widget.group['id']},
                        );
                      },
                    ),
                    _animatedMenuItem(
                      icon: Icons.add_a_photo,
                      text: 'Photos',
                      index: 1,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(
                          context,
                          '/groups/photos',
                          arguments: {'groupId': widget.group['id']},
                        );
                      },
                    ),

                    _animatedMenuItem(
                      icon: Icons.video_call,
                      text: 'Videos',
                      index: 1,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(
                          context,
                          '/groups/videos',
                            arguments: {'groupId': widget.group['id']},
                        );
                      },
                    ),
                    _animatedMenuItem(
                      icon: Icons.folder,
                      text: 'Documents',
                      index: 1,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(
                          context,
                          '/groups/documents',
                          arguments: {'groupId': widget.group['id']},
                        );
                      },
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _animatedMenuItem({
    required IconData icon,
    required String text,
    required int index,
    required VoidCallback onTap,
  }) {
    final isSelected = index == widget.selectedIndex;
    return SlideTransition(
      position: _drawerAnimations[index],
      child: HoverCard(
        baseColor: Colors.white,
        hoverColor: Colors.grey.shade100,
        child: ListTile(
          selected: isSelected,
          leading: Icon(icon, color: Colors.green),
          title: Text(
            text,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class HoverCard extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color hoverColor;

  const HoverCard({
    super.key,
    required this.child,
    this.baseColor = Colors.white,
    this.hoverColor = const Color(0xFFF5F5F5),
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: _hovering ? widget.hoverColor : widget.baseColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hovering ? 0.2 : 0.1),
              blurRadius: _hovering ? 10 : 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
