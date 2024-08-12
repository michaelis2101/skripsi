import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_network/image_network.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/classes/input_cl.dart';
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
  List<PlatformFile> _files = [];

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
      // backgroundColor: ColorApp.lapisLazuli,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: ColorApp.lapisLazuli,
            ))
          : Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: ColorApp.lapisLazuli),
                      // color: ColorApp.duronQuartzWhite,
                      borderRadius: BorderRadius.circular(10)),
                  height: Get.height,
                  width: Get.width / 1.8,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                // boxShadow: [
                                //   BoxShadow(
                                //       color: ColorApp.lapisLazuli,
                                //       spreadRadius: 2,
                                //       blurRadius: 4,
                                //       blurStyle: BlurStyle.inner,
                                //       offset: const Offset(0, 1))
                                // ],
                                color: Colors.white,
                                border: Border.all(
                                    width: 1, color: ColorApp.lapisLazuli),
                                borderRadius: BorderRadius.circular(10)),
                            width: double.infinity,
                            height: 200,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        border: Border.all(
                                          width: 3,
                                          color: ColorApp.lapisLazuli,
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Container(
                                        height: 120,
                                        width: 120,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                        child: userSettings['profile_pic'] !=
                                                null
                                            ? ImageNetwork(
                                                image:
                                                    userSettings['profile_pic'],
                                                height: 120,
                                                width: 120,
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                              )
                                            : ImageNetwork(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                image:
                                                    'https://firebasestorage.googleapis.com/v0/b/project-st-iot.appspot.com/o/default_asset%2Fdefaultpfp.png?alt=media&token=882c5086-0c64-4285-b452-ca0b021707b6',
                                                height: 120,
                                                width: 120),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Welcome Back, ${userInfo['username']}!',
                                    style: TextStyle(
                                        color: ColorApp.lapisLazuli,
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.person,
                              color: ColorApp.lapisLazuli,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                    width: 1,
                                    color: ColorApp.lightLapisLazuli)),
                            title: const Text('Change Profile Picture'),
                            tileColor: Colors.white,
                            onTap: () async {
                              await _selectFiles();
                              if (_files.isNotEmpty) {
                                try {
                                  await UserService().changePfp(email,
                                      _files[0], userSettings['profile_pic']);
                                } catch (e) {
                                  print(e);
                                } finally {
                                  getUserInfo();
                                }
                              } else {
                                setState(() {
                                  _files.clear();
                                });
                                Get.back();
                              }
                            },
                            // hoverColor: Colors.red,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.edit,
                              color: ColorApp.lapisLazuli,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                    width: 1,
                                    color: ColorApp.lightLapisLazuli)),
                            title: const Text('Change Username'),
                            tileColor: Colors.white,
                            onTap: () async {
                              Get.defaultDialog(
                                  title: 'Change Username',
                                  content: Container(
                                    width: Get.width * 0.2,
                                    child: Column(
                                      children: [
                                        TextField(
                                          controller: newNameCont,
                                          decoration: InputStyle().fieldStyle,
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        SizedBox(
                                          height: 50,
                                          width: double.infinity,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      ColorApp.lapisLazuli,
                                                  shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          width: 1,
                                                          color: ColorApp
                                                              .lapisLazuli),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  10)))),
                                              onPressed: () async {
                                                if (newNameCont.text.isEmpty) {
                                                  Get.defaultDialog(
                                                      title: 'Warning',
                                                      middleText:
                                                          'Name cannot be empty',
                                                      confirm: SizedBox(
                                                        width: 200,
                                                        height: 50,
                                                        child: ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    ColorApp
                                                                        .lapisLazuli,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10))),
                                                            onPressed: () {
                                                              Get.back();
                                                            },
                                                            child: const Text(
                                                              'Ok',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            )),
                                                      ));
                                                } else {
                                                  try {
                                                    await UserService()
                                                        .changeUsername(
                                                            user!.uid,
                                                            newNameCont.text);

                                                    getUserInfo();
                                                  } catch (e) {
                                                    print(e);
                                                  } finally {
                                                    newNameCont.clear();
                                                    Get.back();
                                                  }
                                                }
                                                // try {
                                                //   Auth().signOut();
                                                // } catch (e) {
                                                //   print(e);
                                                // } finally {
                                                //   Get.back();
                                                // }
                                              },
                                              child: const Text(
                                                'Yes',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        SizedBox(
                                          height: 50,
                                          width: double.infinity,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          width: 1,
                                                          color: ColorApp
                                                              .lapisLazuli),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  10)))),
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: Text(
                                                'Back',
                                                style: TextStyle(
                                                    color:
                                                        ColorApp.lapisLazuli),
                                              )),
                                        )
                                      ],
                                    ),
                                  ));
                            },
                            // hoverColor: Colors.red,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.logout_outlined,
                              color: ColorApp.lapisLazuli,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                    width: 1,
                                    color: ColorApp.lightLapisLazuli)),
                            title: const Text('Logout'),
                            tileColor: Colors.white,
                            onTap: () {
                              Get.defaultDialog(
                                  // middleTextStyle: const TextStyle(fontSize: 120),
                                  title: 'Log Out?',
                                  // middleText: 'Are you sure want to delete $widgetName?',
                                  content: Column(
                                    children: [
                                      const Text(
                                        'Are you sure want to sign out?',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        height: 50,
                                        width: double.infinity,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        width: 1,
                                                        color: ColorApp
                                                            .lapisLazuli),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)))),
                                            onPressed: () {
                                              try {
                                                Auth().signOut();
                                              } catch (e) {
                                                print(e);
                                              } finally {
                                                Get.back();
                                              }
                                            },
                                            child: Text(
                                              'Yes',
                                              style: TextStyle(
                                                  color: ColorApp.lapisLazuli),
                                            )),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      SizedBox(
                                        height: 50,
                                        width: double.infinity,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            width: 1,
                                                            color: Colors.red),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)))),
                                            onPressed: () {
                                              Get.back();
                                            },
                                            child: const Text(
                                              'No',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )),
                                      )
                                    ],
                                  ));
                            },
                            // hoverColor: Colors.red,
                          )
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
