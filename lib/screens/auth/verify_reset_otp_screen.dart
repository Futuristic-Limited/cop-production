import 'package:flutter/material.dart';
import 'package:APHRC_COP/components/text_fields.dart';
import 'package:APHRC_COP/components/button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiUrl = dotenv.env['BPI_URL'] ?? 'http://10.0.2.2:8000';

class VerifyResetOtpScreen extends StatefulWidget {
  const VerifyResetOtpScreen({super.key});

  @override
  State<VerifyResetOtpScreen> createState() => _VerifyResetOtpScreenState();
}

class _VerifyResetOtpScreenState extends State<VerifyResetOtpScreen> {
  final otpController = TextEditingController();
  bool _isVerifying = false;
  String? email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    email = Uri.decodeFull(
      ModalRoute.of(context)?.settings.arguments as String? ?? '',
    );
  }

  Future<void> _verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.length != 6) {
      Fluttertoast.showToast(msg: "Enter the 6-digit OTP.");
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final url = Uri.parse('$apiUrl/account/verify_reset_otp');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email, 'otp': otp},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        Fluttertoast.showToast(msg: "OTP Verified.");
        Navigator.pushNamed(context, '/reset-password', arguments: email);
      } else {
        Fluttertoast.showToast(
          msg: data['message'] ?? "Invalid OTP.",
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isVerifying = false);
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
        title: const Text('Verify OTP'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user, size: 100, color: apHrcGreen),
                const SizedBox(height: 20),
                const Text(
                  'Enter the 6-digit OTP sent to your email',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: otpController,
                  hintText: 'Enter OTP',
                  obsecureText: false,
                ),
                const SizedBox(height: 25),
                _isVerifying
                    ? const CircularProgressIndicator(color: apHrcGreen)
                    : MyButton(text: 'Verify OTP', onPressed: _verifyOtp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
