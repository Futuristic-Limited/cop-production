import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AnimatedAppDrawerState();
}

class _AnimatedAppDrawerState extends State<AppDrawer>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    const itemCount = 4;
    _slideAnimations = List.generate(
      itemCount,
          (index) => Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedDrawerItem(
      int index,
      IconData icon,
      String title,
      BuildContext context,
      String route,
      ) {
    return SlideTransition(
      position: _slideAnimations[index],
      child: HoverCard(
        baseColor: Colors.white,
        hoverColor: Colors.grey.shade100,
        child: ListTile(
          leading: Icon(icon, color: Colors.green),
          title: Text(title, style: const TextStyle(fontSize: 16, color: Colors.black)),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, route);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topMargin = MediaQuery.of(context).size.height * 0.135;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(top: topMargin),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
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
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildAnimatedDrawerItem(0, Icons.login, 'Login', context, '/login'),
                  _buildAnimatedDrawerItem(1, Icons.app_registration, 'Sign Up', context, '/register'),
                  _buildAnimatedDrawerItem(2, Icons.event, 'Events', context, '/events'),
                  _buildAnimatedDrawerItem(3, Icons.rule, 'Community Guidelines', context, '/guidelines'),
                ],
              ),
            ),
          ],
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



//
//
// import 'package:flutter/material.dart';
//
// class AppDrawer extends StatelessWidget {
//   const AppDrawer({super.key});
//
//   Widget _buildDrawerItem(
//       IconData icon,
//       String title,
//       BuildContext context,
//       String route,
//       ) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.green),
//       title: Text(title, style: const TextStyle(fontSize: 16)),
//       onTap: () {
//         Navigator.pop(context);
//         Navigator.pushNamed(context, route);
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: Column(
//         children: [
//           DrawerHeader(
//             decoration: const BoxDecoration(
//               color: Color.fromRGBO(123, 193, 72, 1),
//             ),
//             child: Row(
//               children: const [
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundColor: Colors.white,
//                   child: Icon(Icons.group, color: Colors.green, size: 30),
//                 ),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'Community Hub',
//                     style: TextStyle(
//                       fontSize: 20,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               children: [
//                 _buildDrawerItem(Icons.login, 'Login', context, '/login'),
//                 _buildDrawerItem(
//                   Icons.app_registration,
//                   'Sign Up',
//                   context,
//                   '/register',
//                 ),
//                 _buildDrawerItem(Icons.event, 'Events', context, '/events'),
//                 _buildDrawerItem(
//                   Icons.rule,
//                   'Community Guidelines',
//                   context,
//                   '/guidelines',
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }