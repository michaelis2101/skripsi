// import 'dart:ffi';

// import 'dart:math';

import 'dart:developer';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/classes/input_cl.dart';
import 'package:ta_web/models/log_model.dart';
import 'package:ta_web/services/devices_service.dart';
import 'package:ta_web/widgets/info_dialog.dart';

class WidgetCard extends StatefulWidget {
  String dataKey, widgetType, deviceId, deviceName, widgetName, id, dataType;
  // unit;
  double minGauge, maxGauge;
  String? unit;
  WidgetCard(
      {super.key,
      required this.id,
      required this.dataKey,
      required this.deviceId,
      required this.widgetType,
      required this.minGauge,
      required this.maxGauge,
      required this.deviceName,
      required this.widgetName,
      required this.dataType,
      this.unit});

  @override
  State<WidgetCard> createState() => _WidgetCardState();
}

class _WidgetCardState extends State<WidgetCard> {
  final FirebasePerformance performance = FirebasePerformance.instance;
  String unit = '';

  Future<void> getUnit() async {
    String tempunit =
        await DevicesService().getWidgetUnit(widget.id, widget.dataKey);

    if (tempunit == 'null') {
      setState(() {
        unit = '';
      });
    } else {
      setState(() {
        unit = tempunit;
      });
    }

    // print(unit);
  }

  // Future<void> checkLatency(String deviceid) async {
  //   int now = DateTime.now().millisecondsSinceEpoch;

  //   final ref = FirebaseDatabase.instance.ref();
  //   final ts = ref.child('devices/$deviceid/lastUpdated/timestamp');

  //   try {
  //     final snapshot = await ts.get();
  //     if (snapshot.exists) {
  //       int lastupdate = int.parse(snapshot.value.toString());
  //       // print(snapshot.value);
  //       int latency = now - lastupdate;
  //       print('latency = $now - $lastupdate - 10000 = ${latency - 10000}');

  //       // }
  //       if (latency - 10000 > 1) {
  //         setState(() {
  //           _latencies.add(latency - 10000);
  //         });
  //         print(_latencies);
  //       }
  //     } else {
  //       // return 0;
  //     }
  //   } catch (e) {
  //     print(e);
  //     // return 0;
  //   }
  // }
  // Future<void> checkLatency(String deviceId) async {
  //   int now = DateTime.now().millisecondsSinceEpoch;

  //   final ref = FirebaseDatabase.instance.ref();
  //   final ts = ref.child('devices/$deviceId/lastUpdated/timestamp');

  //   try {
  //     final snapshot = await ts.get();
  //     if (snapshot.exists) {
  //       int lastupdate = int.parse(snapshot.value.toString());
  //       int latency = now - lastupdate; // Calculate actual latency
  //       print('latency = $now - $lastupdate = $latency');

  //       if (latency > 1) {
  //         setState(() {
  //           _latencies.add(latency);
  //         });
  //         print(_latencies);
  //       }
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  // Future<void> checkLatency(int lastUpdate) async {
  //   int now = DateTime.now().millisecondsSinceEpoch;
  //   int latency = now - lastUpdate - 10000;
  //   print('latency = $now - $lastUpdate = $latency');

  //   if (latency > 1) {
  //     _latencies.add(latency);

  //     print(_latencies);
  //   }
  // }

