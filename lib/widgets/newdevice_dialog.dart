import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/classes/input_cl.dart';
import 'package:ta_web/models/dynamicdevice_model.dart';
import 'package:ta_web/services/devices_service.dart';

class NewDevDialog extends StatefulWidget {
  const NewDevDialog({super.key});

  @override
  State<NewDevDialog> createState() => _NewDevDialogState();
}

class _NewDevDialogState extends State<NewDevDialog> {
  TextEditingController nameCont = TextEditingController();
  TextEditingController idCont = TextEditingController();

  int generateRandomId() {
    // final random = Random();
    final uniqueId = Random().nextInt(900000000) + 100000000;
    return uniqueId;
  }

  bool isLoading = false;

  void testLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      idCont.text = generateRandomId().toString();
    });
  }

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width * 0.354,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Device ID",
                style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
              ),
              TextField(
                  controller: idCont,
                  onChanged: (value) {},
                  enabled: false,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    prefixIconColor: ColorApp.lapisLazuli,
                    labelStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    disabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    // hintText: 'Pin Title',
                  )),
              const Text(
                '*id is auto generated',
                style: TextStyle(fontFamily: 'Nunito', fontSize: 12),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Device Name",
                style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
              ),
              TextField(
                controller: nameCont,
                // onChanged: (value) {
                //   setState(() {
                //     nameCont.text = value;
                //   });
                // },
                // decoration: InputDecoration(
                //   filled: true,
                //   fillColor: Colors.grey.shade100,
                //   prefixIconColor: ColorApp.lapisLazuli,
                //   labelStyle: const TextStyle(color: Colors.grey),
                //   focusedBorder: const OutlineInputBorder(
                //     borderSide: BorderSide.none,
                //     borderRadius: BorderRadius.all(Radius.circular(10)),
                //   ),
                //   enabledBorder: const OutlineInputBorder(
                //     borderSide: BorderSide.none,
                //     borderRadius: BorderRadius.all(Radius.circular(10)),
                //   ),
                //   disabledBorder: const OutlineInputBorder(
                //     borderSide: BorderSide.none,
                //     borderRadius: BorderRadius.all(Radius.circular(10)),
                //   ),
                //   // hintText: 'Pin Title',
                // )
                decoration: InputStyle().fieldStyle,
              ),
              const SizedBox(
                height: 10,
              ),
              if (isLoading)
                SizedBox(
                  height: 110,
                  child: Center(
                      child: CircularProgressIndicator(
                    color: ColorApp.lapisLazuli,
                  )),
                ),
              if (!isLoading)
                Column(
                  children: [
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: ColorApp.lapisLazuli,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () async {
                            DynamicDevice newDevice = DynamicDevice(
                              deviceId: idCont.text,
                              deviceName: nameCont.text,
                              owner: user!.email!,
                              user: user!.email!,
                            );

                            if (idCont.text.isEmpty || nameCont.text.isEmpty) {
                              Get.snackbar('Warning', 'Data cannot be empty');
                            } else if (idCont.text.length < 9) {
                              Get.snackbar("Error",
                                  "Device ID must be at least 9 characters");
                            } else {
                              try {
                                setState(() {
                                  isLoading = true;
                                });

                                await DevicesService()
                                    .createDynamicDevice(newDevice);
                              } catch (e) {
                                Get.snackbar("Warning", e.toString());
                              } finally {
                                setState(() {
                                  isLoading = false;
                                });

                                Get.back();
                              }

                              // testLoading();
                            }
                          },
                          child: const Text(
                            'Create Device',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          )),
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
                              side: BorderSide(
                                  width: 1, color: ColorApp.lapisLazuli),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                          onPressed: () => Get.back(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                color: ColorApp.lapisLazuli, fontSize: 20),
                          )),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
