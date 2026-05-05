import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  // Cette ligne est obligatoire pour un AppBar personnalisé
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0, // Supprime l'ombre pour un look plat comme sur l'image
      centerTitle: true,
      
      // Partie gauche : Photo de profil
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey.shade200,
          // Remplace par ton image locale ou NetworkImage
          child: const Icon(Icons.person, color: Colors.grey, size: 20),
        ),
      ),

      // Partie centrale : Titre / Logo
      title: const Text(
        "SmartCook",
        style: TextStyle(
          color: Color(0xFF064439), // Ton vert foncé primaryDark
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),

      // Partie droite : Cloche de notification
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              onPressed: () {
                print("Notification cliquée");
              },
              icon: const Icon(Icons.notifications_none, color: Colors.black87),
            ),
            // Petit point rouge si tu as une notification (optionnel)
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