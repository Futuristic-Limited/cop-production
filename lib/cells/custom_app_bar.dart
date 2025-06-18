import 'package:flutter/material.dart';
import 'package:APHRC_COP/notifiers/profile_photo_notifier.dart';
import 'package:APHRC_COP/services/shared_prefs_service.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, this.title = 'APHRC Community of Practice'});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final savedPhotoUrl = await SharedPrefsService.getProfilePhotoUrl();
    final username = await SharedPrefsService.getUserName();
    if (savedPhotoUrl != null && savedPhotoUrl.isNotEmpty) {
      ProfilePhotoNotifier.profilePhotoUrl.value = savedPhotoUrl;
    }
    if (username != null && username.isNotEmpty) {
      ProfilePhotoNotifier.username.value = username;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        widget.title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: Colors.white,
          shadows: [
            Shadow(
              offset: Offset(0, 1),
              blurRadius: 2,
              color: Colors.black26,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 4,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6ABF43),
              Color(0xFF4C9B23),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ValueListenableBuilder<String>(
            valueListenable: ProfilePhotoNotifier.profilePhotoUrl,
            builder: (context, photoUrl, _) {
              return ValueListenableBuilder<String>(
                valueListenable: ProfilePhotoNotifier.username,
                builder: (context, username, _) {
                  return PopupMenuButton<dynamic>(
                    elevation: 5,
                    color: Colors.white,
                    offset: const Offset(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<dynamic>>[
                      // User header section
                      PopupMenuItem<dynamic>(
                        enabled: false,
                        height: 70,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: photoUrl.isNotEmpty
                                      ? NetworkImage(photoUrl)
                                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Welcome',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      username.isNotEmpty ? username : 'Guest',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(height: 1, thickness: 1),
                          ],
                        ),
                      ),
                      // Menu items
                      PopupMenuItem<dynamic>(
                        height: 40,
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.person, size: 20),
                          title: const Text('Profile', style: TextStyle(fontSize: 14)),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/profile');
                          },
                        ),
                      ),
                      const PopupMenuDivider(height: 1),
                      PopupMenuItem<dynamic>(
                        height: 40,
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.email, size: 20),
                          title: const Text('Email Invites', style: TextStyle(fontSize: 14)),
                          onTap: () {
                            Navigator.pop(context);
                            // Add email invites navigation
                          },
                        ),
                      ),
                      const PopupMenuDivider(height: 1),
                      PopupMenuItem<dynamic>(
                        height: 40,
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.settings, size: 20),
                          title: const Text('Settings', style: TextStyle(fontSize: 14)),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                      ),
                    ],
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : const AssetImage('assets/default_avatar.png') as ImageProvider,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}