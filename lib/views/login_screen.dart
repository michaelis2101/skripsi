import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailCont = TextEditingController();
  TextEditingController signUpemailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController signUpPasswordCont = TextEditingController();
  TextEditingController rePasswordCont = TextEditingController();
  TextEditingController namecont = TextEditingController();
  bool hidePw = true;
  bool reHidePw = true;

  String? errorMessage = '';
  // bool isLogin = true;
  bool isLoading = false;

  bool isSignUp = false;

  void testLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  final supabase = Supabase.instance.client;

  bool areFieldsFilled() {
    return emailCont.text.length >= 5 && passwordCont.text.length >= 6;
  }

  Future<void> signUpEmailAndPassword() async {
    bool registrationSuccessful = false;
    setState(() {
      isLoading = true;
    });
    try {
      await Auth().register(
          signUpemailCont.text, signUpPasswordCont.text, namecont.text);

      signUpemailCont.clear();
      signUpPasswordCont.clear();
      rePasswordCont.clear();
      namecont.clear();

      setState(() {
        registrationSuccessful = true;
      });
    } on FirebaseAuthException catch (e) {
      // Get.snackbar("Error", e.code, backgroundColor: Colors.white);
      Get.defaultDialog(
          title: 'Error',
          middleTextStyle: const TextStyle(fontSize: 15),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.remove_circle_outline,
                size: 55,
              ),
              Text(
                e.code.toString(),
                style: const TextStyle(fontSize: 15),
              )
            ],
          ),
          // onConfirm: () {
          //   Get.back();
          // },
          confirm: SizedBox(
            height: 40,
            width: double.infinity,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: ColorApp.lapisLazuli,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () => Get.back(),
                child: const Text(
                  'Ok',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                )),
          ));
      setState(() {
        isLoading = false;
      });
    } finally {
      // await Auth().signOut();
      setState(() {
        isLoading = false;
        // isSignUp = false;
      });
      if (registrationSuccessful) {
        setState(() {
          isLoading = false;
          isSignUp = false;
        });
        Get.defaultDialog(
            title: 'Success',
            middleTextStyle: const TextStyle(fontSize: 15),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            content: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline_outlined,
                  size: 55,
                ),
                Text(
                  'Account created successfully, Please login to continue',
                  style: TextStyle(fontSize: 15),
                )
              ],
            ),
            // onConfirm: () {
            //   Get.back();
            // },
            confirm: SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ColorApp.lapisLazuli,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Ok',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  )),
            ));
      }
      // Get.back();
    }
  }

  Future<void> logInEmailAndPassword() async {
    Trace loginTrace = FirebasePerformance.instance.newTrace('login-trace');
    setState(() {
      isLoading = true;
    });
    await loginTrace.start();
    try {
      await Auth().signInWithEmailAndPassword(
          userEmail: emailCont.text, userPassword: passwordCont.text);
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'invalid-credential') {
        Get.snackbar('Error', 'Invalid email or password',
            backgroundColor: Colors.white, icon: const Icon(Icons.error));
      } else if (e.code == 'too-many-requests') {
        Get.snackbar('Error', 'Too Many Request',
            backgroundColor: Colors.white, icon: const Icon(Icons.error));
      } else if (e.code == 'invalid-email') {
        Get.snackbar('Error', 'Invalid Email',
            backgroundColor: Colors.white, icon: const Icon(Icons.error));
      } else if (e.code == 'user-disabled') {
        Get.snackbar('Error', 'User Banned',
            backgroundColor: Colors.white, icon: const Icon(Icons.error));
      }
    } finally {
      await loginTrace.stop();

      // final user = FirebaseAuth.instance.currentUser!;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ColorApp.lapisLazuli,
      body: Container(
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
        ),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 1200,
              maxHeight: height * 0.85,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: width * 0.05,
              vertical: height * 0.075,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  spreadRadius: 0,
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  spreadRadius: 0,
                  blurRadius: 60,
                  offset: const Offset(0, 30),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Row(
                children: [
                  // Left Panel - Form
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(48),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isSignUp) _buildSignInForm(),
                            if (isSignUp) _buildSignUpForm(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Right Panel - Branding
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ColorApp.lapisLazuli.withValues(alpha: 0.1),
                            ColorApp.lapisLazuli.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: AspectRatio(
                              aspectRatio: 16 / 3,
                              child: SvgPicture.asset(
                                'assets/svg/logo_fdsm.svg',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Firebase IoT Device System Manager',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: ColorApp.lapisLazuli,
                                fontFamily: "Nunito",
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/picture/logotk.png',
                                  height: 60,
                                  width: 60,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Container(
                                height: 60,
                                width: 2,
                                decoration: BoxDecoration(
                                  color: ColorApp.lapisLazuli
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/picture/logoupi.png',
                                  height: 60,
                                  width: 60,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 800.ms),
                  ),
                ],
              ),
            ),
          ).animate().scale(duration: 600.ms).fadeIn(duration: 400.ms),
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back!",
          style: TextStyle(
            color: ColorApp.lapisLazuli,
            fontSize: 32,
            fontFamily: "Nunito",
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Please sign in to continue",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontFamily: "Nunito",
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 40),
        _buildTextField(
          controller: emailCont,
          labelText: 'Email Address',
          hintText: 'Enter your email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: passwordCont,
          labelText: 'Password',
          hintText: 'Enter your password',
          prefixIcon: Icons.lock_outline,
          obscureText: hidePw,
          suffixIcon: IconButton(
            onPressed: () => setState(() => hidePw = !hidePw),
            icon: Icon(
              hidePw
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: ColorApp.lapisLazuli,
            ),
          ),
        ),
        const SizedBox(height: 32),
        if (isLoading)
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: ColorApp.lapisLazuli.withValues(alpha: 0.1),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: ColorApp.lapisLazuli,
                strokeWidth: 3,
              ),
            ),
          )
        else
          _buildPrimaryButton(
            text: 'Sign In',
            onPressed: () async {
              if (emailCont.text.isEmpty || passwordCont.text.isEmpty) {
                _showErrorSnackbar("Email and Password can't be empty");
              } else if (emailCont.text.length < 5 ||
                  passwordCont.text.length < 6) {
                _showErrorSnackbar("Password must be at least 6 characters");
              } else {
                await logInEmailAndPassword();
              }
            },
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 24),
        _buildSecondaryButton(
          text: "Don't have an account? Sign Up",
          onPressed: () => setState(() => isSignUp = true),
        ),
      ],
    ).animate().slideX(duration: 400.ms).fadeIn();
  }

  Widget _buildSignUpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Create Account",
          style: TextStyle(
            color: ColorApp.lapisLazuli,
            fontSize: 32,
            fontFamily: "Nunito",
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Please fill in the details to get started",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontFamily: "Nunito",
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 32),
        _buildTextField(
          controller: namecont,
          labelText: 'Full Name',
          hintText: 'Enter your full name',
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: signUpemailCont,
          labelText: 'Email Address',
          hintText: 'Enter your email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: signUpPasswordCont,
          labelText: 'Password',
          hintText: 'Enter your password',
          prefixIcon: Icons.lock_outline,
          obscureText: hidePw,
          suffixIcon: IconButton(
            onPressed: () => setState(() => hidePw = !hidePw),
            icon: Icon(
              hidePw
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: ColorApp.lapisLazuli,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: rePasswordCont,
          labelText: 'Confirm Password',
          hintText: 'Repeat your password',
          prefixIcon: Icons.lock_outline,
          obscureText: reHidePw,
          suffixIcon: IconButton(
            onPressed: () => setState(() => reHidePw = !reHidePw),
            icon: Icon(
              reHidePw
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: ColorApp.lapisLazuli,
            ),
          ),
        ),
        const SizedBox(height: 32),
        if (isLoading)
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: ColorApp.lapisLazuli.withValues(alpha: 0.1),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: ColorApp.lapisLazuli,
                strokeWidth: 3,
              ),
            ),
          )
        else
          _buildPrimaryButton(
            text: 'Create Account',
            onPressed: () async {
              if (signUpemailCont.text.isEmpty ||
                  signUpPasswordCont.text.isEmpty ||
                  namecont.text.isEmpty) {
                _showErrorSnackbar("All fields are required");
              } else if (signUpemailCont.text.length < 6 ||
                  signUpPasswordCont.text.length < 6) {
                _showErrorSnackbar("Password must be at least 6 characters");
              } else if (signUpPasswordCont.text != rePasswordCont.text) {
                _showErrorSnackbar("Passwords do not match");
              } else {
                await signUpEmailAndPassword();
              }
            },
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 24),
        _buildSecondaryButton(
          text: "Already have an account? Sign In",
          onPressed: () => setState(() => isSignUp = false),
        ),
      ],
    ).animate().slideX(duration: 400.ms, begin: -0.2).fadeIn();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: "Nunito",
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[50],
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(prefixIcon, color: ColorApp.lapisLazuli),
          suffixIcon: suffixIcon,
          labelStyle: TextStyle(
            color: ColorApp.lapisLazuli,
            fontFamily: "Nunito",
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontFamily: "Nunito",
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: ColorApp.lapisLazuli, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            ColorApp.lapisLazuli,
            ColorApp.lapisLazuli.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ColorApp.lapisLazuli.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: "Nunito",
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorApp.lapisLazuli.withValues(alpha: 0.3)),
        color: Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: ColorApp.lapisLazuli,
                fontSize: 16,
                fontFamily: "Nunito",
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      "Error",
      message,
      backgroundColor: Colors.red[50],
      colorText: Colors.red[700],
      icon: Icon(Icons.error_outline, color: Colors.red[700]),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }
}
