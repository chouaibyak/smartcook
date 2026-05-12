import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class InitialProfileScreen extends StatefulWidget {
final String token;

//  : données user/login
final Map<String, dynamic>? result;

const InitialProfileScreen({
  Key? key,
  required this.token,
  this.result,
}) : super(key: key);




  @override
  State<InitialProfileScreen> createState() => _InitialProfileScreenState();
}

class _InitialProfileScreenState extends State<InitialProfileScreen> {
  final Color green = const Color(0xFF0B5D3B);

  final heightController = TextEditingController(text: "175");
  final weightController = TextEditingController(text: "70");

  String selectedGoal = "Maintain health";

  final List<String> selectedAllergies = ["gluten", "seafood"];
  final List<String> selectedHealth = ["hypertension"];
  final List<String> selectedDiet = ["vegetarian", "high protein"];

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void toggleItem(List<String> list, String item) {
    setState(() {
      if (list.contains(item)) {
        list.remove(item);
      } else {
        list.add(item);
      }
    });
  }

  void continueToApp() async {
    final profileData = {
      "taille": double.tryParse(heightController.text),
      "poids": double.tryParse(weightController.text),
      "objectif": selectedGoal,
      "allergies": selectedAllergies,
      "sante": selectedHealth,
      "diet": selectedDiet,
    };

    // Appel au service avec le token reçu du constructeur
    bool success = await AuthService.completeProfile(widget.token, profileData);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved on server")),
      );

      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) =>HomeScreen(
  result: widget.result,
))
        );
    
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error saving profile"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            children: [
              _header(),
              const SizedBox(height: 28),
              const Text(
                "Welcome to your\npersonal kitchen",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF003F22),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "Let's tailor your SmartCook experience to\nyour health and taste preferences.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
              ),
              const SizedBox(height: 28),

              _card(
                title: "Biometrics",
                icon: Icons.straighten,
                color: green,
                child: Column(
                  children: [
                    _input("Height (cm)", heightController),
                    const SizedBox(height: 14),
                    _input("Weight (kg)", weightController),
                  ],
                ),
              ),

              _card(
                title: "Your Goal",
                icon: Icons.track_changes,
                color: green,
                child: Column(
                  children: [
                    _goalOption("Lose weight"),
                    const SizedBox(height: 12),
                    _goalOption("Maintain health"),
                    const SizedBox(height: 12),
                    _goalOption("Gain weight/muscle"),
                  ],
                ),
              ),

              _card(
                title: "Allergies & Sensitivities",
                icon: Icons.warning_amber_outlined,
                color: Colors.red,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select any items we should strictly avoid in\nyour recipes.",
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _chip("gluten", selectedAllergies, Colors.red),
                        _chip("lactose", selectedAllergies, Colors.red),
                        _chip("nuts", selectedAllergies, Colors.red),
                        _chip("seafood", selectedAllergies, Colors.red),
                      ],
                    ),
                  ],
                ),
              ),

              _card(
                title: "Health Profile",
                icon: Icons.medical_services_outlined,
                color: const Color(0xFFB32600),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    _healthBox("diabetes", Icons.bloodtype_outlined),
                    _healthBox("hypertension", Icons.monitor_heart_outlined),
                    _healthBox("cholesterol", Icons.favorite_border),
                    _healthBox("other", Icons.add_circle_outline),
                  ],
                ),
              ),

              _card(
                title: "Dietary Preferences",
                icon: Icons.restaurant,
                color: green,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _chip("vegetarian", selectedDiet, green),
                    _chip("vegan", selectedDiet, green),
                    _chip("halal", selectedDiet, green),
                    _chip("high protein", selectedDiet, green),
                    _chip("low sugar", selectedDiet, green),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: continueToApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Continue to App",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),
              const Text(
                "You can update these settings anytime in your profile.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            "SmartCook",
            style: TextStyle(
              color: green,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          CircleAvatar(
            radius: 18,
            backgroundColor: green,
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF1F1F1),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          ),
        ),
      ],
    );
  }

  Widget _goalOption(String text) {
    final bool selected = selectedGoal == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = text;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFFB5C3B8) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? green : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, List<String> list, Color activeColor) {
    final bool selected = list.contains(text);

    return GestureDetector(
      onTap: () => toggleItem(list, text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withOpacity(0.25)
              : const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          selected ? "✓ $text" : text,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _healthBox(String text, IconData icon) {
    final bool selected = selectedHealth.contains(text);

    return GestureDetector(
      onTap: () => toggleItem(selectedHealth, text),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF7A3D) : const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: const Color(0xFFB32600), width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : const Color(0xFFB32600),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}