import 'package:flutter/material.dart';
import 'package:APHRC_COP/components/text_fields.dart';
import 'package:APHRC_COP/components/button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiUrl = dotenv.env['BPI_URL'] ?? 'http://10.0.2.2:8000';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendOtp() async {
    String email = emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$apiUrl/account/forgot_password');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'email': email,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        Fluttertoast.showToast(msg: "OTP sent to your email.");
        Navigator.pushNamed(context, '/verify-reset-otp', arguments: email);
      } else {
        Fluttertoast.showToast(
          msg: data['message'] ?? "Failed to send OTP.",
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const apHrcGreen = Color(0xFF7BC148);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: apHrcGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.password, // OTP icon style
                  size: 120,
                  color: apHrcGreen,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Reset via OTP',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter your email address to receive\nan OTP for password reset.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 25),

                MyTextField(
                  controller: emailController,
                  hintText: 'Email Address',
                  obsecureText: false,
                ),
                const SizedBox(height: 25),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: apHrcGreen)
                      : MyButton(
                    text: 'Send OTP',
                    onPressed: _sendOtp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}