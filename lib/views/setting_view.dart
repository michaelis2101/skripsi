import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_network/image_network.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/services/auth_service.dart';
import 'package:ta_web/services/user_service.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  User? user = FirebaseAuth.instance.currentUser;
  String email = '';
  Map<String, dynamic> userInfo = {};
  Map<String, dynamic> userSettings = {};
  bool isLoading = false;
  final List<PlatformFile> _files = [];

  final newNameCont = TextEditingController();

  Future<void> _selectFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['png', 'jpeg', 'jpg']);

    if (result != null) {
      setState(() {
        _files.addAll(result.files);
      });
    }
  }

  void getUserInfo() async {
    setState(() {
      isLoading = true;

      email = user!.email!;
    });

    try {
      List<Map<String, dynamic>> userData =
          await UserService().getUserInfo(email);
      userInfo = userData.first;

      List<Map<String, dynamic>> userSetting =
          await UserService().getUserSettings(email);
      userSettings = userSetting.first;
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getUserInfo();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    newNameCont.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: ColorApp.lapisLazuli,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading your settings...',
                      style: TextStyle(
                        color: ColorApp.lapisLazuli,
                        fontSize: 16,
                        fontFamily: "Nunito",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 32),

                  // Main Content
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          // Profile Card
                          _buildProfileCard(),
                          const SizedBox(height: 24),

                          // Settings Options
                          _buildSettingsOptions(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorApp.lapisLazuli,
                ColorApp.lapisLazuli.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ColorApp.lapisLazuli.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.settings_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: ColorApp.lapisLazuli,
            fontFamily: "Nunito",
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorApp.lapisLazuli,
            ColorApp.lapisLazuli.withValues(alpha: 0.8),
            ColorApp.lapisLazuli.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ColorApp.lapisLazuli.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildProfileImage(),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Settings',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontFamily: "Nunito",
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userInfo['username'] ?? 'User',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: "Nunito",
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontFamily: "Nunito",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.3), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: SizedBox(
              height: 120,
              width: 120,
              child: userSettings['profile_pic'] != null
                  ? ImageNetwork(
                      image: userSettings['profile_pic'],
                      height: 120,
                      width: 120,
                      borderRadius: BorderRadius.circular(17),
                    )
                  : ImageNetwork(
                      borderRadius: BorderRadius.circular(17),
                      image:
                          'https://firebasestorage.googleapis.com/v0/b/project-st-iot.appspot.com/o/default_asset%2Fdefaultpfp.png?alt=media&token=882c5086-0c64-4285-b452-ca0b021707b6',
                      height: 120,
                      width: 120,
                    ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _handleImageUpload,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: ColorApp.lapisLazuli,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsOptions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorApp.lapisLazuli.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: ColorApp.lapisLazuli,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Account Settings',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: ColorApp.lapisLazuli,
                    fontFamily: "Nunito",
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[200], height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSettingItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Change Profile Picture',
                  subtitle: 'Update your profile photo',
                  onTap: _handleImageUpload,
                ),
                const SizedBox(height: 12),
                _buildSettingItem(
                  icon: Icons.edit_outlined,
                  title: 'Change Username',
                  subtitle: 'Update your display name',
                  onTap: _showUsernameDialog,
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey[200]),
                const SizedBox(height: 12),
                _buildSettingItem(
                  icon: Icons.logout_outlined,
                  title: 'Sign Out',
                  subtitle: 'Logout from your account',
                  onTap: _showLogoutDialog,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red[50]
                : ColorApp.lapisLazuli.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red[600] : ColorApp.lapisLazuli,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: "Nunito",
            fontSize: 16,
            color: isDestructive ? Colors.red[600] : Colors.grey[800],
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontFamily: "Nunito",
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _handleImageUpload() async {
    await _selectFiles();
    if (_files.isNotEmpty) {
      try {
        await UserService()
            .changePfp(email, _files[0], userSettings['profile_pic']);
        Get.snackbar(
          'Success',
          'Profile picture updated successfully',
          backgroundColor: Colors.green[50],
          colorText: Colors.green[700],
          icon: Icon(Icons.check_circle_outline, color: Colors.green[700]),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      } catch (e) {
        print(e);
        Get.snackbar(
          'Error',
          'Failed to update profile picture',
          backgroundColor: Colors.red[50],
          colorText: Colors.red[700],
          icon: Icon(Icons.error_outline, color: Colors.red[700]),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      } finally {
        getUserInfo();
        setState(() {
          _files.clear();
        });
      }
    }
  }

  void _showUsernameDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorApp.lapisLazuli.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  color: ColorApp.lapisLazuli,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Change Username',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ColorApp.lapisLazuli,
                  fontFamily: "Nunito",
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: newNameCont,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: "Nunito",
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    hintText: 'Enter new username',
                    prefixIcon:
                        Icon(Icons.person_outline, color: ColorApp.lapisLazuli),
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: "Nunito",
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: ColorApp.lapisLazuli, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            newNameCont.clear();
                            Get.back();
                          },
                          child: const Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: "Nunito",
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ColorApp.lapisLazuli,
                            ColorApp.lapisLazuli.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            if (newNameCont.text.isEmpty) {
                              Get.snackbar(
                                'Warning',
                                'Name cannot be empty',
                                backgroundColor: Colors.orange[50],
                                colorText: Colors.orange[700],
                                icon: Icon(Icons.warning_outlined,
                                    color: Colors.orange[700]),
                                snackPosition: SnackPosition.TOP,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                              return;
                            }

                            try {
                              await UserService()
                                  .changeUsername(user!.uid, newNameCont.text);
                              getUserInfo();
                              Get.back();
                              Get.snackbar(
                                'Success',
                                'Username updated successfully',
                                backgroundColor: Colors.green[50],
                                colorText: Colors.green[700],
                                icon: Icon(Icons.check_circle_outline,
                                    color: Colors.green[700]),
                                snackPosition: SnackPosition.TOP,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                            } catch (e) {
                              print(e);
                              Get.snackbar(
                                'Error',
                                'Failed to update username',
                                backgroundColor: Colors.red[50],
                                colorText: Colors.red[700],
                                icon: Icon(Icons.error_outline,
                                    color: Colors.red[700]),
                                snackPosition: SnackPosition.TOP,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                            } finally {
                              newNameCont.clear();
                            }
                          },
                          child: const Center(
                            child: Text(
                              'Update',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Nunito",
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorApp.lapisLazuli.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.logout_outlined,
                  color: ColorApp.lapisLazuli,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ColorApp.lapisLazuli,
                  fontFamily: "Nunito",
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to sign out of your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: "Nunito",
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 45,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Get.back(),
                    child: const Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: "Nunito",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 45,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorApp.lapisLazuli,
                      ColorApp.lapisLazuli.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      try {
                        Auth().signOut();
                        Get.back();
                      } catch (e) {
                        print(e);
                        Get.back();
                      }
                    },
                    child: const Center(
                      child: Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Nunito",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
