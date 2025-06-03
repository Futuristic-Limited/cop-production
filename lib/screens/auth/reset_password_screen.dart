import 'package:flutter/material.dart';
import 'package:APHRC_COP/components/text_fields.dart';
import 'package:APHRC_COP/components/button.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';



final apiUrl = dotenv.env['BPI_URL'] ?? 'http://10.0.2.2:8000';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isResetting = false;
  String? email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    email = ModalRoute.of(context)?.settings.arguments as String?;
  }

  Future<void> _resetPassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Fluttertoast.showToast(msg: "Fill in all fields.");
      return;
    }

    if (newPassword.length < 6) {
      Fluttertoast.showToast(msg: "Password must be at least 6 characters.");
      return;
    }

    if (newPassword != confirmPassword) {
      Fluttertoast.showToast(msg: "Passwords do not match.");
      return;
    }

    if (email == null || email!.isEmpty) {
      Fluttertoast.showToast(msg: "Invalid email.");
      return;
    }

    setState(() => _isResetting = true);

    try {
      final url = Uri.parse('$apiUrl/account/reset_password');

      // Prepare url-encoded body
      final body = {
        'email': email!,
        'new_password': newPassword,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      // Parse JSON response
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;

      if (response.statusCode == 200 && data != null && data['status'] == true) {
        Fluttertoast.showToast(msg: "Password reset successful.");
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        Fluttertoast.showToast(
          msg: data?['message'] ?? "Failed to reset password.",
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isResetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const apHrcGreen = Color(0xFF7BC148);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: apHrcGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        title: const Text('Reset Password'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_reset, size: 100, color: apHrcGreen),
                const SizedBox(height: 20),
                const Text(
                  'Create a new password for your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                MyTextField(
                  controller: newPasswordController,
                  hintText: 'New Password',
                  obsecureText: true,
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obsecureText: true,
                ),
                const SizedBox(height: 25),

                _isResetting
                    ? const CircularProgressIndicator(color: apHrcGreen)
                    : MyButton(
                  text: 'Reset Password',
                  onPressed: _resetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
