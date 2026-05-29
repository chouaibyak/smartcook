import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import 'initial_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String token;

  const ProfileScreen({
    super.key,
    required this.token,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
      print("PROFILE PAGE OPENED");

    loadProfile();

    
  }
Future<void> loadProfile() async {
  print("LOAD PROFILE START");

  final token = widget.token;

  final data = await AuthService.getProfile(token);

  print("PROFILE RESPONSE = $data");

  if (!mounted) return;

  setState(() {
    profile = data;
    isLoading = false;
  });
}

  String getValue(String key) {
    final value = profile?[key];

    if (value == null) return "Not provided";

    final text = value.toString();

    if (text.isEmpty || text == "[]" || text == "null") {
      return "Not provided";
    }

    return text
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '');
  }

  @override
  Widget build(BuildContext context) {

    print("PROFILE VARIABLE = $profile");
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F4F4),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF0B5D3B),
          ),
        ),
      );
    }

    if (profile == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F4F4),
        body: Center(
          child: Text("Unable to load profile"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

   appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  title: const Text(
    "Profile",
    style: TextStyle(
      color: Color(0xFF0B5D3B),
      fontWeight: FontWeight.bold,
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.black),
),
      body: RefreshIndicator(
        onRefresh: loadProfile,
        color: const Color(0xFF0B5D3B),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // PROFILE CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                 Stack(
  children: [

    CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey.shade200,

      child: const Icon(
        Icons.person,
        size: 50,
        color: Colors.grey,
      ),
    ),

    Positioned(
      bottom: 0,
      right: 0,

      child: Container(
        padding: const EdgeInsets.all(10),

        decoration: const BoxDecoration(
          color: Color(0xFF0B5D3B),
          shape: BoxShape.circle,
        ),

        child: const Icon(
          Icons.edit,
          color: Colors.white,
          size: 18,
        ),
      ),
    ),
  ],
),
                     
                    

                    const SizedBox(height: 20),

                    Text(
                      getValue("nom"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      getValue("email"),
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _tag(
                          "SmartCook User",
                          Colors.green.shade50,
                          Colors.green,
                        ),
                        const SizedBox(width: 10),
                        _tag(
                          "Healthy Profile",
                          Colors.orange.shade50,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // DAILY GOAL
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D57),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Daily Goal",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      getValue("objectifNutritionnel"),
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Calorie Target",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "2,200 / 2,500",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: const LinearProgressIndicator(
                        value: 0.8,
                        minHeight: 10,
                        backgroundColor: Colors.black12,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // BIOMETRICS
              _sectionCard(
                title: "Biometrics",
                icon: Icons.monitor_weight_outlined,
                child: Row(
                  children: [
                    Expanded(
                      child: _miniCard(
                        "HEIGHT",
                        getValue("taille"),
                        "cm",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _miniCard(
                        "WEIGHT",
                        getValue("poids"),
                        "kg",
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // DIETARY STYLE
              _sectionCard(
                title: "Dietary Style",
                icon: Icons.restaurant,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _dietTag(getValue("preferencesAlimentaires")),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ALLERGIES
              _sectionCard(
                title: "Allergies",
                icon: Icons.warning_amber_outlined,
                child: _allergyCard(
                  getValue("allergies"),
                  "Info",
                  Colors.red,
                ),
              ),

              const SizedBox(height: 18),

              // HEALTH NOTES
              _sectionCard(
                title: "Health Notes",
                icon: Icons.health_and_safety_outlined,
                child: Text(
                  getValue("conditionsSante"),
                  style: const TextStyle(
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // EDIT PROFILE
            // EDIT PROFILE
SizedBox(
  width: double.infinity,
  height: 52,
  child: ElevatedButton.icon(

    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0B5D3B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),

    onPressed: () {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InitialProfileScreen(

            token: widget.token,

            result: {
              "token": widget.token,

              "user": {
                "id": profile?["id"],
                "nom": profile?["nom"],
                "email": profile?["email"],
              },
            },
          ),
        ),
      );
    },

    icon: const Icon(
      Icons.settings,
      color: Colors.white,
    ),

    label: const Text(
      "Edit Profile",
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),

              const SizedBox(height: 12),

              // LOGOUT
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (_) => const LoginScreen(),
  ),
  (route) => false,
);                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

);

   
    
  }

  static Widget _tag(String text, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black87),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  static Widget _miniCard(String title, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(unit),
              )
            ],
          ),
        ],
      ),
    );
  }

  static Widget _dietTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0B5D3B),
        ),
      ),
    );
  }

  static Widget _allergyCard(String title, String level, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: color),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 17),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              level,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
