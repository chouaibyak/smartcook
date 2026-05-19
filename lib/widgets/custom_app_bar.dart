import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {

  final VoidCallback? onProfileTap;

  const CustomAppBar({
    super.key,
    this.onProfileTap,
  });

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,

      // PROFILE IMAGE
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),

        child: GestureDetector(
          onTap: onProfileTap,

          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade200,

            child: const Icon(
              Icons.person,
              color: Colors.grey,
              size: 20,
            ),
          ),
        ),
      ),

      // TITLE
      title: const Text(
        "SmartCook",
        style: TextStyle(
          color: Color(0xFF064439),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),

      // NOTIFICATIONS
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [

            IconButton(
              onPressed: () {
                print("Notification cliquée");
              },

              icon: const Icon(
                Icons.notifications_none,
                color: Colors.black87,
              ),
            ),

            Positioned(
              right: 12,
              top: 12,

              child: Container(
                height: 8,
                width: 8,

                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 8),
      ],
    );
  }
}