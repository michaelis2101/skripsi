import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/services/devices_service.dart';

class EditDeviceName extends StatefulWidget {
  String deviceID;
  EditDeviceName({super.key, required this.deviceID});

  @override
  State<EditDeviceName> createState() => _EditDeviceNameState();
}

class _EditDeviceNameState extends State<EditDeviceName> {
  TextEditingController newNameCont = TextEditingController();
  bool isLoading = false;

  Future<void> rename(String newName) async {
    setState(() {
      isLoading = true;
    });

    try {
      await DevicesService().changeDeviceName(widget.deviceID, newName);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
        Get.back();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * 0.3,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Device Name',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: newNameCont,
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
              ),
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
                  ),
                ),
              ),
            if (!isLoading)
              Column(
                children: [
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () async {
                          if (newNameCont.text.isEmpty) {
                            Get.defaultDialog(
                                title: 'Warning!',
                                middleText: 'Device name cannot be empty',
                                confirm: SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10))),
                                      child: const Text(
                                        'Ok',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      )),
                                ));
                          } else {
                            await rename(newNameCont.text);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ColorApp.lapisLazuli,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: const Text(
                          'Rename Device',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        )),
                  )
                ],
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
                      side: BorderSide(width: 1, color: ColorApp.lapisLazuli),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: ColorApp.lapisLazuli, fontSize: 20),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
