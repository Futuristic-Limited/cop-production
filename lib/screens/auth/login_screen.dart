import 'package:flutter/material.dart';
import 'package:APHRC_COP/screens/auth/register_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:APHRC_COP/components/forgot_password_link.dart';
import 'package:APHRC_COP/screens/auth/forgot_password_screen.dart';
import 'package:APHRC_COP/services/shared_prefs_service.dart';
import 'package:APHRC_COP/services/token_preference.dart';
import 'package:APHRC_COP/notifiers/profile_photo_notifier.dart';
import 'package:APHRC_COP/utils/network_checker.dart';


final apiUrl = dotenv.env['BPI_URL'] ?? 'http://10.0.2.2:8000';
final buddyBossApiUrl = dotenv.env['WP_API_URL'] ?? 'http://10.0.2.2:8000';

class LoginScreen extends StatefulWidget {
  const LoginScreen({  super.key,

  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _lastUserName;
  String? _lastUserEmail;
  String? _lastUserPhotoUrl;
  bool _showContinueAs = false;


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

  Future<void> loginUser(String email, String password) async {
    final hasInternet = await NetworkChecker.hasConnection();

    if (!hasInternet) {
      Fluttertoast.showToast(
        msg: "No Internet Connection.",
        backgroundColor: Colors.grey,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);
    final url = Uri.parse('$apiUrl/log');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email, 'password': password},
      );

      final data = jsonDecode(response.body);
      print("Login Response: $data");

      if (response.statusCode == 200 && data['success'] == true) {
        Fluttertoast.showToast(msg: "Logging you in...");

        await SharedPrefsService.saveUserSession(
          accessToken: data['tokens']['access_token'] ?? '',
          refreshToken: data['tokens']['refresh_token'] ?? '',
          tokenExpiresAt: data['tokens']['token_expires_at'] ?? '',
          userName: data['user_name'] ?? '',
          userRole: data['user_role'] ?? 'bbp_participant',
          userId: data['user_id'].toString(),
          buddyBossToken: data['token'] ?? '',
        );
        await SharedPrefsService.saveUserPassword(password);

        await SaveAccessTokenService.saveAccessToken(data['tokens']['access_token']);
        await fetchAndCacheProfilePhoto();

        await SharedPrefsService.saveLastUserInfo(
          userName: data['user_name'] ?? '',
          email: email,
          photoUrl: ProfilePhotoNotifier.profilePhotoUrl.value ?? '',
        );

        await generateAndSaveBuddyBossToken(email, password);

        Navigator.pushReplacementNamed(context, '/home');
        // Navigator.pushReplacementNamed(context, '/activity/feeds');
      } else {
        Fluttertoast.showToast(
          msg: data['message'] ?? "Login Failed.",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error in login: ${e.toString()}",
        backgroundColor: Colors.grey,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchAndCacheProfilePhoto() async {
    final token = await SharedPrefsService.getAccessToken();
    if (token == null) return;

    final uri = Uri.parse('$apiUrl/photo'); // Or user/profile if different
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final photoUrl = jsonData['photo_url'];
      print('Fetched profile photo URL: $photoUrl');
      if (photoUrl != null && photoUrl.toString().isNotEmpty) {
        await SharedPrefsService.saveProfilePhotoUrl(photoUrl);
        ProfilePhotoNotifier.profilePhotoUrl.value = photoUrl;
      }
    } else {
      print('Failed to fetch profile photo. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
  @override
  void initState() {
    super.initState();
    _loadLastUserInfo();
  }

  Future<void> _loadLastUserInfo() async {
    final name = await SharedPrefsService.getLastUserName();
    final email = await SharedPrefsService.getLastUserEmail();
    final photo = await SharedPrefsService.getLastUserPhotoUrl();


    if (name != null && email != null) {
      setState(() {
        _lastUserName = name;
        _lastUserEmail = email;
        _lastUserPhotoUrl = photo;
        _showContinueAs = true;
      });
    }
  }


  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const apHrcGreen = Color(0xFF79C148);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(backgroundColor: apHrcGreen),
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
                    // Lock Icon with white dot and green color
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(20),
                      child: const Icon(
                        Icons.lock_outline,
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
                    if (_showContinueAs) ...[
                      const SizedBox(height: 20),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final savedPassword = await SharedPrefsService.getUserPassword();
                          setState(() {
                            emailTextController.text = _lastUserEmail!;
                            passwordTextController.text = savedPassword ?? '';
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Email & password pre-filled. Just press Sign In."),
                            ),
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: apHrcGreen, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundImage: _lastUserPhotoUrl != null
                                    ? NetworkImage(_lastUserPhotoUrl!)
                                    : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Continue as $_lastUserName",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _lastUserEmail ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () async {
                            await SharedPrefsService.clearLastUser();
                            setState(() => _showContinueAs = false);
                          },
                          icon: const Icon(Icons.switch_account_outlined, size: 18),
                          label: const Text("Not you? Switch account"),
                          style: TextButton.styleFrom(
                            foregroundColor: apHrcGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    const Text(
                      'Sign in to continue',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 30),

                    // Email field
                    // Email field
                    TextFormField(
                      controller: emailTextController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: Color(0xFFF6FFF1), // APHRC light green
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: apHrcGreen,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: apHrcGreen),
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

                    // Password field
                    TextFormField(
                      controller: passwordTextController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: apHrcGreen,
                          ),
                          onPressed: () {
                            setState(
                                  () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                        filled: true,
                        fillColor: Color(0xFFF6FFF1), // APHRC light green
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: apHrcGreen,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: apHrcGreen),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ForgotPasswordLink(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Sign In button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                        _isLoading
                            ? null
                            : () {
                          if (_formKey.currentState!.validate()) {
                            final email =
                            emailTextController.text.trim();
                            final password =
                            passwordTextController.text.trim();
                            loginUser(email, password);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: apHrcGreen,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                        _isLoading
                            ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                            : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Register now!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: apHrcGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
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