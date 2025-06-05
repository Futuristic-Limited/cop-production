import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:APHRC_COP/services/shared_prefs_service.dart';
import 'package:APHRC_COP/widgets/profile_pic.dart';
import 'package:APHRC_COP/services/pic_service.dart'; // uploadProfileImage function
import 'dart:io';
import 'package:APHRC_COP/services/follower_service.dart';
import 'package:APHRC_COP/widgets/follower_stats.dart';
import 'package:APHRC_COP/models/follower_model.dart';
import 'package:fluttertoast/fluttertoast.dart';



final apiUrl = dotenv.env['BPI_URL'] ?? 'http://10.0.2.2:8000';
bool isSaving = false;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _organizationController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  FollowerData? _followerData;



  String userId = '';
  String profileImage = '';
  bool isLoading = true;

  static const Color aphrcGreen = Color(0xFF79C148);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProfilePhotoUrl();
    _loadFollowerStats();
  }

  Future<void> _loadProfilePhotoUrl() async {
    final savedPhotoUrl = await SharedPrefsService.getProfilePhotoUrl();
    if (savedPhotoUrl != null) {
      setState(() {
        profileImage = savedPhotoUrl;
      });
    }
  }

  Future<void> _loadFollowerStats() async {
    final token = await SharedPrefsService.getAccessToken();
    if (token != null) {
      final data = await FollowerService.fetchFollowerStats(token);
      setState(() {
        _followerData = data;
      });
    }
  }


  Future<void> _loadUserData() async {
    final id = await SharedPrefsService.getUserId();
    final token = await SharedPrefsService.getAccessToken();

    if (id == null || token == null) {
      setState(() => isLoading = false);
      return;
    }

    userId = id;

    try {
      final response = await http.get(
        Uri.parse("$apiUrl/profile/$userId"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['user'];
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _departmentController.text = data['department'] ?? '';
          _organizationController.text = data['organization'] ?? '';
          _cityController.text = data['city'] ?? '';
          _countryController.text = data['country'] ?? '';
          isLoading = false;
        });
      } else {
        throw Exception('Unauthorized: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error: $e");
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final token = await SharedPrefsService.getAccessToken();

    try {
      final response = await http.post(
        Uri.parse("$apiUrl/profile/update"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'user_id': userId,
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'department': _departmentController.text,
          'organization': _organizationController.text,
          'city': _cityController.text,
          'country': _countryController.text,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        Fluttertoast.showToast(
          msg: "Profile updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: data['message'] ?? 'Failed to update',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      debugPrint("Update Error: $e");
      Fluttertoast.showToast(
        msg: "Error updating profile",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _onImageSelected(File imageFile) async {
    setState(() => isLoading = true);
    try {
      await uploadProfileImage(imageFile);
      await _loadProfilePhotoUrl();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated successfully')),
      );
    } catch (e) {
      debugPrint("Photo Upload Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload profile photo')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _organizationController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        elevation: 0,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                shadowColor: aphrcGreen.withOpacity(0.2),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ProfilePic(
                    image: profileImage,
                    size: 120,
                    onImageSelected: _onImageSelected,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              FollowerStats(stats: _followerData),
              const SizedBox(height: 24),


              const SizedBox(height: 24),

              // Profile Form Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 6,
                shadowColor: aphrcGreen.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildLabeledField("Name", _nameController, validator: (v) => v!.isEmpty ? 'Name required' : null),
                        _buildLabeledField("Email", _emailController, validator: (v) => v!.isEmpty ? 'Email required' : null, keyboardType: TextInputType.emailAddress),
                        _buildLabeledField("Phone", _phoneController, keyboardType: TextInputType.phone),
                        _buildLabeledField("Department", _departmentController),
                        _buildLabeledField("Organization", _organizationController),
                        _buildLabeledField("City", _cityController),
                        _buildLabeledField("Country", _countryController),

                        const SizedBox(height: 24),

                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: isSaving ? null : _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: aphrcGreen,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              elevation: 3,
                              shadowColor: aphrcGreen.withOpacity(0.7),
                            ),
                            child: isSaving
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Text("Save Update"),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller,
      {String? Function(String?)? validator, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: aphrcGreen.withOpacity(0.08),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: aphrcGreen, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension method to darken a color for subtle shading
extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}