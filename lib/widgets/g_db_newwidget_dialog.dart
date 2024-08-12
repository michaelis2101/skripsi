import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/classes/input_cl.dart';
import 'package:ta_web/models/dashboard_model.dart';
import 'package:ta_web/services/dashboard_service.dart';
import 'package:uuid/uuid.dart';

class NewWidgetDialogDB extends StatefulWidget {
  String userEmail, dsahboardId;
  NewWidgetDialogDB(
      {super.key, required this.userEmail, required this.dsahboardId});

  @override
  State<NewWidgetDialogDB> createState() => _NewWidgetDialogDBState();
}

class _NewWidgetDialogDBState extends State<NewWidgetDialogDB> {
  var widgetNameCont = TextEditingController();
  var minValueCont = TextEditingController();
  var maxValueCont = TextEditingController();

  Map<String, dynamic>? selectedDevice;
  String? selectedDeviceName;
  String? selectedDeviceId;
  String? selectedDeviceKey;
  String? selectedWidget;
  String? selectedDataType;
  Map<String, dynamic>? selectedValue;
  // Object? selectedValue;

  List<Map<String, dynamic>> deviceList = [];
  List<String> selectedKeyList = [];
  // List
  bool deviceListLoading = false;
  bool addingWidgetLoading = false;
  List<String> widgetSelection = ['String', 'Switch', 'Gauge', 'Input'];

  final deviceListRef = FirebaseDatabase.instance.ref().child('devices');

