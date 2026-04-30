import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'initial_profile_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool agree = false;
  bool isLoading = false;

  final Color green = const Color(0xFF0B5D3B);

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void validateRegister() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showMessage("Please fill in all fields");
      return;
    }

    if (!email.contains("@") || !email.contains(".")) {
      showMessage("Please enter a valid email address");
      return;
    }

    if (password.length < 6) {
      showMessage("Password must be at least 6 characters");
      return;
    }

    if (password != confirmPassword) {
      showMessage("Passwords do not match");
      return;
    }

    if (!agree) {
      showMessage("Please accept the Terms and Privacy Policy");
      return;
    }

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    setState(() => isLoading = false);

    showMessage("Account created successfully ✅");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const InitialProfileScreen(),
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: green,
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Widget socialButton(String text) {
    return Expanded(
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFB5C3B8)),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 19),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: green.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 34,
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                "SmartCook",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 12),

              const Text(
                "Your intelligent sous-chef awaits.",
                style: TextStyle(fontSize: 20, color: Color(0xFF1F2A24)),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 45),

              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: "First Name",
                      hint: "Jamie",
                      controller: firstNameController,
                    ),
                    CustomTextField(
                      label: "Last Name",
                      hint: "Oliver",
                      controller: lastNameController,
                    ),
                    CustomTextField(
                      label: "Email Address",
                      hint: "jamie@example.com",
                      icon: Icons.email_outlined,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    CustomTextField(
                      label: "Password",
                      hint: "••••••••",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      controller: passwordController,
                    ),
                    CustomTextField(
                      label: "Confirm Password",
                      hint: "••••••••",
                      icon: Icons.shield_outlined,
                      isPassword: true,
                      controller: confirmPasswordController,
                    ),

                    const SizedBox(height: 10),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: agree,
                          onChanged: (value) {
                            setState(() => agree = value ?? false);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          activeColor: green,
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text.rich(
                              TextSpan(
                                text: "I agree to the ",
                                style: TextStyle(fontSize: 15),
                                children: [
                                  TextSpan(
                                    text: "Terms of Service",
                                    style: TextStyle(
                                      color: Color(0xFF0B5D3B),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: " and\n"),
                                  TextSpan(
                                    text: "Privacy Policy.",
                                    style: TextStyle(
                                      color: Color(0xFF0B5D3B),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    CustomButton(
                      text: "Register",
                      isLoading: isLoading,
                      onPressed: validateRegister,
                    ),

                    const SizedBox(height: 35),

                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "OR REGISTER WITH",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        socialButton("Google"),
                        const SizedBox(width: 16),
                        socialButton("Apple"),
                      ],
                    ),

                    const SizedBox(height: 35),

                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "Already have an account? ",
                            style: const TextStyle(fontSize: 18),
                            children: [
                              TextSpan(
                                text: "Log in",
                                style: TextStyle(
                                  color: green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                "© 2024 SmartCook AI Technologies. All rights\nreserved.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}