import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/classes/input_cl.dart';
import 'package:ta_web/services/dashboard_service.dart';
import 'package:ta_web/widgets/info_dialog.dart';

class GlobalDashBoardCard extends StatelessWidget {
  String widgetName,
      dataKey,
      dataType,
      widgetType,
      widgetId,
      deviceId,
      deviceName,
      dashboardId;
  String? unit;
  double minVal, maxVal;
  GlobalDashBoardCard(
      {super.key,
      required this.dashboardId,
      required this.widgetName,
      required this.dataKey,
      required this.dataType,
      required this.widgetType,
      required this.widgetId,
      required this.deviceId,
      required this.deviceName,
      required this.minVal,
      required this.maxVal,
      this.unit});

  @override
  Widget build(BuildContext context) {
    final valCont = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref()
        .child('devices/$deviceId/value/$dataKey');

    void updateSwitchValue(bool value) {
      int intValue = value ? 1 : 0;
      dbRef.set(intValue);
    }

    TextEditingController newNameCont = TextEditingController();
    TextEditingController unitController = TextEditingController();

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // color: Colors.pink,
          border: Border.all(width: 1, color: ColorApp.lapisLazuli)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Container(
              color: ColorApp.lapisLazuli,
              height: 30,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$widgetName ($dataKey)",
                        style: const TextStyle(
                            fontFamily: 'Nunito', color: Colors.white)),
                    Row(
                      children: [
                        Tooltip(
                          message: 'Add Unit',
                          child: InkWell(
                              onTap: () {
                                Get.defaultDialog(
                                    title: 'Add/Change Units',
                                    content: Container(
                                      width: 400,
                                      child: Column(
                                        children: [
                                          TextField(
                                            controller: unitController,
                                            decoration: InputStyle().fieldStyle,
                                          ),
                                          const SizedBox(
                                            height: 10,
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
                                                  if (unitController
                                                      .text.isEmpty) {
                                                    Get.defaultDialog(
                                                        title: 'Warning',
                                                        middleText:
                                                            'Unit cannot be null',
                                                        confirm: SizedBox(
                                                          width:
                                                              double.infinity,
                                                          height: 50,
                                                          child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  shape: RoundedRectangleBorder(
                                                                      side: BorderSide(
                                                                          width:
                                                                              1,
                                                                          color: ColorApp
                                                                              .lapisLazuli),
                                                                      borderRadius: const BorderRadius
                                                                          .all(
                                                                          Radius.circular(
                                                                              10)))),
                                                              onPressed: () =>
                                                                  Get.back(),
                                                              child: const Text(
                                                                'Ok',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              )),
                                                        ));
                                                  } else {
                                                    try {
                                                      await DashboardService()
                                                          .changeWidgetUnit(
                                                              dashboardId,
                                                              widgetId,
                                                              unitController
                                                                  .text);
                                                    } catch (e) {
                                                      print(e);
                                                    } finally {
                                                      // await getUnit();
                                                      // setState(() {});
                                                      Get.back();
                                                    }
                                                  }
                                                },
                                                child: const Text(
                                                  'Change Unit',
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
                                                    backgroundColor: Colors.red,
                                                    shape: const RoundedRectangleBorder(
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
                                                  'Back',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                          )
                                        ],
                                      ),
                                    ));
                              },
                              child: const Icon(
                                Icons.miscellaneous_services,
                                color: Colors.white,
                              )),
                        ),
                        Tooltip(
                          message: 'Info',
                          textAlign: TextAlign.start,
                          child: InkWell(
                              onTap: () {
                                Get.defaultDialog(
                                    actions: [
                                      SizedBox(
                                        height: 50,
                                        width: 200,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      width: 1,
                                                      color:
                                                          ColorApp.lapisLazuli),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                            ),
                                            onPressed: () => Get.back(),
                                            child: Text(
                                              'Back',
                                              style: TextStyle(
                                                  color: ColorApp.lapisLazuli),
                                            )),
                                      )
                                    ],
                                    title: 'Widget Info',
                                    content: InfoDialog(
                                        widgetId: widgetId.toString(),
                                        dataKey: dataKey.toString(),
                                        dataType: dataType.toString(),
                                        deviceName: deviceName.toString(),
                                        widgetName: widgetName.toString(),
                                        widgetType: widgetType.toString(),
                                        maxGauge: maxVal,
                                        minGauge: minVal,
                                        deviceID: deviceId.toString()));
                              },
                              child: const Icon(
                                Icons.info,
                                color: Colors.white,
                              )),
                        ),
                        // Tooltip(
                        //   message: 'Widget Note',
                        //   child: InkWell(
                        //     child: const Icon(
                        //       Icons.note_add,
                        //       color: Colors.white,
                        //     ),
                        //     onTap: () {},
                        //   ),
                        // ),
                        Tooltip(
                          message: 'Rename Widget',
                          child: InkWell(
                              onTap: () {
                                Get.defaultDialog(
                                    title: 'Change Widget Name',
                                    content: Container(
                                      width: 400,
                                      child: Column(
                                        children: [
                                          TextField(
                                            controller: newNameCont,
                                            decoration: InputStyle().fieldStyle,
                                          ),
                                          const SizedBox(
                                            height: 10,
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
                                                  if (newNameCont
                                                      .text.isEmpty) {
                                                    Get.defaultDialog(
                                                        title: 'Warning',
                                                        middleText:
                                                            'Widget name cannot be null',
                                                        confirm: SizedBox(
                                                          width:
                                                              double.infinity,
                                                          height: 50,
                                                          child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  shape: RoundedRectangleBorder(
                                                                      side: BorderSide(
                                                                          width:
                                                                              1,
                                                                          color: ColorApp
                                                                              .lapisLazuli),
                                                                      borderRadius: const BorderRadius
                                                                          .all(
                                                                          Radius.circular(
                                                                              10)))),
                                                              onPressed: () =>
                                                                  Get.back(),
                                                              child: const Text(
                                                                'Ok',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              )),
                                                        ));
                                                  } else {
                                                    try {
                                                      await DashboardService()
                                                          .renameDashboardWidget(
                                                              dashboardId,
                                                              widgetId,
                                                              newNameCont.text
                                                                  .toString());
                                                    } catch (e) {
                                                      print(e);
                                                    } finally {
                                                      Get.back();
                                                    }
                                                  }
                                                },
                                                child: const Text(
                                                  'Rename Widget',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                          )
                                        ],
                                      ),
                                    ));
                              },
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              )),
                        ),
                        // Tooltip(
                        //   message: 'Change Wigdet Type',
                        //   child: InkWell(
                        //       onTap: () {},
                        //       child: const Icon(
                        //         Icons.restart_alt_outlined,
                        //         color: Colors.white,
                        //       )),
                        // ),
                        Tooltip(
                          message: 'Delete Widget',
                          child: InkWell(
                              onTap: () {
                                Get.defaultDialog(
                                    barrierDismissible: false,
                                    title:
                                        'Delete Confirmation for $widgetName',
                                    // middleText:
                                    //     'Are you sure want to delete $widgetName?',
                                    content: Container(
                                      // width: 40,
                                      // color: Colors.amber,
                                      child: Column(
                                        children: [
                                          Text(
                                            'Are you sure want to delete $widgetName?',
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            height: 50,
                                            width: double.infinity,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
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
                                                  try {
                                                    DashboardService()
                                                        .deleteWidget(widgetId,
                                                            dashboardId);
                                                  } catch (e) {
                                                    print(e);
                                                  } finally {
                                                    Get.back();
                                                  }
                                                },
                                                child: Text(
                                                  'Yes',
                                                  style: TextStyle(
                                                      color:
                                                          ColorApp.lapisLazuli),
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
                                                    shape: const RoundedRectangleBorder(
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
                                      ),
                                    )

                                    // contentPadding: const EdgeInsets.all(10),

                                    );
                              },
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              )),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  left: 5,
                  top: 5,
                  child: StreamBuilder(
                    stream: FirebaseDatabase.instance
                        .ref()
                        .child('devices/$deviceId/status/status')
                        .onValue,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        var status = snapshot.data.snapshot.value;

                        if (status == null || status == 'offline') {
                          return const Row(
                            children: [
                              Icon(
                                Icons.circle_sharp,
                                color: Colors.red,
                                size: 18,
                              ),
                              SizedBox(width: 5),
                              Text('Offline')
                            ],
                          );
                        } else {
                          return const Row(
                            children: [
                              Icon(
                                Icons.circle_sharp,
                                color: Colors.green,
                                size: 18,
                              ),
                              SizedBox(width: 5),
                              Text('Online')
                            ],
                          );
                        }
                      } else if (snapshot.hasError) {
                        return const Row(
                          children: [
                            Icon(
                              Icons.circle_sharp,
                              color: Colors.grey,
                              size: 18,
                            ),
                            SizedBox(width: 5),
                            Text('N/A')
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: ColorApp.lapisLazuli,
                                )),
                            const Text('Loading...')
                          ],
                        );
                      }
                    },
                  ),
                ),
                StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref()
                      .child('devices/$deviceId/value/$dataKey')
                      .onValue,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      var value = snapshot.data.snapshot.value;

                      bool switchValue =
                          (snapshot.data!.snapshot.value as double) > 0;

                      if (value == null) {
                        return const Center(
                          child: Text('No Data Found'),
                        );
                      }

                      if (widgetType == 'String') {
                        return Center(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                overflow: TextOverflow.ellipsis,
                                value.toString(),
                                style: const TextStyle(
                                    fontFamily: 'Nunito', fontSize: 45),
                              ),
                              if (unit != null) const SizedBox(width: 10),
                              if (unit != null)
                                Text(
                                  overflow: TextOverflow.ellipsis,
                                  unit.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 30,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ).animate().fadeIn(),
                        );
                      } else if (widgetType == 'Gauge') {
                        return Center(
                          child: SfRadialGauge(
                            enableLoadingAnimation: true,
                            axes: <RadialAxis>[
                              RadialAxis(
                                annotations: [
                                  GaugeAnnotation(
                                    // widget: Text(
                                    //   value.toString(),
                                    //   style: const TextStyle(
                                    //       fontSize: 30, fontFamily: 'Nunito'),
                                    // ),
                                    widget: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          value.toString(),
                                          style: const TextStyle(
                                              fontSize: 30,
                                              fontFamily: 'Nunito'),
                                        ),
                                        if (unit != null)
                                          const SizedBox(height: 1),
                                        if (unit != null)
                                          Text(
                                            unit.toString(),
                                            style: const TextStyle(
                                                // fontWeight: FontWeight.bold,
                                                fontStyle: FontStyle.italic,
                                                fontSize: 20),
                                          )
                                      ],
                                    ),
                                  )
                                ],
                                minimum: minVal,
                                maximum: maxVal,
                                pointers: <GaugePointer>[
                                  RangePointer(
                                    value: (value is double || value is int)
                                        ? value
                                        : 0,
                                    // value: value == '-' ? 0 : value,
                                    enableAnimation: true,
                                    color: ColorApp.lapisLazuli,
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      } else if (widgetType == 'Switch') {
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SizedBox(
                              // height: 150,
                              width: double.infinity,
                              child: Center(
                                child: AnimatedToggleSwitch.dual(
                                  current: switchValue,
                                  first: false,
                                  second: true,
                                  height: 150,
                                  // indicatorSize: Size.fromHeight(100 * 0.5),
                                  indicatorSize: const Size.fromHeight(120),
                                  borderWidth: 10,
                                  iconBuilder: (value) => value == false
                                      ? const Icon(
                                          Icons.power_settings_new_rounded,
                                          size: 50,
                                          color: Colors.red,
                                        )
                                      : const Icon(
                                          Icons.power_settings_new_rounded,
                                          size: 50,
                                          color: Colors.green,
                                        ),
                                  textBuilder: (value) => value == false
                                      ? const Center(
                                          child: Padding(
                                          padding: EdgeInsets.only(top: 10),
                                          child: Text(
                                            'Off',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Nunito',
                                                fontSize: 50),
                                          ),
                                        ))
                                      : const Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 10),
                                            child: Text(
                                              'On',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Nunito',
                                                  fontSize: 50),
                                            ),
                                          ),
                                        ),
                                  styleBuilder: (value) => ToggleStyle(
                                      backgroundColor: value == false
                                          ? Colors.red
                                          : Colors.green,
                                      indicatorColor: value == false
                                          ? Colors.white
                                          : Colors.white),
                                  style: ToggleStyle(
                                      borderColor: Colors.transparent,
                                      borderRadius: BorderRadius.circular(100),
                                      boxShadow: [
                                        const BoxShadow(
                                          color: Colors.black26,
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: Offset(0, 1.5),
                                        ),
                                      ],
                                      indicatorBorderRadius:
                                          BorderRadius.circular(100)

                                      // indicatorColor: ColorApp.lightLapisLazuli,
                                      ),
                                  onChanged: (value) {
                                    updateSwitchValue(value);
                                  },
                                ),
                              )),
                        );
                      }
                      //======nambah jenis widget lain disini

                      else if (widgetType == 'Input') {
                        return Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: valCont,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Data Cannot be Empty';
                                    }
                                    if (dataType == 'Numeric' &&
                                        !RegExp(r'^\d+$').hasMatch(value)) {
                                      return 'Please enter a valid number';
                                    }
                                    return null;
                                  },
                                  inputFormatters: (dataType == 'Numeric' ||
                                          value.runtimeType == int ||
                                          value.runtimeType == double)
                                      ? [FilteringTextInputFormatter.digitsOnly]
                                      : [],
                                  keyboardType: dataType == 'Numeric'
                                      ? TextInputType.number
                                      : TextInputType.text,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    prefixIconColor: ColorApp.lapisLazuli,
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: ColorApp.lapisLazuli),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 0.5,
                                          color: ColorApp.lapisLazuli),
                                      // borderSide: BorderSide.none,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    disabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    focusedErrorBorder:
                                        const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.red),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    errorBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.red),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        'Data Type : ${value.runtimeType == int ? 'Numeric' : dataType}')),
                              ),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: ColorApp.lapisLazuli,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    onPressed: () async {
                                      // if (valCont.text.isEmpty) {}
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        // Proceed with your logic

                                        // updateInputValue(valCont.text);
                                        try {
                                          if (dataType == 'Numeric') {
                                            // updateInputValue(double.parse(valCont.text));
                                            dbRef.set(
                                                double.parse(valCont.text));
                                          } else {
                                            dbRef.set(valCont.text);
                                          }
                                        } catch (e) {
                                          print(e);
                                        } finally {
                                          valCont.clear();
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Submit',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                ),
                              )
                              // TextField()
                            ],
                          ),
                        );
                      } else {
                        return Center(
                          child: Text(value.toString()),
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          color: ColorApp.lapisLazuli,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
