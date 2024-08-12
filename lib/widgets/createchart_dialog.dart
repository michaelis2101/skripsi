import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/models/chart_models.dart';
import 'package:ta_web/services/devices_service.dart';
import 'package:uuid/uuid.dart';

class CreateChart extends StatefulWidget {
  String deviceID;
  List<String> keys;
  CreateChart({super.key, required this.deviceID, required this.keys});

  @override
  State<CreateChart> createState() => _CreateChartState();
}

class _CreateChartState extends State<CreateChart> {
  String? selectedChartModel;
  String? selectedKey;
  String? selectedKY1Key;
  String? selectedKY2Key;

  bool isLoading = false;

  TextEditingController chartTitleCont = TextEditingController();

  List<String> chartSelection = ['Single Axis', 'Double Axis'];

  // String chartID = const Uuid().v4();

  String generateChartID() {
    Uuid uuid = const Uuid();
    return uuid.v4();
  }

  void createNewChart() async {
    String id = generateChartID();

    setState(() {
      isLoading = true;
    });
    try {

      await DevicesService().createNewChart(
          chartTitleCont.text, widget.deviceID, generateChartID());
    } catch (e) {
      Get.snackbar('Warning', e.toString());
    } finally {
      // widget.onWidgetCreated();
      setState(() {
        isLoading = false;
      });

      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width * 0.3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chart Title',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: chartTitleCont,
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
            // const Text(
            //   'Choose Key',
            //   style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
            // ),
            // SizedBox(
            //   height: 50,
            //   width: double.infinity,
            //   child: DropdownButtonHideUnderline(
            //       child: DropdownButton2(
            //     isExpanded: true,
            //     hint: const Row(
            //       children: [
            //         Expanded(
            //             child: Text(
            //           'Select Key From Device',
            //           style: TextStyle(
            //               fontFamily: 'Nunito',
            //               fontSize: 14,
            //               // fontWeight: FontWeight.bold,
            //               color: Colors.black),
            //         ))
            //       ],
            //     ),
            //     value: selectedKey,
            //     onChanged: (value) {
            //       setState(() {
            //         selectedKey = value as String;
            //       });
            //     },
            //     items: widget.keys
            //         .map((String item) => DropdownMenuItem<String>(
            //             value: item,
            //             child: Text(
            //               item,
            //               style: const TextStyle(
            //                 fontSize: 14,
            //                 // fontWeight: FontWeight.bold,
            //                 color: Colors.black,
            //               ),
            //               overflow: TextOverflow.ellipsis,
            //             )))
            //         .toList(),

            //     //buttonstyle
            //     buttonStyleData: ButtonStyleData(
            //         padding: const EdgeInsets.all(8),
            //         decoration: BoxDecoration(
            //           color: Colors.grey.shade100,
            //           borderRadius: BorderRadius.circular(10),
            //         )),
            //     iconStyleData: IconStyleData(
            //         icon: const Icon(Icons.arrow_forward_ios_rounded),
            //         iconSize: 14,
            //         iconEnabledColor: ColorApp.lapisLazuli),
            //     dropdownStyleData: DropdownStyleData(
            //         // maxHeight: 50,
            //         decoration: const BoxDecoration(
            //             color: Colors.white,
            //             borderRadius:
            //                 BorderRadius.vertical(bottom: Radius.circular(10))),
            //         width: MediaQuery.of(context).size.width * 0.29,
            //         padding: const EdgeInsets.all(8)),
            //   )),
            // ),
            // const SizedBox(
            //   height: 10,
            // ),

            //===================CHART MODEL=========================================================
            // const Text(
            //   'Chart Model',
            //   style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
            // ),
            // SizedBox(
            //   height: 50,
            //   width: double.infinity,
            //   child: DropdownButtonHideUnderline(
            //       child: DropdownButton2(
            //     isExpanded: true,
            //     hint: const Row(
            //       children: [
            //         Expanded(
            //             child: Text(
            //           'Select The Chart Model',
            //           style: TextStyle(
            //               fontFamily: 'Nunito',
            //               fontSize: 14,
            //               // fontWeight: FontWeight.bold,
            //               color: Colors.black),
            //         ))
            //       ],
            //     ),
            //     value: selectedChartModel,
            //     onChanged: (value) {
            //       setState(() {
            //         selectedChartModel = value as String;
            //       });
            //     },
            //     items: chartSelection
            //         .map((String item) => DropdownMenuItem<String>(
            //             value: item,
            //             child: Text(
            //               item,
            //               style: const TextStyle(
            //                 fontSize: 14,
            //                 // fontWeight: FontWeight.bold,
            //                 color: Colors.black,
            //               ),
            //               overflow: TextOverflow.ellipsis,
            //             )))
            //         .toList(),

            //     //buttonstyle
            //     buttonStyleData: ButtonStyleData(
            //         padding: const EdgeInsets.all(8),
            //         decoration: BoxDecoration(
            //           color: Colors.grey.shade100,
            //           borderRadius: BorderRadius.circular(10),
            //         )),
            //     iconStyleData: IconStyleData(
            //         icon: const Icon(Icons.arrow_forward_ios_rounded),
            //         iconSize: 14,
            //         iconEnabledColor: ColorApp.lapisLazuli),
            //     dropdownStyleData: DropdownStyleData(
            //         // maxHeight: 50,
            //         decoration: const BoxDecoration(
            //             color: Colors.white,
            //             borderRadius:
            //                 BorderRadius.vertical(bottom: Radius.circular(10))),
            //         width: MediaQuery.of(context).size.width * 0.29,
            //         padding: const EdgeInsets.all(8)),
            //   )),
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // if (selectedChartModel == 'Single Axis' ||
            //     selectedChartModel == 'Double Axis')
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const SizedBox(
            //           height: 50,
            //           width: 100,
            //           child: Align(
            //               alignment: Alignment.centerLeft,
            //               child: Text('Y-Axis 1 : ',
            //                   style: TextStyle(fontSize: 16)))),
            //       SizedBox(
            //         height: 50,
            //         // width: double.infinity,
            //         width: Get.width * 0.224,
            //         child: DropdownButtonHideUnderline(
            //             child: DropdownButton2(
            //           isExpanded: true,
            //           hint: const Row(
            //             children: [
            //               Expanded(
            //                   child: Text(
            //                 'Select Key From Device',
            //                 style: TextStyle(
            //                     fontFamily: 'Nunito',
            //                     fontSize: 14,
            //                     // fontWeight: FontWeight.bold,
            //                     color: Colors.black),
            //               ))
            //             ],
            //           ),
            //           value: selectedKY1Key,
            //           onChanged: (value) {
            //             setState(() {
            //               selectedKY1Key = value as String;
            //             });
            //           },
            //           items: widget.keys
            //               .map((String item) => DropdownMenuItem<String>(
            //                   value: item,
            //                   child: Text(
            //                     item,
            //                     style: const TextStyle(
            //                       fontSize: 14,
            //                       // fontWeight: FontWeight.bold,
            //                       color: Colors.black,
            //                     ),
            //                     overflow: TextOverflow.ellipsis,
            //                   )))
            //               .toList(),

            //           //buttonstyle
            //           buttonStyleData: ButtonStyleData(
            //               padding: const EdgeInsets.all(8),
            //               decoration: BoxDecoration(
            //                 color: Colors.grey.shade100,
            //                 borderRadius: BorderRadius.circular(10),
            //               )),
            //           iconStyleData: IconStyleData(
            //               icon: const Icon(Icons.arrow_forward_ios_rounded),
            //               iconSize: 14,
            //               iconEnabledColor: ColorApp.lapisLazuli),
            //           dropdownStyleData: DropdownStyleData(
            //               // maxHeight: 50,
            //               decoration: const BoxDecoration(
            //                   color: Colors.white,
            //                   borderRadius: BorderRadius.vertical(
            //                       bottom: Radius.circular(10))),
            //               width: MediaQuery.of(context).size.width * 0.24,
            //               padding: const EdgeInsets.all(8)),
            //         )),
            //       ),
            //     ],
            //   ),

            // const SizedBox(
            //   height: 10,
            // ),

            // if (selectedChartModel == 'Double Axis')
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const SizedBox(
            //           height: 50,
            //           width: 100,
            //           child: Align(
            //               alignment: Alignment.centerLeft,
            //               child: Text('Y-Axis 2 : ',
            //                   style: TextStyle(fontSize: 16)))),
            //       SizedBox(
            //         height: 50,
            //         // width: double.infinity,
            //         width: Get.width * 0.224,
            //         child: DropdownButtonHideUnderline(
            //             child: DropdownButton2(
            //           isExpanded: true,
            //           hint: const Row(
            //             children: [
            //               Expanded(
            //                   child: Text(
            //                 'Select Key From Device',
            //                 style: TextStyle(
            //                     fontFamily: 'Nunito',
            //                     fontSize: 14,
            //                     // fontWeight: FontWeight.bold,
            //                     color: Colors.black),
            //               ))
            //             ],
            //           ),
            //           value: selectedKY2Key,
            //           onChanged: (value) {
            //             setState(() {
            //               selectedKY2Key = value as String;
            //             });
            //           },
            //           items: widget.keys
            //               .map((String item) => DropdownMenuItem<String>(
            //                   value: item,
            //                   child: Text(
            //                     item,
            //                     style: const TextStyle(
            //                       fontSize: 14,
            //                       // fontWeight: FontWeight.bold,
            //                       color: Colors.black,
            //                     ),
            //                     overflow: TextOverflow.ellipsis,
            //                   )))
            //               .toList(),

            //           //buttonstyle
            //           buttonStyleData: ButtonStyleData(
            //               padding: const EdgeInsets.all(8),
            //               decoration: BoxDecoration(
            //                 color: Colors.grey.shade100,
            //                 borderRadius: BorderRadius.circular(10),
            //               )),
            //           iconStyleData: IconStyleData(
            //               icon: const Icon(Icons.arrow_forward_ios_rounded),
            //               iconSize: 14,
            //               iconEnabledColor: ColorApp.lapisLazuli),
            //           dropdownStyleData: DropdownStyleData(
            //               // maxHeight: 50,
            //               decoration: const BoxDecoration(
            //                   color: Colors.white,
            //                   borderRadius: BorderRadius.vertical(
            //                       bottom: Radius.circular(10))),
            //               width: MediaQuery.of(context).size.width * 0.24,
            //               padding: const EdgeInsets.all(8)),
            //         )),
            //       ),
            //     ],
            //   ),

            // if (selectedChartModel == 'Single Axis' ||
            //     selectedChartModel == 'Double Axis')
            //   const SizedBox(
            //     height: 10,
            //   ),

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
                          if (chartTitleCont.text.isEmpty) {
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
                            createNewChart();
                          }
                          // if (chartTitleCont.text.isEmpty ||
                          //     selectedChartModel == null) {
                          //   Get.defaultDialog(
                          //       title: 'Warning!',
                          //       middleText: 'Please fill all the fields',
                          //       // textConfirm: 'Ok',
                          //       onConfirm: () {
                          //         Get.back();
                          //       },
                          //       confirm: SizedBox(
                          //         height: 50,
                          //         width: double.infinity,
                          //         child: ElevatedButton(
                          //             style: ElevatedButton.styleFrom(
                          //                 backgroundColor: ColorApp.lapisLazuli,
                          //                 shape: RoundedRectangleBorder(
                          //                     borderRadius:
                          //                         BorderRadius.circular(10))),
                          //             onPressed: () => Get.back(),
                          //             child: const Text(
                          //               'OK',
                          //               style: TextStyle(color: Colors.white),
                          //             )),
                          //       ));
                          // } else {
                          //   if (selectedChartModel!.isNotEmpty) {
                          //     if (selectedChartModel == 'Single Axis') {
                          //       if (selectedKY1Key == null) {
                          //         Get.defaultDialog(
                          //             title: 'Warning!',
                          //             middleText: 'Please fill all the fields',
                          //             // textConfirm: 'Ok',
                          //             onConfirm: () {
                          //               Get.back();
                          //             },
                          //             confirm: SizedBox(
                          //               height: 50,
                          //               width: double.infinity,
                          //               child: ElevatedButton(
                          //                   style: ElevatedButton.styleFrom(
                          //                       backgroundColor:
                          //                           ColorApp.lapisLazuli,
                          //                       shape: RoundedRectangleBorder(
                          //                           borderRadius:
                          //                               BorderRadius.circular(
                          //                                   10))),
                          //                   onPressed: () => Get.back(),
                          //                   child: const Text(
                          //                     'OK',
                          //                     style: TextStyle(
                          //                         color: Colors.white),
                          //                   )),
                          //             ));
                          //       } else {
                          //         NewDoubleAxisChartModel newChart =
                          //             NewDoubleAxisChartModel(
                          //                 chartId: generateChartID(),
                          //                 title: chartTitleCont.text,
                          //                 type: selectedChartModel!,
                          //                 selectedYAxis1: selectedKY1Key!,
                          //                 selectedYAxis2: '');

                          //         createNewChart(newChart);
                          //         print('buat single chart');
                          //       }
                          //     } else if (selectedChartModel == 'Double Axis') {
                          //       if (selectedKY1Key == null ||
                          //           selectedKY2Key == null) {
                          //         Get.defaultDialog(
                          //             title: 'Warning!',
                          //             middleText: 'Please fill all the fields',
                          //             // textConfirm: 'Ok',
                          //             onConfirm: () {
                          //               Get.back();
                          //             },
                          //             confirm: SizedBox(
                          //               height: 50,
                          //               width: double.infinity,
                          //               child: ElevatedButton(
                          //                   style: ElevatedButton.styleFrom(
                          //                       backgroundColor:
                          //                           ColorApp.lapisLazuli,
                          //                       shape: RoundedRectangleBorder(
                          //                           borderRadius:
                          //                               BorderRadius.circular(
                          //                                   10))),
                          //                   onPressed: () => Get.back(),
                          //                   child: const Text(
                          //                     'OK',
                          //                     style: TextStyle(
                          //                         color: Colors.white),
                          //                   )),
                          //             ));
                          //       } else if (selectedKY1Key == selectedKY2Key) {
                          //         Get.defaultDialog(
                          //             title: 'Warning!',
                          //             middleText:
                          //                 'The value of Y-Axis1 cannot be the same as Y-Axis2',
                          //             // textConfirm: 'Ok',
                          //             onConfirm: () {
                          //               Get.back();
                          //             },
                          //             confirm: SizedBox(
                          //               height: 50,
                          //               width: double.infinity,
                          //               child: ElevatedButton(
                          //                   style: ElevatedButton.styleFrom(
                          //                       backgroundColor:
                          //                           ColorApp.lapisLazuli,
                          //                       shape: RoundedRectangleBorder(
                          //                           borderRadius:
                          //                               BorderRadius.circular(
                          //                                   10))),
                          //                   onPressed: () => Get.back(),
                          //                   child: const Text(
                          //                     'OK',
                          //                     style: TextStyle(
                          //                         color: Colors.white),
                          //                   )),
                          //             ));
                          //       } else {
                          // NewDoubleAxisChartModel newChart =
                          //     NewDoubleAxisChartModel(
                          //         chartId: generateChartID(),
                          //         title: chartTitleCont.text,
                          //         type: selectedChartModel!,
                          //         selectedYAxis1: selectedKY1Key!,
                          //         selectedYAxis2: selectedKY2Key!);
                          //         createNewChart(newChart);
                          //         print('buat double axis chart');
                          //       }
                          //     }
                          //   }

                          //   // if (selectedKY1Key == selectedKY2Key) {
                          //   //   Get.defaultDialog(
                          //   //       title: 'Warning!',
                          //   //       middleText:
                          //   //           'The Value of Y-Axis1 cannot be the same as Y-Axis2',
                          //   //       // textConfirm: 'Ok',
                          //   //       onConfirm: () {
                          //   //         Get.back();
                          //   //       },
                          //   //       confirm: SizedBox(
                          //   //         height: 50,
                          //   //         width: double.infinity,
                          //   //         child: ElevatedButton(
                          //   //             style: ElevatedButton.styleFrom(
                          //   //                 backgroundColor:
                          //   //                     ColorApp.lapisLazuli,
                          //   //                 shape: RoundedRectangleBorder(
                          //   //                     borderRadius:
                          //   //                         BorderRadius.circular(10))),
                          //   //             onPressed: () => Get.back(),
                          //   //             child: const Text(
                          //   //               'OK',
                          //   //               style: TextStyle(color: Colors.white),
                          //   //             )),
                          //   //       ));
                          //   // } else {

                          //   // }
                          // }

                          //===========================================================================

                          //===========================================================================
                        },
                        child: const Text(
                          'Create Chart',
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