  var _lastValue;
  int? _lastUpdate;
  int? dataProcessingUpdate;
  List<int> _latencies = [];
  List<int> stringDataProccesing = [];
  List<int> gaugeDataProccesing = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getUnit();
    // print(widget.unit);
    // print(DateTime.now().millisecondsSinceEpoch);
    // latency(widget.deviceId);
  }

  @override
  Widget build(BuildContext context) {
    final valCont = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    final widgetNameCont = TextEditingController();
    final widgetUnit = TextEditingController();
    // var data = lastValue;

    // LogModel newVal = LogModel(
    //     deviceId: deviceId,
    //     value: currentValue.toString(),
    //     deviceName: deviceName);

    // insertDataToLog(newVal, data);

    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref()
        .child('devices/${widget.deviceId}/value/${widget.dataKey}');

    void updateSwitchValue(bool value) async {
      int intValue = value ? 1 : 0;
      await dbRef.set(intValue);
    }

    void updateInputValue(String param) {
      dbRef.set(param);
    }

    return Container(
      height: double.infinity,
      width: double.infinity,
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
                    Text('${widget.widgetName} (${widget.dataKey})',
                        overflow: TextOverflow.ellipsis,
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
                                            controller: widgetUnit,
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
                                                  if (widgetUnit.text.isEmpty) {
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
                                                      await DevicesService()
                                                          .changeWidgetUnit(
                                                              widget.deviceId,
                                                              widget.id,
                                                              widgetUnit.text);
                                                    } catch (e) {
                                                      print(e);
                                                    } finally {
                                                      await getUnit();
                                                      setState(() {});
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
                                        widgetId: widget.id,
                                        dataKey: widget.dataKey,
                                        dataType: widget.dataType,
                                        deviceName: widget.deviceName,
                                        widgetName: widget.widgetName,
                                        widgetType: widget.widgetType,
                                        maxGauge: widget.maxGauge,
                                        minGauge: widget.minGauge,
                                        deviceID: widget.deviceId));
                              },
                              child: const Icon(
                                Icons.info,
                                color: Colors.white,
                              )),
                        ),
                        Tooltip(
                          message: 'Change Name',
                          child: InkWell(
                              onTap: () {
                                Get.defaultDialog(
                                    title: 'Change Widget Title',
                                    content: Container(
                                      width: 400,
                                      child: Column(
                                        children: [
                                          TextField(
                                            controller: widgetNameCont,
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
                                                onPressed: () {
                                                  if (widgetNameCont
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
                                                      DevicesService()
                                                          .changeWidgetName(
                                                              widget.deviceId,
                                                              widget.id,
                                                              widgetNameCont
                                                                  .text);
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
                                Icons.edit,
                                color: Colors.white,
                              )),
                        ),
                        // Tooltip(
                        //   message: 'Change Widget',
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
                                // DevicesService().deleteWidget(deviceId, id);
                                Get.defaultDialog(
                                    title: 'Delete ${widget.widgetName}?',
                                    content: Container(
                                      child: Column(
                                        children: [
                                          Text(
                                            'Are you sure want to delete ${widget.widgetName}?',
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
                                                    DevicesService()
                                                        .deleteWidget(
                                                            widget.deviceId,
                                                            widget.id);
                                                  } catch (e) {
                                                    print(e);
                                                  } finally {
                                                    setState(() {
                                                      unit = '';
                                                    });
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
                                    ));
                              },
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          StreamBuilder(
            stream: FirebaseDatabase.instance
                .ref()
                .child('devices/${widget.deviceId}/value/${widget.dataKey}')
                .onValue,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                // checkLatency(widget.deviceId);

                // int lms = latency(widget.deviceId);
                // _latencies.add(latency(widget.deviceId) as int);
                // print(_latencies);
                // Trace trace = performance
                //     .newTrace('${widget.deviceId} : ${widget.dataKey} traces');

                // trace.start();

                // log('Latency: $latency ms');
                // print('Latency: $latency ms');
                // DateTime requestEndTime = DateTime.now();
                // int latency = _requestStartTime != null
                //     ? requestEndTime
                //         .difference(_requestStartTime!)
                //         .inMilliseconds
                //     : 0;
                // _latencies.add(latency);
                dataProcessingUpdate = DateTime.now().millisecondsSinceEpoch;

                var value = snapshot.data.snapshot.value;

                // print('kekee : ${snapshot.data.snapshot.key.toString()}');
                // if (_lastValue != value) {
                //   _lastValue = value;
                //   if (_lastUpdate != null) {
                //     checkLatency(_lastUpdate!);
                //   }
                //   _lastUpdate = DateTime.now().millisecondsSinceEpoch;
                // }
                // if (_lastValue != value) {
                //   _lastValue = value;
                //   checkLatency(widget.deviceId);
                //   print(_latencies);
                // }

                // int currentTimestamp =
                //     int.parse(snapshot.data.snapshot.key.toString());
                // if (_lastTimestamp == 0 || currentTimestamp != _lastTimestamp) {
                //   _lastTimestamp = currentTimestamp;
                //   checkLatency(widget.deviceId);
                // }

                // _requestStartTime = DateTime.now();

                // print("Data latency: $latency");

                // print(_latencies);

                // trace.stop();

                bool switchValue =
                    (snapshot.data!.snapshot.value as double) > 0;

                if (value == null) {
                  return const Center(
                    child: Text('No Data Found'),
                  );
                }

                if (widget.widgetType == 'String') {
                  // int processingTime = DateTime.now().millisecondsSinceEpoch -
                  //     dataProcessingUpdate!;
                  // stringDataProccesing.add(processingTime);
                  // print(processingTime);'
                  int processingTime = DateTime.now().millisecondsSinceEpoch;
                  // dataProcessingUpdate!;

                  stringDataProccesing
                      .add(processingTime - dataProcessingUpdate!);

                  print(stringDataProccesing);
                  print(
                      'Data Processing = ${DateTime.now().millisecondsSinceEpoch} - $dataProcessingUpdate = ${DateTime.now().millisecondsSinceEpoch - dataProcessingUpdate!}');
                  return Expanded(
                    child: Center(
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
                          if (widget.unit != null) const SizedBox(width: 10),
                          if (widget.unit != null)
                            Text(
                              overflow: TextOverflow.ellipsis,
                              widget.unit.toString(),
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 30,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ).animate().fadeIn(),
                    ),
                  );
                } else if (widget.widgetType == 'Gauge') {
                  return Expanded(
                    child: Center(
                      child: SfRadialGauge(
                        enableLoadingAnimation: true,
                        axes: <RadialAxis>[
                          RadialAxis(
                            annotations: [
                              GaugeAnnotation(
                                widget: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      value.toString(),
                                      style: const TextStyle(
                                          fontSize: 30, fontFamily: 'Nunito'),
                                    ),
                                    if (widget.unit != null)
                                      const SizedBox(height: 1),
                                    if (widget.unit != null)
                                      Text(
                                        widget.unit.toString(),
                                        style: const TextStyle(
                                            // fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                            fontSize: 20),
                                      )
                                  ],
                                ),
                              )
                            ],
                            minimum: widget.minGauge,
                            maximum: widget.maxGauge,
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
                    ),
                  );
                } else if (widget.widgetType == 'Input') {
                  return Expanded(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: valCont,
                              // onChanged: (value) {

                              // },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Data Cannot be Empty';
                                }
                                if (widget.dataType == 'Numeric' &&
                                    !RegExp(r'^\d+$').hasMatch(value)) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },

                              inputFormatters: (widget.dataType == 'Numeric' ||
                                      value.runtimeType == int ||
                                      value.runtimeType == double)
                                  ? [FilteringTextInputFormatter.digitsOnly]
                                  : [],
                              keyboardType: widget.dataType == 'Numeric'
                                  ? TextInputType.number
                                  : TextInputType.text,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                prefixIconColor: ColorApp.lapisLazuli,
                                labelStyle: const TextStyle(color: Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1, color: ColorApp.lapisLazuli),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 0.5, color: ColorApp.lapisLazuli),
                                  // borderSide: BorderSide.none,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                disabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedErrorBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                errorBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Data Type : ${widget.dataType}')),
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
                                    // updateInputValue(valCont.text);
                                    if (widget.dataType == 'Numeric') {
                                      // updateInputValue(double.parse(valCont.text));
                                      dbRef.set(double.parse(valCont.text));
                                    } else {
                                      dbRef.set(valCont.text);
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
                    ),
                  );
                } else if (widget.widgetType == 'Switch') {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 40),
                      child: Container(
                          // color: Colors.pink,
                          // height: double.infinity,
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
                    ),
                  );
                } else {
                  return Center(
                    child: Text(value),
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
          )
        ],
      ),
    );
  }
}
