import 'package:flutter/material.dart';
import 'package:APHRC_COP/components/button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:APHRC_COP/services/shared_prefs_service.dart';
import 'package:APHRC_COP/services/token_preference.dart';

final apiUrl = dotenv.env['BPI_URL'] ?? 'http://10.0.2.2:8000';
final buddyBossApiUrl = dotenv.env['WP_API_URL'] ?? 'http://10.0.2.2:8000';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  Future<void> generateAndSaveBuddyBossToken(String email, String password) async {
    try {
      final url = Uri.parse('${buddyBossApiUrl}wp-json/jwt-auth/v1/token');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        await SaveAccessTokenService.saveBuddyBossToken(token);
        print("BuddyBoss token saved: $token");
      } else {
        print("Failed to fetch BuddyBoss token: ${response.body}");
      }
    } catch (e) {
      print("Exception in BuddyBoss token generation: $e");
      Fluttertoast.showToast(msg: "Error generating BuddyBoss token.");
    }
  }

  Future<void> registerUser(String fullName, String email, String password) async {
    setState(() => isLoading = true);
    var url = Uri.parse('$apiUrl/regist');

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': fullName,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        Fluttertoast.showToast(msg: "Creating your account, please wait...");

        // Save session using SharedPrefsService
        await SharedPrefsService.saveUserSession(
          accessToken: data['tokens']['access_token'] ?? '',
          refreshToken: data['tokens']['refresh_token'] ?? '',
          tokenExpiresAt: data['tokens']['token_expires_at'] ?? '',
          userName: data['user_name'] ?? '',
          userId: data['user_id'].toString(),
          buddyBossToken: data['token'] ?? '',
        );


        await SaveAccessTokenService.saveAccessToken(data['tokens']['access_token']);

        // Generate and save BuddyBoss token
        await generateAndSaveBuddyBossToken(email, password);

        // Debugging prints
        print("Access token (SharedPrefsService): ${await SharedPrefsService.getAccessToken()}");
        print("Access token (SaveAccessTokenService): ${await SaveAccessTokenService.getAccessToken()}");

        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Fluttertoast.showToast(
          msg: data['message'] ?? "Registration failed.",
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error in registration: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    const apHrcGreen = Color(0xFF7BC148);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(backgroundColor: apHrcGreen, elevation: 2),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(20),
                      child: const Icon(
                        Icons.person_add_alt_1,
                        size: 90,
                        color: apHrcGreen,
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Community of Practice',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Create your account below',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 30),

                    // Full name
                    TextFormField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: const Color(0xFFF6FFF1),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: apHrcGreen),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: apHrcGreen, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Email
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: const Color(0xFFF6FFF1),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: apHrcGreen),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: apHrcGreen, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        } else if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password
                    TextFormField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: apHrcGreen,
                          ),
                          onPressed: () {
                            setState(() => isPasswordVisible = !isPasswordVisible);
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF6FFF1),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: apHrcGreen),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: apHrcGreen, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Password is required';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                          if (_formKey.currentState!.validate()) {
                            registerUser(
                              fullNameController.text.trim(),
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: apHrcGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Login here!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: apHrcGreen,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}