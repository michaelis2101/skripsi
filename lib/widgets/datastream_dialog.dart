import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/controllers/new_device_cont.dart';
import 'package:ta_web/models/datastream_model.dart';
import 'package:ta_web/widgets/widget_preview.dart';

class DataStreamDialog extends StatefulWidget {
  // TextEditingController pinTitle;

  DataStreamDialog({super.key});

  @override
  State<DataStreamDialog> createState() => _DataStreamDialogState();
}

class _DataStreamDialogState extends State<DataStreamDialog> {
  NewDiviceCont newDeviceCont = Get.put(NewDiviceCont());

  bool isPinAlreadySelected(String pin) {
    switch (pin) {
      case 'P1':
        return newDeviceCont.titleP1.value != '-' &&
            newDeviceCont.widgetP1.value != '-';
      case 'P2':
        return newDeviceCont.titleP2.value != '-' &&
            newDeviceCont.widgetP2.value != '-';
      case 'P3':
        return newDeviceCont.titleP3.value != '-' &&
            newDeviceCont.widgetP3.value != '-';
      case 'P4':
        return newDeviceCont.titleP4.value != '-' &&
            newDeviceCont.widgetP4.value != '-';
      case 'P5':
        return newDeviceCont.titleP5.value != '-' &&
            newDeviceCont.widgetP5.value != '-';
      default:
        return false;
    }
  }

  final List<String> virtualPins = [
    'P1',
    'P2',
    'P3',
    'P4',
    'P5',
  ];

  final List<String> pinWidgets = [
    'String',
    'Button',
    'Switch',
    'Gauge',
    'Chart',
  ];

  TextEditingController pinTitle = TextEditingController();
  TextEditingController gaugeMinValue = TextEditingController();
  TextEditingController gaugeMaxValue = TextEditingController();
  String? selectedPin;
  String? selectedWidget;