  void getDeviceList() async {
    setState(() {
      deviceListLoading = true;
    });
    try {
      var snapshit = await deviceListRef
          .orderByChild('user')
          .equalTo(widget.userEmail)
          .get();
      List<Map<String, dynamic>> tempDeviceList = [];

      if (snapshit.exists) {
        Map<dynamic, dynamic>? snapshotValueMap =
            snapshit.value as Map<dynamic, dynamic>?;

        snapshotValueMap?.forEach((key, value) {
          tempDeviceList.add({
            'id': key.toString(),
            'name': value['deviceName'] as String,
            'value': value['value']
          });
        });
        setState(() {
          deviceList = tempDeviceList;
        });
      } else {
        setState(() {
          deviceList = [];
        });
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        deviceListLoading = false;
      });
      print(deviceList);
    }
  }

  void addNewWidget(DashboardModel param, String dataType) async {
    setState(() {
      addingWidgetLoading = true;
    });
    try {
      await DashboardService().createNewWidget(
        widget.dsahboardId,
        param,
        dataType,
      );
    } catch (e) {
      rethrow;
    } finally {
      setState(() {
        addingWidgetLoading = false;
      });
      Get.back();
    }
  }

  String generateWidgetId() {
    const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    String id = '';

    for (int i = 0; i < 9; i++) {
      id += chars[random.nextInt(chars.length)];
    }

    return id;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * 0.3,
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Widget Name',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: widgetNameCont,
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
            const Text(
              'Choose Device',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 50,
              child: DropdownButtonHideUnderline(
                  child: DropdownButton2<Map<String, dynamic>>(
                isExpanded: true,
                value: selectedDevice,
                onChanged: (value) {
                  setState(() {
                    selectedDevice = value!;
                    selectedDeviceName = value['name'] as String;
                    selectedDeviceId = value['id'] as String;
                    selectedValue = value['value'];
                  });

                  if (selectedValue != null) {
                    // print(selectedValue);

                    setState(() {
                      selectedKeyList.clear();
                      selectedDeviceKey = null;
                    });

                    selectedValue?.forEach(
                      (key, value) {
                        selectedKeyList.add(key);
                      },
                    );

                    print(selectedKeyList);
                  }
                },
                items: deviceList
                    .map((dashboard) => DropdownMenuItem<Map<String, dynamic>>(
                          value: dashboard,
                          child: Text(
                            dashboard['name'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                hint: const Text(
                  'Select Device',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      // fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                buttonStyleData: ButtonStyleData(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    )),
                iconStyleData: IconStyleData(
                    icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                    iconSize: 14,
                    iconEnabledColor: ColorApp.lapisLazuli),
                dropdownStyleData: DropdownStyleData(
                    // maxHeight: 50,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(10))),
                    // width: MediaQuery.of(context).size.width / 3,
                    width: MediaQuery.of(context).size.width * 0.29,
                    padding: const EdgeInsets.all(8)),
              )),
            ),
            const SizedBox(
              height: 10,
            ),
            if (selectedDevice != null)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Key From Device',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    height: 50,
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                      isExpanded: true,
                      value: selectedDeviceKey,
                      onChanged: (value) {
                        setState(() {
                          selectedDeviceKey = value;
                        });
                      },
                      items: selectedKeyList
                          .map((select) => DropdownMenuItem<String>(
                                value: select,
                                child: Text(
                                  select,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      hint: const Text(
                        'Select Device',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            // fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      buttonStyleData: ButtonStyleData(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          )),
                      iconStyleData: IconStyleData(
                          icon:
                              const Icon(Icons.arrow_drop_down_circle_outlined),
                          iconSize: 14,
                          iconEnabledColor: ColorApp.lapisLazuli),
                      dropdownStyleData: DropdownStyleData(
                          // maxHeight: 50,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(10))),
                          // width: MediaQuery.of(context).size.width / 3,
                          width: MediaQuery.of(context).size.width * 0.29,
                          padding: const EdgeInsets.all(8)),
                    )),
                  ),
                ],
              ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Select Widget Type',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                isExpanded: true,
                hint: const Row(
                  children: [
                    Text(
                      'Select Widget',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          // fontWeight: FontWeight.bold,
                          color: Colors.black),
                    )
                  ],
                ),
                value: selectedWidget,
                onChanged: (value) {
                  setState(() {
                    selectedWidget = value as String;
                  });
                },
                items: widgetSelection
                    .map((String item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                            // fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )))
                    .toList(),

                //buttonstyle
                buttonStyleData: ButtonStyleData(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    )),
                iconStyleData: IconStyleData(
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                    iconSize: 14,
                    iconEnabledColor: ColorApp.lapisLazuli),
                dropdownStyleData: DropdownStyleData(
                    // maxHeight: 50,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(10))),
                    width: MediaQuery.of(context).size.width * 0.29,
                    padding: const EdgeInsets.all(8)),
              )),
            ),
            //+++++++++++++++++++++++++++++++++++++++++++++++
            if (selectedWidget == 'Input')
              const SizedBox(
                height: 10,
              ),

            if (selectedWidget == 'Input')
              const Text(
                'Choose Data Type',
                style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
              ),

            //dropdown datatype
            if (selectedWidget == 'Input')
              SizedBox(
                height: 50,
                width: double.infinity,
                child: DropdownButtonHideUnderline(
                    child: DropdownButton2(
                  isExpanded: true,
                  hint: const Row(
                    children: [
                      Expanded(
                          child: Text(
                        'Select Data Type For Input',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            // fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ))
                    ],
                  ),
                  value: selectedDataType,
                  onChanged: (value) {
                    setState(() {
                      selectedDataType = value as String;
                    });
                  },
                  items: ['String', 'Numeric']
                      .map((String item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 14,
                              // fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          )))
                      .toList(),

                  //buttonstyle
                  buttonStyleData: ButtonStyleData(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      )),
                  iconStyleData: IconStyleData(
                      icon: const Icon(Icons.arrow_forward_ios_rounded),
                      iconSize: 14,
                      iconEnabledColor: ColorApp.lapisLazuli),
                  dropdownStyleData: DropdownStyleData(
                      // maxHeight: 50,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(10))),
                      width: MediaQuery.of(context).size.width * 0.29,
                      padding: const EdgeInsets.all(8)),
                )),
              ),

            const SizedBox(
              height: 10,
            ),
            if (selectedWidget == 'Gauge' || selectedWidget == 'String')
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('Min Value'),
                      SizedBox(
                        height: 50,
                        width: 100,
                        child: TextField(
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          keyboardType: TextInputType.number,
                          controller: minValueCont,
                          decoration: InputStyle().fieldStyle,
                        ),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('Max Value'),
                      SizedBox(
                        height: 50,
                        width: 100,
                        child: TextField(
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          keyboardType: TextInputType.number,
                          controller: maxValueCont,
                          decoration: InputStyle().fieldStyle,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            const SizedBox(
              height: 10,
            ),
            if (addingWidgetLoading)
              SizedBox(
                height: 110,
                width: double.infinity,
                child: Center(
                  child: CircularProgressIndicator(
                    color: ColorApp.lapisLazuli,
                  ),
                ),
              ),
            if (!addingWidgetLoading)
              Column(
                children: [
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        String widgetId = const Uuid().v4();
                        DashboardModel newWidget = DashboardModel(
                          dataKey: selectedDeviceKey!,
                          deviceID: selectedDeviceId!,
                          widgetName: widgetNameCont.text,
                          widgetType: selectedWidget!,
                          widgetID: widgetId,
                          minVal: minValueCont.text.isEmpty
                              ? 0
                              : double.parse(minValueCont.text),
                          maxVal: maxValueCont.text.isEmpty
                              ? 100
                              : double.parse(maxValueCont.text),
                        );

                        addNewWidget(
                            newWidget,
                            selectedDataType.toString() == 'null'
                                ? 'Numeric'
                                : selectedDataType!.toString());
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: ColorApp.lapisLazuli,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text(
                        'Create New Widget',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
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
              ),
          ],
        ),
      ),
    );
  }
}
