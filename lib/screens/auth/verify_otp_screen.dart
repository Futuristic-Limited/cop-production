import 'package:flutter/material.dart';
import 'package:APHRC_COP/components/text_fields.dart';
import 'package:APHRC_COP/components/button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:APHRC_COP/services/shared_prefs_service.dart';
import 'package:APHRC_COP/services/token_preference.dart';

final apiUrl = dotenv.env['BPI_URL'] ?? 'http://10.0.2.2:8000';
final buddyBossApiUrl = dotenv.env['WP_API_URL'] ?? 'http://10.0.2.2:8000';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({
    super.key,
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen>
    with SingleTickerProviderStateMixin {
  final otpController = TextEditingController();
  bool _isLoading = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Animation setup for zoom-out effect
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 1.2, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    otpController.dispose();
    _cooldownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _generateBuddyOtp() async {
    try {
      var url = Uri.parse('${buddyBossApiUrl}wp-json/jwt-auth/v1/token');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.email,
          'password': widget.password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await SaveAccessTokenService.saveBuddyBossToken(data['token']);
      } else {
        return;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error generating OTP: $e");
    }
  }

  Future<void> _verifyOtp() async {
    String otp = otpController.text.trim();

    print('password: ${widget.password}');
    print('email: ${widget.email}');

    if (otp.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter the OTP')));
      return;
    }

    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var url = Uri.parse('$apiUrl/verify_otp');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email, 'otp': otp}),
      );

      var data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        Fluttertoast.showToast(msg: "OTP verified successfully!");

        _generateBuddyOtp();

        // Save session data
        await SharedPrefsService.saveUserSession(
          accessToken: data['tokens']['access_token'] ?? '',
          refreshToken: data['tokens']['refresh_token'] ?? '',
          tokenExpiresAt: data['tokens']['token_expires_at'] ?? '',
          userName: data['user_name'] ?? '',
          userId: data['user_id'].toString(),
          buddyBossToken: data['token'] ?? '',
        );
        // Save the access token to SharedPreferences
        await SaveAccessTokenService.saveAccessToken(
          data['tokens']['access_token'],
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Fluttertoast.showToast(
          msg: data['message'] ?? "OTP verification failed.",
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error verifying OTP: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCooldown > 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var url = Uri.parse('$apiUrl/resend_otp');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );

      var data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        Fluttertoast.showToast(msg: "OTP resent successfully!");
        _startResendCooldown();
      } else {
        Fluttertoast.showToast(
          msg: data['message'] ?? "Failed to resend OTP.",
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error resending OTP: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = 60;
    });

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown == 0) {
        timer.cancel();
      } else {
        setState(() {
          _resendCooldown--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const apHrcGreen = Color(0xFF79c148); // Your preferred green

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: apHrcGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated zoom-out icon
                ScaleTransition(
                  scale: _animation,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: apHrcGreen.withOpacity(0.15),
                      boxShadow: [
                        BoxShadow(
                          color: apHrcGreen.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Icon(
                      Icons.verified_user,
                      size: 100,
                      color: apHrcGreen,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: 0.4,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  'We sent a 6-digit code to:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: apHrcGreen,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 35),

                // OTP input field
                MyTextField(
                  controller: otpController,
                  hintText: 'Enter 6-digit OTP',
                  obsecureText: false,
                ),

                const SizedBox(height: 35),

                // Verify button or loader
                SizedBox(
                  width: double.infinity,
                  child:
                      _isLoading
                          ? const Center(
                            child: CircularProgressIndicator(color: apHrcGreen),
                          )
                          : MyButton(text: 'Verify', onPressed: _verifyOtp),
                ),

                const SizedBox(height: 30),

                // Resend OTP row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive the code? ",
                      style: TextStyle(fontSize: 14),
                    ),
                    GestureDetector(
                      onTap:
                          (_isLoading || _resendCooldown > 0)
                              ? null
                              : _resendOtp,
                      child: Text(
                        _resendCooldown > 0
                            ? 'Resend in $_resendCooldown s'
                            : 'Resend OTP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color:
                              (_isLoading || _resendCooldown > 0)
                                  ? Colors.grey
                                  : apHrcGreen,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Back to login button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                    style: TextButton.styleFrom(
                      foregroundColor: apHrcGreen,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    child: const Text('Back to Login'),
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