  String widgetTitle = '';
  double gaugeMin = 0;
  double gaugeMax = 100;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width * 0.74,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Title',
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.74 / 2,
                  height: 50,
                  child: TextField(
                      controller: pinTitle,
                      onChanged: (value) {
                        setState(() {
                          widgetTitle = value;
                        });
                      },
                      // readOnly: true,
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
                        hintText: 'Pin Title',
                      )),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Choose Virtual PIN',
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
                ),

                //dropdown button virtual pin
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.74 / 2,
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton2(
                    isExpanded: true,
                    hint: const Row(
                      children: [
                        Expanded(
                            child: Text(
                          'Select Virtual Pin',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              // fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ))
                      ],
                    ),
                    value: selectedPin,
                    onChanged: (value) {
                      setState(() {
                        selectedPin = value as String;
                      });
                    },
                    items: virtualPins
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
                              ),
                            ))
                        .toList(),
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
                        width: MediaQuery.of(context).size.width * 0.74 / 2,
                        padding: const EdgeInsets.all(8)),
                    style: TextStyle(fontFamily: 'Nunito'),
                  )),
                ),

                //============================================================================================

                const SizedBox(height: 10),
                const Text(
                  'Choose Widget',
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
                ),

                //dropdown widget

                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.74 / 2,
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton2(
                    isExpanded: true,
                    hint: const Row(
                      children: [
                        Expanded(
                            child: Text(
                          'Select Widget',
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
                    items: pinWidgets
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
                              ),
                            ))
                        .toList(),
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
                        width: MediaQuery.of(context).size.width * 0.74 / 2,
                        padding: const EdgeInsets.all(8)),
                    style: const TextStyle(fontFamily: 'Nunito'),
                  )),
                ),

                const SizedBox(height: 10),

                //============================================================================================

                if (selectedWidget == 'Gauge')
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.74 / 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Min Gauge Value',
                              style:
                                  TextStyle(fontFamily: 'Nunito', fontSize: 16),
                            ),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 0.74 / 8,
                              height: 50,
                              child: TextField(
                                  // onChanged: (value) {
                                  //   setState(() {
                                  //     gaugeMin = double.parse(
                                  //         double.parse(value)
                                  //             .toStringAsFixed(1));
                                  //   });
                                  //   if (gaugeMin >= gaugeMax) {
                                  //     setState(() {
                                  //       gaugeMax = gaugeMin * 2;
                                  //     });
                                  //   } else {
                                  //     setState(() {
                                  //       gaugeMax = double.parse(
                                  //           double.parse(value)
                                  //               .toStringAsFixed(1));
                                  //     });
                                  //   }
                                  // },
                                  onChanged: (value) {
                                    double newValue = double.parse(value);
                                    if (newValue >= gaugeMax) {
                                      // If the new value is greater than or equal to the max, adjust max
                                      setState(() {
                                        gaugeMax = newValue +
                                            1; // Set max to new value + 1
                                      });
                                    }
                                    setState(() {
                                      gaugeMin = newValue; // Update gaugeMin
                                    });
                                  },
                                  keyboardType: TextInputType.number,
                                  controller: gaugeMinValue,
                                  // readOnly: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    prefixIconColor: ColorApp.lapisLazuli,
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
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
                                    // hintText: 'Pin Title',
                                  )),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'Max Gauge Value',
                              style:
                                  TextStyle(fontFamily: 'Nunito', fontSize: 16),
                            ),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 0.74 / 8,
                              height: 50,
                              child: TextField(
                                  controller: gaugeMaxValue,
                                  onChanged: (value) {
                                    double newValue = double.parse(value);
                                    if (newValue <= gaugeMin) {
                                      // If the new value is less than or equal to the min, adjust min
                                      setState(() {
                                        gaugeMin = newValue -
                                            1; // Set min to new value - 1
                                      });
                                    }
                                    setState(() {
                                      gaugeMax = newValue; // Update gaugeMax
                                    });
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    prefixIconColor: ColorApp.lapisLazuli,
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
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
                                    // hintText: 'Pin Title',
                                  )),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.74 / 2,
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        backgroundColor: ColorApp.lapisLazuli,
                      ),
                      onPressed: selectedPin != null &&
                              isPinAlreadySelected(selectedPin!)
                          ? null
                          : () {
                              DataStream newDatastream = DataStream(
                                pinTitle: widgetTitle,
                                selectedWidget: selectedWidget!,
                                virtualPin: selectedPin!,
                                minGaugeVal: gaugeMin,
                                maxGaugeVal: gaugeMax,
                              );
                              // if (gaugeMin.toString().isNotEmpty &&
                              //     gaugeMax.toString().isNotEmpty) {
                              //   newDeviceCont.updateGaugeVal(
                              //       double.parse(gaugeMin.toString()),
                              //       double.parse(gaugeMax.toString()));
                              // }

                              if (selectedPin == 'P1') {
                                newDeviceCont.updateP1Info(
                                    widgetTitle, selectedWidget!);

                                if (gaugeMinValue.text.isNotEmpty &&
                                    gaugeMaxValue.text.isNotEmpty) {
                                  newDeviceCont.updateGaugeVal1(
                                      double.parse(gaugeMin.toString()),
                                      double.parse(gaugeMax.toString()));
                                }

                                newDeviceCont.addDataStream(newDatastream);
                              } else if (selectedPin == 'P2') {
                                newDeviceCont.updateP2Info(
                                    widgetTitle, selectedWidget!);
                                if (gaugeMinValue.text.isNotEmpty &&
                                    gaugeMaxValue.text.isNotEmpty) {
                                  newDeviceCont.updateGaugeVal2(
                                      double.parse(gaugeMin.toString()),
                                      double.parse(gaugeMax.toString()));
                                }

                                newDeviceCont.addDataStream(newDatastream);
                              } else if (selectedPin == 'P3') {
                                newDeviceCont.updateP3Info(
                                    widgetTitle, selectedWidget!);
                                if (gaugeMinValue.text.isNotEmpty &&
                                    gaugeMaxValue.text.isNotEmpty) {
                                  newDeviceCont.updateGaugeVal3(
                                      double.parse(gaugeMin.toString()),
                                      double.parse(gaugeMax.toString()));
                                }

                                newDeviceCont.addDataStream(newDatastream);
                              } else if (selectedPin == 'P4') {
                                newDeviceCont.updateP4Info(
                                    widgetTitle, selectedWidget!);

                                if (gaugeMinValue.text.isNotEmpty &&
                                    gaugeMaxValue.text.isNotEmpty) {
                                  newDeviceCont.updateGaugeVal4(
                                      double.parse(gaugeMin.toString()),
                                      double.parse(gaugeMax.toString()));
                                }

                                newDeviceCont.addDataStream(newDatastream);
                              } else if (selectedPin == 'P5') {
                                newDeviceCont.updateP5Info(
                                    widgetTitle, selectedWidget!);

                                if (gaugeMinValue.text.isNotEmpty &&
                                    gaugeMaxValue.text.isNotEmpty) {
                                  newDeviceCont.updateGaugeVal5(
                                      double.parse(gaugeMin.toString()),
                                      double.parse(gaugeMax.toString()));
                                }

                                newDeviceCont.addDataStream(newDatastream);
                              }
                              Get.back();
                            },
                      child: const Text(
                        'Create Datastream',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Nunito',
                            fontSize: 18),
                      )),
                )
              ],
            ),
          ),
          if (selectedWidget != null && selectedWidget!.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              // boxShadow: [BoxShadow(offset: Offset(10, 20))]),
              // color: Colors.redAccent,
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width * 0.74 / 2.1,
              child: Center(
                child: WidgetPreview(
                  widgetType: selectedWidget!,
                  minVal: gaugeMin,
                  maxVal: gaugeMax,
                  title: widgetTitle,
                ),
              ),
            ),
        ],
      ),
      // decoration: BoxDecoration(color: Colors.white),
    );
  }
}
