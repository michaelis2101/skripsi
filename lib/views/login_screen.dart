import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_network/image_network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/models/user_model.dart';
import 'package:ta_web/services/auth_service.dart';
import 'package:ta_web/services/user_service.dart';
import 'package:ta_web/views/screen_handler.dart';

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

  static Future<UserCredential> register(String email, String password) async {
    FirebaseApp app = await Firebase.initializeApp(
        name: 'Secondary', options: Firebase.app().options);

    UserCredential userCredential = await FirebaseAuth.instanceFor(app: app)
        .createUserWithEmailAndPassword(email: email, password: password);
    await app.delete();
    return Future.sync(() => userCredential);
    // Do something with exception. This try/catch is here to make sure
    // that even if the user creation fails, app.delete() runs, if is not,
    // next time Firebase.initializeApp() will fail as the previous one was
    // not deleted.
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
    // var height = Get.height;
    // var width = Get.width;

    return Scaffold(
        backgroundColor: ColorApp.lapisLazuli,
        body: Stack(
          children: [
            Container(
              height: height,
              width: width,
              decoration: BoxDecoration(color: ColorApp.lapisLazuli),
              child: Center(
                child: Container(
                  height: height * 0.7,
                  width: width * 0.7,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      // border: BorderSide(),
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!isSignUp)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 40, left: 8, right: 8, bottom: 8),
                          // padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // const SizedBox(height: 32),
                                // Text(data)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Sign In",
                                    style: TextStyle(
                                        color: ColorApp.lapisLazuli,
                                        fontSize: 25,
                                        fontFamily: "Nunito",
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      "Please Sign In to Continue",
                                      style: TextStyle(
                                          color: ColorApp.lapisLazuli,
                                          fontFamily: "Nunito"),
                                    )),
                                const SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  height: 50,
                                  width: width * 0.7 * 0.48,
                                  child: TextField(
                                      controller: emailCont,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIconColor: ColorApp.lapisLazuli,
                                        labelStyle: TextStyle(
                                            color: ColorApp.lapisLazuli),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1.0,
                                                color: ColorApp.lapisLazuli),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        focusColor: ColorApp.lapisLazuli,
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide(width: 1.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        labelText: 'Email',
                                        hintText: 'Enter Your Email',
                                        prefixIcon:
                                            const Icon(Icons.email_rounded),
                                      )),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  height: 50,
                                  // width: 200,
                                  width: width * 0.7 * 0.48,
                                  child: TextField(
                                      controller: passwordCont,
                                      obscureText: hidePw,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIconColor: ColorApp.lapisLazuli,
                                        labelStyle: TextStyle(
                                            color: ColorApp.lapisLazuli),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1.0,
                                                color: ColorApp.lapisLazuli),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        focusColor: ColorApp.lapisLazuli,
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide(width: 1.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        labelText: 'Password',
                                        hintText: 'Enter Your Password',
                                        prefixIcon:
                                            const Icon(Icons.password_rounded),
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                hidePw = !hidePw;
                                              });
                                            },
                                            icon: Icon(hidePw
                                                ? Icons.visibility_rounded
                                                : Icons
                                                    .visibility_off_rounded)),
                                      )),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (isLoading)
                                  SizedBox(
                                    width: width * 0.7 * 0.48,
                                    height: 50,
                                    child: Center(
                                        child: LinearProgressIndicator(
                                      color: ColorApp.lapisLazuli,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(100)),
                                    )),
                                  ),
                                if (isLoading)
                                  SizedBox(
                                    width: width * 0.7 * 0.48,
                                    height: 60,
                                  ),

                                if (!isLoading)
                                  SizedBox(
                                    width: width * 0.7 * 0.48,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (emailCont.text.isEmpty ||
                                            passwordCont.text.isEmpty) {
                                          Get.snackbar("Warning",
                                              "Email and Password can't be empty",
                                              backgroundColor: Colors.white,
                                              icon: const Icon(Icons.error));
                                        } else if (emailCont.text.length < 5 ||
                                            passwordCont.text.length < 6) {
                                          Get.snackbar("Warning",
                                              "Password Length Must be Greater than 6",
                                              backgroundColor: Colors.white,
                                              icon: const Icon(Icons.error));
                                        } else {
                                          // Get.to(() => const ScreenHandler());
                                          await logInEmailAndPassword();
                                          // testLoading();
                                          // final SharedPreferences prefs =
                                          //     await SharedPreferences.getInstance();
                                          // User? user = FirebaseAuth.instance.currentUser;
                                          // // store.write("email", user!.email);
                                          // // store.write("uid", user.uid);
                                          // prefs.setString('email', user!.email!);
                                          // prefs.setString('uid', user.uid);
                                        }
                                      },
                                      // onPressed: areFieldsFilled()
                                      //     ? () => logInEmailAndPassword()
                                      //     : null,
                                      // : () => Get.snackbar("Warning",
                                      //     "Email and Password can't be empty",
                                      //     backgroundColor: Colors.white,
                                      //     icon: const Icon(Icons.error)),
                                      // onPressed: () => logInEmailAndPassword(),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: ColorApp.lapisLazuli,
                                          // minimumSize: const Size.fromHeight(50),
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)))),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Sign In",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "Nunito",
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.white,
                                            size: 20,
                                            weight: 700,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (!isLoading)
                                  SizedBox(
                                    width: width * 0.7 * 0.48,
                                    child: const Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Or',
                                          style:
                                              TextStyle(fontFamily: 'Nunito'),
                                        )),
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (!isLoading)
                                  SizedBox(
                                    // width: double.infinity,
                                    width: width * 0.7 * 0.48,
                                    height: 50,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          isSignUp = !isSignUp;
                                        });
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: 1,
                                                  color: ColorApp.lapisLazuli)),
                                          child: Center(
                                            child: Text(
                                              'Sign Up',
                                              style: TextStyle(
                                                  color: ColorApp.lapisLazuli,
                                                  fontFamily: "Nunito",
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          )),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(),
                      if (!isSignUp)
                        Expanded(
                          child: Container(
                            // color: ColorApp.duronQuartzWhite,
                            height: height * 0.7,
                            width: width * 0.7 * 0.48,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            // color: ColorApp.duronQuartzWhite,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 1),
                                  child: AspectRatio(
                                    aspectRatio: 32 / 6,
                                    child: Container(
                                      // color: Colors.pink,
                                      child: SvgPicture.asset(
                                        'assets/svg/logo_fdsm.svg',
                                        // color: Colors.pink,
                                        fit: BoxFit.scaleDown,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  'Firebase IoT Device System Manager',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/picture/logotk.png',
                                        scale: 6,
                                      ),
                                      Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                            border: Border.symmetric(
                                                vertical: BorderSide(
                                                    width: 1,
                                                    color:
                                                        ColorApp.lapisLazuli))),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Image.asset(
                                        'assets/picture/logoupi.png',
                                        scale: 12,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      // .animate().fadeIn(),
                      if (isSignUp)
                        Expanded(
                          child: Container(
                            // color: ColorApp.duronQuartzWhite,
                            height: height * 0.7,
                            width: width * 0.7 * 0.48,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            // color: ColorApp.duronQuartzWhite,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 1),
                                  child: AspectRatio(
                                    aspectRatio: 32 / 6,
                                    child: Container(
                                      // color: Colors.pink,
                                      child: SvgPicture.asset(
                                        'assets/svg/logo_fdsm.svg',
                                        // color: Colors.pink,
                                        fit: BoxFit.scaleDown,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  'Firebase IoT Device System Manager',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/picture/logotk.png',
                                        scale: 6,
                                      ),
                                      // ImageNetwork(
                                      //     image:
                                      //         'https://firebasestorage.googleapis.com/v0/b/project-st-iot.appspot.com/o/default_asset%2Flogotk.png?alt=media&token=e1caacd3-3b51-4942-b658-95276bc4ce93',
                                      //     height: height,
                                      //     width: width),
                                      Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                            border: Border.symmetric(
                                                vertical: BorderSide(
                                                    width: 1,
                                                    color:
                                                        ColorApp.lapisLazuli))),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      // ImageNetwork(
                                      //     fitWeb: BoxFitWeb.scaleDown,
                                      //     image:
                                      //         'https://firebasestorage.googleapis.com/v0/b/project-st-iot.appspot.com/o/default_asset%2Flogoupi.png?alt=media&token=e4353c72-1fde-40f1-b286-c3b2c1a5a04e',
                                      //     height: height,
                                      //     width: width)
                                      Image.asset(
                                        'assets/picture/logoupi.png',
                                        scale: 12,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ).animate().fadeIn(),

                      //form sign up
                      if (isSignUp)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 40, left: 8, right: 8, bottom: 8),
                          // padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // const SizedBox(height: 32),
                                // Text(data)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Sign Up",
                                    style: TextStyle(
                                        color: ColorApp.lapisLazuli,
                                        fontSize: 25,
                                        fontFamily: "Nunito",
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      "Please Sign Up to Continue",
                                      style: TextStyle(
                                          color: ColorApp.lapisLazuli,
                                          fontFamily: "Nunito"),
                                    )),
                                const SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  height: 50,
                                  width: width * 0.7 * 0.48,
                                  child: TextField(
                                      controller: namecont,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIconColor: ColorApp.lapisLazuli,
                                        labelStyle: TextStyle(
                                            color: ColorApp.lapisLazuli),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1.0,
                                                color: ColorApp.lapisLazuli),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        focusColor: ColorApp.lapisLazuli,
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide(width: 1.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        labelText: 'Name',
                                        hintText: 'Enter Your Name',
                                        prefixIcon: const Icon(Icons.person),
                                      )),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 50,
                                  width: width * 0.7 * 0.48,
                                  child: TextField(
                                      controller: signUpemailCont,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIconColor: ColorApp.lapisLazuli,
                                        labelStyle: TextStyle(
                                            color: ColorApp.lapisLazuli),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1.0,
                                                color: ColorApp.lapisLazuli),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        focusColor: ColorApp.lapisLazuli,
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide(width: 1.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        labelText: 'Email',
                                        hintText: 'Enter Your Email',
                                        prefixIcon:
                                            const Icon(Icons.email_rounded),
                                      )),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 50,
                                  // width: 200,
                                  width: width * 0.7 * 0.48,
                                  child: TextField(
                                      controller: signUpPasswordCont,
                                      obscureText: hidePw,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIconColor: ColorApp.lapisLazuli,
                                        labelStyle: TextStyle(
                                            color: ColorApp.lapisLazuli),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1.0,
                                                color: ColorApp.lapisLazuli),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        focusColor: ColorApp.lapisLazuli,
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide(width: 1.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        labelText: 'Password',
                                        hintText: 'Enter Your Password',
                                        prefixIcon:
                                            const Icon(Icons.password_rounded),
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                hidePw = !hidePw;
                                              });
                                            },
                                            icon: Icon(hidePw
                                                ? Icons.visibility_rounded
                                                : Icons
                                                    .visibility_off_rounded)),
                                      )),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 50,
                                  // width: 200,
                                  width: width * 0.7 * 0.48,
                                  child: TextField(
                                      controller: rePasswordCont,
                                      obscureText: reHidePw,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIconColor: ColorApp.lapisLazuli,
                                        labelStyle: TextStyle(
                                            color: ColorApp.lapisLazuli),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1.0,
                                                color: ColorApp.lapisLazuli),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        focusColor: ColorApp.lapisLazuli,
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide(width: 1.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        labelText: 'Repeat Password',
                                        hintText: 'Repeat Your Password',
                                        prefixIcon:
                                            const Icon(Icons.password_rounded),
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                reHidePw = !reHidePw;
                                              });
                                            },
                                            icon: Icon(reHidePw
                                                ? Icons.visibility_rounded
                                                : Icons
                                                    .visibility_off_rounded)),
                                      )),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (isLoading)
                                  SizedBox(
                                    width: width * 0.7 * 0.48,
                                    height: 50,
                                    child: Center(
                                        child: LinearProgressIndicator(
                                      color: ColorApp.lapisLazuli,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(100)),
                                    )),
                                  ),
                                if (isLoading)
                                  SizedBox(
                                    width: width * 0.7 * 0.48,
                                    height: 60,
                                  ),

                                if (!isLoading)
                                  SizedBox(
                                    width: width * 0.7 * 0.48,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (signUpemailCont.text.isEmpty ||
                                            signUpPasswordCont.text.isEmpty) {
                                          Get.snackbar("Warning",
                                              "Email and Password can't be empty",
                                              backgroundColor: Colors.white,
                                              icon: const Icon(Icons.error));
                                        } else if (signUpemailCont.text.length <
                                                6 ||
                                            signUpPasswordCont.text.length <
                                                6) {
                                          Get.snackbar("Warning",
                                              "Password Length Must be Greater than 6",
                                              backgroundColor: Colors.white,
                                              icon: const Icon(Icons.error));
                                        } else if (signUpPasswordCont.text !=
                                            rePasswordCont.text) {
                                          Get.snackbar("Warning",
                                              "Password does not match",
                                              backgroundColor: Colors.white,
                                              icon: const Icon(Icons.error));
                                        } else {
                                          await signUpEmailAndPassword();
                                        }
                                      },
                                      // onPressed: areFieldsFilled()
                                      //     ? () => logInEmailAndPassword()
                                      //     : null,
                                      // : () => Get.snackbar("Warning",
                                      //     "Email and Password can't be empty",
                                      //     backgroundColor: Colors.white,
                                      //     icon: const Icon(Icons.error)),
                                      // onPressed: () => logInEmailAndPassword(),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: ColorApp.lapisLazuli,
                                          // minimumSize: const Size.fromHeight(50),
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)))),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Sign Up",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "Nunito",
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.white,
                                            size: 20,
                                            weight: 700,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (!isLoading)
                                  SizedBox(
                                    width: width * 0.7 * 0.48,
                                    child: const Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Or',
                                          style:
                                              TextStyle(fontFamily: 'Nunito'),
                                        )),
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (!isLoading)
                                  SizedBox(
                                    // width: double.infinity,
                                    width: width * 0.7 * 0.48,
                                    height: 50,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          isSignUp = !isSignUp;
                                        });
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: 1,
                                                  color: ColorApp.lapisLazuli)),
                                          child: Center(
                                            child: Text(
                                              'Sign In',
                                              style: TextStyle(
                                                  color: ColorApp.lapisLazuli,
                                                  fontFamily: "Nunito",
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          )),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ).animate().fadeIn(),
              ),
            ),
          ],
        ));
  }
}
