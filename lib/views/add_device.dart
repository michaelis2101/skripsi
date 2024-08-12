import 'dart:math';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/controllers/new_device_cont.dart';
import 'package:ta_web/models/newdevice_model.dart';
import 'package:ta_web/services/devices_service.dart';
import 'package:ta_web/widgets/datastream_dialog.dart';
import 'package:ta_web/widgets/widget_preview.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  NewDiviceCont newDataStream = Get.put(NewDiviceCont());

  TextEditingController deviceName = TextEditingController();
  TextEditingController pinTitle = TextEditingController();
  String randomId = '';
  int generateRandomId() {
    final random = Random();
    final uniqueId = random.nextInt(900000000) + 100000000;
    return uniqueId;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      randomId = generateRandomId().toString();
    });
  }

  bool sValue = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ColorApp.lapisLazuli,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        automaticallyImplyLeading: false,
        title: const Text(
          "Add Device",
          style: TextStyle(
            fontFamily: "Nunito",
            fontSize: 30,
          ),
        ),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          height: height * 0.855,
          width: width * 0.74,
          child: Row(
            children: [
              SizedBox(
                height: height * 0.855,
                width: width * 0.74 / 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Device Name',
                        style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
                      ),
                      SizedBox(
                        width: width * 0.74 / 2,
                        height: 50,
                        child: TextField(
                            controller: deviceName,
                            // readOnly: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              prefixIconColor: ColorApp.lapisLazuli,
                              labelStyle: const TextStyle(color: Colors.grey),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              disabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              hintText: 'Enter Your Device Name',
                            )),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Data Stream',
                            style:
                                TextStyle(fontFamily: 'Nunito', fontSize: 16),
                          ),
                          InkWell(
                            onTap: () {
                              // Get.dialog(
                              //     useSafeArea: true,
                              //     Container(
                              //       height: height * 0.855,
                              //       width: width * 0.74,
                              //       decoration:
                              //           BoxDecoration(color: Colors.white),
                              //     ));
                              Get.defaultDialog(
                                  title: 'Create new Datastream',
                                  titleStyle: const TextStyle(
                                      fontFamily: 'Nunito',
                                      color: Colors.black),
                                  // barrierDismissible: false,
                                  content: DataStreamDialog());
                              // AlertDialog(content: ,);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: ColorApp.lapisLazuli,
                                  borderRadius: BorderRadius.circular(10)),
                              height: 30,
                              width: 30,
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Obx(() => SizedBox(
                            height: height * 0.600,
                            width: width * 0.74 / 2,
                            child: ListView.builder(
                              itemCount: newDataStream.dataStreams.length,
                              itemBuilder: (context, index) {
                                final data = newDataStream.dataStreams[index];

                                return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.grey.shade100,
                                      child: Text(
                                        data.virtualPin,
                                        style: const TextStyle(
                                            fontFamily: 'Nunito'),
                                      ),
                                    ),
                                    title: Text(
                                      data.pinTitle,
                                      style:
                                          const TextStyle(fontFamily: 'Nunito'),
                                    ),
                                    subtitle: Text(
                                      data.selectedWidget,
                                      style:
                                          const TextStyle(fontFamily: 'Nunito'),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        if (data.virtualPin == 'P1') {
                                          newDataStream.removeP1Data();
                                        } else if (data.virtualPin == 'P2') {
                                          newDataStream.removeP2Data();
                                        } else if (data.virtualPin == 'P3') {
                                          newDataStream.removeP3Data();
                                        } else if (data.virtualPin == 'P4') {
                                          newDataStream.removeP4Data();
                                        } else {
                                          newDataStream.removeP5Data();
                                        }
                                        newDataStream.removeDataStream(index);
                                        setState(() {});
                                      },
                                    ));
                              },
                            ),
                          )),
                      if (isLoading)
                        SizedBox(
                          height: 50,
                          width: width * 0.74 / 2,
                          child: Center(
                            child: LinearProgressIndicator(
                              color: ColorApp.lapisLazuli,
                            ),
                          ),
                        ),
                      if (!isLoading)
                        SizedBox(
                            height: 50,
                            width: width * 0.74 / 2,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorApp.lapisLazuli,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                onPressed: () async {
                                  NewDevice newDevice = NewDevice(
                                    deviceId: randomId.toString(),
                                    owner: user!.email!,
                                    user: user!.email!,
                                    deviceName: deviceName.text,

                                    //monGaugeVal
                                    minGaugeValP1:
                                        newDataStream.minGaugeVal1.value,
                                    minGaugeValP2:
                                        newDataStream.minGaugeVal2.value,
                                    minGaugeValP3:
                                        newDataStream.minGaugeVal3.value,
                                    minGaugeValP4:
                                        newDataStream.minGaugeVal4.value,
                                    minGaugeValP5:
                                        newDataStream.minGaugeVal5.value,

                                    //maxGaugeVal
                                    maxGaugeValP1:
                                        newDataStream.maxGaugeVal1.value,
                                    maxGaugeValP2:
                                        newDataStream.maxGaugeVal2.value,
                                    maxGaugeValP3:
                                        newDataStream.maxGaugeVal3.value,
                                    maxGaugeValP4:
                                        newDataStream.maxGaugeVal4.value,
                                    maxGaugeValP5:
                                        newDataStream.maxGaugeVal5.value,

                                    P1: '-',
                                    P2: '-',
                                    P3: '-',
                                    P4: '-',
                                    P5: '-',
                                    P1Title: newDataStream.titleP1.value,
                                    P2Title: newDataStream.titleP2.value,
                                    P3Title: newDataStream.titleP3.value,
                                    P4Title: newDataStream.titleP4.value,
                                    P5Title: newDataStream.titleP5.value,
                                    P1Widget: newDataStream.widgetP1.value,
                                    P2Widget: newDataStream.widgetP2.value,
                                    P3Widget: newDataStream.widgetP3.value,
                                    P4Widget: newDataStream.widgetP4.value,
                                    P5Widget: newDataStream.widgetP5.value,
                                  );
                                  // Get.snackbar('title', 'message');

                                  if (newDataStream.dataStreams.isEmpty ||
                                      deviceName.text.isEmpty) {
                                    // Get.snackbar(
                                    //     "Warning", "Data cannot be empty");
                                    Get.defaultDialog(
                                        title: "Warning",
                                        middleText: 'Data cannot be empty',
                                        titleStyle: const TextStyle(
                                            fontFamily: 'Nunito',
                                            color: Colors.black),
                                        middleTextStyle: const TextStyle(
                                            fontFamily: 'Nunito',
                                            color: Colors.black),
                                        // textConfirm: "OK",
                                        confirm: SizedBox(
                                          height: 50,
                                          width: double.infinity,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      ColorApp.lapisLazuli,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10))),
                                              onPressed: () => Get.back(),
                                              child: const Text(
                                                "OK",
                                                style: TextStyle(
                                                    fontFamily: 'Nunito',
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              )),
                                        ));
                                  } else {
                                    try {
                                      setState(() {
                                        isLoading = true;
                                      });

                                      await DevicesService().createNewDevice(
                                          DateFormat('dd-MM-yyyy')
                                              .format(DateTime.now())
                                              .toString(),
                                          newDevice);
                                    } catch (e) {
                                      Get.snackbar("Warning", e.toString());
                                    } finally {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      Get.defaultDialog();
                                    }
                                  }
                                },
                                child: const Text(
                                  'Create Device',
                                  style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 20,
                                      color: Colors.white),
                                )))

                      // const SizedBox(
                      //   height: 50,
                      //   width: ,
                      // )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.855,
                width: width * 0.74 / 2,
                child: Obx(() => ListView.builder(
                      itemCount: newDataStream.dataStreams.length,
                      itemBuilder: (context, index) {
                        final data = newDataStream.dataStreams[index];
                        return SizedBox(
                          height: 300,
                          width: 400,
                          child: WidgetPreview(
                              widgetType: data.selectedWidget,
                              minVal: data.minGaugeVal,
                              maxVal: data.maxGaugeVal,
                              title: data.pinTitle),
                        );
                      },
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
