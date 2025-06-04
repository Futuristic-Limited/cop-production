import 'package:flutter/material.dart';
import 'package:APHRC_COP/components/text_fields.dart';
import 'package:APHRC_COP/components/button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:APHRC_COP/screens/auth/verify_otp_screen.dart';

final apiUrl = dotenv.env['BPI_URL'] ?? 'http://10.0.2.2:8000';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  Future<void> registerUser(
    String fullName,
    String email,
    String password,
  ) async {
    setState(() => isLoading = true);
    var url = Uri.parse('$apiUrl/register');

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
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Registration successful!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => VerifyOtpScreen(email: email, password: password),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: data['message'] ?? "Registration failed.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => isLoading = false);
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
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                const SizedBox(height: 6),
                const Text(
                  'And connect with Africa’s leading knowledge community.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 28),

                MyTextField(
                  controller: fullNameController,
                  hintText: 'Full Name',
                  obsecureText: false,
                ),
                const SizedBox(height: 18),

                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obsecureText: false,
                ),
                const SizedBox(height: 18),

                // Password with toggle
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Color(
                      0xFFF6FFF1,
                    ), // Light APHRC green background to match other fields
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF6EBF4B), // APHRC green color
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF6EBF4B), // Same color when focused
                        width: 2,
                      ),
                    ),
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
                  ),
                ),

                const SizedBox(height: 28),

                isLoading
                    ? const CircularProgressIndicator()
                    : MyButton(
                      text: 'Sign Up',
                      onPressed: () {
                        String fullName = fullNameController.text.trim();
                        String email = emailController.text.trim();
                        String password = passwordController.text.trim();

                        if (fullName.isEmpty ||
                            email.isEmpty ||
                            password.isEmpty) {
                          Fluttertoast.showToast(
                            msg: 'Please fill in all fields',
                          );
                        } else if (!email.contains('@')) {
                          Fluttertoast.showToast(msg: 'Enter a valid email');
                        } else if (password.length < 6) {
                          Fluttertoast.showToast(
                            msg: 'Password must be at least 6 characters',
                          );
                        } else {
                          registerUser(fullName, email, password);
                        }
                      },
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
    );
  }
}
