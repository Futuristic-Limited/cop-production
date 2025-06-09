import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
final String title;

const CustomAppBar({Key? key, this.title = 'APHRC Community of Practice'})
    : super(key: key);

@override
Widget build(BuildContext context) {
return AppBar(
title: Text(
title,
style: const TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
color: Colors.white,
),
),
backgroundColor: const Color.fromRGBO(123, 193, 72, 1),
elevation: 0,
iconTheme: const IconThemeData(color: Colors.white),
);
}

@override
Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

