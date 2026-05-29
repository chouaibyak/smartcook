import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final List<Widget>? actions;
  final String title;
  final bool centerTitle;
  final VoidCallback? onProfileTap;

  const CustomAppBar({
    super.key,
    this.leading,
    this.actions,
    this.title = "SmartCook",
    this.centerTitle = true,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: centerTitle,
      leading: leading ??
          GestureDetector(
            onTap: onProfileTap,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person, color: Colors.grey, size: 20),
              ),
            ),
          ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF064439),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: actions,
    );
  }
}
