import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/classes/input_cl.dart';
import 'package:ta_web/models/widget_model.dart';
import 'package:ta_web/services/devices_service.dart';
import 'package:uuid/uuid.dart';

class CreateWidget extends StatefulWidget {
  VoidCallback onWidgetCreated;
  String deviceID;
  List<String> keys;
  CreateWidget(
      {super.key,
      required this.keys,
      required this.deviceID,
      required this.onWidgetCreated});

  @override
  State<CreateWidget> createState() => _CreateWidgetState();
}

class _CreateWidgetState extends State<CreateWidget> {
  String? selectedKey;
  String? selectedWidget;
  String? selectedDataType;

  bool isLoading = false;

  void testLoading() => setState(() {
        isLoading = !isLoading;
      });

  TextEditingController minCont = TextEditingController();
  TextEditingController maxCont = TextEditingController();
  TextEditingController widgetNameCont = TextEditingController();

  List<String> widgetSelection = ['String', 'Switch', 'Gauge', 'Input'];
  List<String> dataTypeSelection = ['String', 'Numeric'];
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
  Widget build(BuildContext context) {
    return Container(
      // height: MediaQuery.of(context).size.height * 0.5,
      width: MediaQuery.of(context).size.width * 0.3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
              'Choose Key',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
            ),
            // const SizedBox(
            //   height: 10,
            // ),
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
                      'Select Key From Device',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          // fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ))
                  ],
                ),
                value: selectedKey,
                onChanged: (value) {
                  setState(() {
                    selectedKey = value as String;
                  });
                },
                items: widget.keys
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

            const SizedBox(
              height: 10,
            ),

            const Text(
              'Choose Widget',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
            ),

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
                      'Select Widget to Show The Data',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          // fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ))
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
                  items: dataTypeSelection
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

            if (selectedWidget == 'Gauge' ||
                selectedWidget == 'String' ||
                selectedDataType == 'Numeric')
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          controller: minCont,
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          controller: maxCont,
                          decoration: InputStyle().fieldStyle,
                        ),
                      )
                    ],
                  ),
                ],
              ),

            // if (selectedWidget != 'Gauge' && selectedWidget != 'String')
            //   const SizedBox(
            //     height: 50,
            //   ),

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
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ColorApp.lapisLazuli,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () async {
                          if (widgetNameCont.text.isEmpty ||
                              selectedKey == null ||
                              selectedWidget == null) {
                            Get.defaultDialog(
                                title: 'Warning!',
                                middleText: 'Please fill all the fields',
                                // textConfirm: 'Ok',
                                onConfirm: () {
                                  Get.back();
                                },
                                confirm: SizedBox(
                                  height: 50,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: ColorApp.lapisLazuli,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10))),
                                      onPressed: () => Get.back(),
                                      child: const Text(
                                        'OK',
                                        style: TextStyle(color: Colors.white),
                                      )),
                                ));
                          } else {
                            WidgetModel newWidget = WidgetModel(
                              key: selectedKey!,
                              type: selectedWidget!,
                              minValue: ((selectedWidget! == 'String' ||
                                          selectedWidget! == 'Gauge') &&
                                      minCont.text.isNotEmpty)
                                  ? double.parse(minCont.text)
                                  : 0,
                              maxValue: ((selectedWidget! == 'String' ||
                                          selectedWidget! == 'Gauge') &&
                                      maxCont.text.isNotEmpty)
                                  ? double.parse(maxCont.text)
                                  : 100,
                            );

                            String id = generateWidgetId();

                            setState(() {
                              isLoading = true;
                            });
                            try {
                              await DevicesService().createNewWidget(
                                  newWidget,
                                  widget.deviceID,
                                  // id.toString().toLowerCase(),
                                  const Uuid().v4(),
                                  widgetNameCont.text,
                                  selectedDataType.toString() == 'null'
                                      ? 'Numeric'
                                      : selectedDataType.toString());
                            } catch (e) {
                              Get.snackbar('Warning', e.toString());
                            } finally {
                              widget.onWidgetCreated();
                              setState(() {
                                isLoading = false;
                              });

                              Get.back();
                            }
                          }

                          //===========================================================================

                          //===========================================================================
                        },
                        child: const Text(
                          'Create Widget',
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
              ),
          ],
        ),
      ),
    );
  }
}
