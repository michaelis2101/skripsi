import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/models/chart_models.dart';

import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ExportLog extends StatefulWidget {
  String deviceID;
  List<String> keys;

  ExportLog({super.key, required this.deviceID, required this.keys});

  @override
  State<ExportLog> createState() => _ExportLogState();
}

class _ExportLogState extends State<ExportLog> {
  final titleCont = TextEditingController();
  final supabase = Supabase.instance.client;
  late GlobalKey<SfCartesianChartState> _cartesianChartKey;
  List<DynamicModelChart> chartData = [];
  Uint8List? bytes;

  DateTime _startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  bool isLoading = false;
  bool isGenerateChart = true;

  List<Map<String, dynamic>> deviceLogs = [];

  List<String> selectedKeys = [];

  TimeOfDay startTime = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay endTime = TimeOfDay(hour: 23, minute: 59);

  Future<List<Map<String, dynamic>>> fetchDeviceLogs(
      DateTime startDateTime, DateTime endDateTime) async {
    try {
      final response = await supabase
          .from('device_log')
          .select()
          .eq('device_id', widget.deviceID)
          .gte('created_at', startDateTime.toIso8601String())
          .lte('created_at', endDateTime.toIso8601String());

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
      print(picked.toIso8601String());
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? startTime : endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          setState(() {
            startTime = picked;
          });
        } else {
          setState(() {
            endTime = picked;
          });
        }
      });
    }
  }

  Future<void> fetchLogs() async {
    setState(() {
      isLoading = true;
    });

    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      startTime.hour,
      startTime.minute,
    );

    final endDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      endTime.hour,
      endTime.minute,
    );

    final logs = await fetchDeviceLogs(startDateTime, endDateTime);
    setState(() {
      deviceLogs = logs;
      isLoading = false;
    });
  }

  Future<void> generateChart(List<Map<String, dynamic>> log) async {
    if (log.isNotEmpty && log != null) {
      setState(() {
        chartData = log.map<DynamicModelChart>((data) {
          Map<String, double> yAxes = {};

          for (var key in widget.keys) {
            yAxes[key] = data['value'][key];
            // yAxes[key] = data['value'][key];
          }

          return DynamicModelChart(
              DateTime.parse(data['created_at'].toString()).toUtc(), yAxes);
        }).toList();
      });
    }
  }

  List<LineSeries<DynamicModelChart, DateTime>> getChartSeries(
      List<DynamicModelChart> data) {
    return selectedKeys.map((key) {
      return LineSeries<DynamicModelChart, DateTime>(
        dataSource: data,
        xValueMapper: (DynamicModelChart chart, _) => chart.xAxis,
        yValueMapper: (DynamicModelChart chart, _) => chart.yAxes[key],
        name: key,
        markerSettings: const MarkerSettings(isVisible: true),
      );
    }).toList();
  }

  @override
  void dispose() {
    chartData.clear();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    _cartesianChartKey = GlobalKey();
    super.initState();
  }

  Future<void> _renderChartAsImage() async {
    // Capture the chart as an image with a specified pixel ratio
    final double pixelRatio = ui.window.devicePixelRatio;
    final ui.Image? data =
        await _cartesianChartKey.currentState!.toImage(pixelRatio: pixelRatio);

    // Convert the captured image to ByteData in PNG format
    final ByteData? bytes =
        await data!.toByteData(format: ui.ImageByteFormat.png);

    if (bytes != null) {
      // Convert ByteData to Uint8List
      final Uint8List imageBytes =
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

      // Create a Blob from the image bytes
      final html.Blob blob = html.Blob([imageBytes]);

      // Create an object URL for the blob
      final String url = html.Url.createObjectUrlFromBlob(blob);

      // Create a link element
      final html.AnchorElement anchor = html.AnchorElement(href: url)
        ..setAttribute("download",
            "${titleCont.text.isEmpty ? widget.deviceID : titleCont.text}.png")
        ..click();

      // Revoke the object URL to free up memory
      html.Url.revokeObjectUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorApp.lapisLazuli,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        automaticallyImplyLeading: false,
        title: const Text(
          'Export Log',
          style: TextStyle(
              fontFamily: "Nunito", fontSize: 30, color: Colors.white),
        ),
      ),
      body: Container(
        height: Get.height,
        width: Get.width,
        child: Row(
          children: [
            Container(
              height: Get.height,
              width: Get.width * 0.4,
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(width: 1, color: ColorApp.lapisLazuli)),
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Title",
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
                    ),
                    SizedBox(
                      // height: Get.width * 0.2,
                      width: double.infinity,
                      child: TextField(
                          controller: titleCont,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            prefixIconColor: ColorApp.lapisLazuli,
                            labelStyle: const TextStyle(color: Colors.grey),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 1, color: ColorApp.lapisLazuli),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 1, color: ColorApp.lapisLazuli),
                              // borderSide: BorderSide.none,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                            disabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            // hintText: 'Pin Title',
                          )),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Select Date",
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
                    ),
                    InkWell(
                      onTap: () => _selectStartDate(context),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 1, color: ColorApp.lapisLazuli)),
                        width: double.infinity,
                        height: 50,
                        child: Center(
                            child: Text(
                          DateFormat('dd MMMM yyyy').format(_startDate),
                          style: const TextStyle(
                              // color: Colors.white,
                              fontSize: 20),
                        )),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Start",
                              style:
                                  TextStyle(fontFamily: 'Nunito', fontSize: 16),
                            ),
                            InkWell(
                              onTap: () {
                                _selectTime(context, true);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        width: 1, color: ColorApp.lapisLazuli)),
                                width: 100,
                                height: 50,
                                child: Center(
                                    child: Text(
                                  startTime.format(context),
                                  style: const TextStyle(
                                      // color: Colors.white,
                                      fontSize: 20),
                                )),
                              ),
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "End",
                              style:
                                  TextStyle(fontFamily: 'Nunito', fontSize: 16),
                            ),
                            InkWell(
                              onTap: () {
                                _selectTime(context, false);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        width: 1, color: ColorApp.lapisLazuli)),
                                width: 100,
                                height: 50,
                                child: Center(
                                    child: Text(
                                  endTime.format(context),
                                  style: const TextStyle(
                                      // color: Colors.white,
                                      fontSize: 20),
                                )),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: Text(
                          'Select Keys',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        items: widget.keys.map((item) {
                          return DropdownMenuItem(
                              value: item,
                              enabled: false,
                              child: StatefulBuilder(
                                builder: (context, menuSetState) {
                                  final isSelected =
                                      selectedKeys.contains(item);
                                  return InkWell(
                                    onTap: () {
                                      isSelected
                                          ? selectedKeys.remove(item)
                                          : selectedKeys.add(item);
                                      setState(() {});
                                      menuSetState(() {});
                                    },
                                    child: Container(
                                      height: double.infinity,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        children: [
                                          if (isSelected)
                                            const Icon(
                                                Icons.check_box_outlined),
                                          if (!isSelected)
                                            const Icon(
                                                Icons.check_box_outline_blank),
                                          const SizedBox(
                                            width: 16,
                                          ),
                                          Expanded(
                                              child: Text(
                                            item,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          )),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ));
                        }).toList(),
                        value: selectedKeys.isEmpty ? null : selectedKeys[0],
                        onChanged: (value) {},
                        selectedItemBuilder: (context) {
                          return widget.keys.map(
                            (item) {
                              return Container(
                                alignment: AlignmentDirectional.center,
                                child: Text(
                                  selectedKeys.join(', '),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                ),
                              );
                            },
                          ).toList();
                        },
                        buttonStyleData: ButtonStyleData(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1, color: ColorApp.lapisLazuli),
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            )),
                        iconStyleData: IconStyleData(
                            icon: const Icon(
                                Icons.arrow_drop_down_circle_outlined),
                            iconSize: 14,
                            iconEnabledColor: ColorApp.lapisLazuli),
                        dropdownStyleData: DropdownStyleData(
                            // maxHeight: 50,
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(10))),
                            width: (Get.width * 0.4) - 16,
                            // width: MediaQuery.of(context).size.width * 0.29,
                            padding: const EdgeInsets.all(8)),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                          padding: EdgeInsets.zero,
                        ),
                      )),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (isLoading)
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: Center(
                          child: LinearProgressIndicator(
                            color: ColorApp.lapisLazuli,
                          ),
                        ),
                      ),
                    if (!isLoading)
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: ColorApp.lapisLazuli,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            onPressed: () async {
                              await fetchLogs();
                              print(deviceLogs);

                              if (deviceLogs.isNotEmpty) {
                                try {
                                  generateChart(deviceLogs);
                                } catch (e) {
                                  print(e);
                                }
                              } else {
                                Get.defaultDialog(
                                    title: 'Error',
                                    middleTextStyle:
                                        const TextStyle(fontSize: 15),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 10),
                                    content: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.disabled_by_default_outlined,
                                          size: 55,
                                        ),
                                        Text(
                                          'Log Not Found, Chart Cannot be Generated',
                                          style: TextStyle(fontSize: 15),
                                        )
                                      ],
                                    ),
                                    // onConfirm: () {
                                    //   Get.back();
                                    // },
                                    confirm: SizedBox(
                                      height: 40,
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
                                            'Ok',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          )),
                                    ));
                              }
                            },
                            child: const Text(
                              'Generate',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            )),
                      )
                  ],
                ),
              ),
            ),
            // if (chartData.isNotEmpty || chartData != null)
            Container(
              height: Get.height,
              width: Get.width * 0.6,
              decoration: BoxDecoration(color: Colors.white),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // if (chartData.isEmpty) const Text('asdasdkjas'),
                    if (chartData.isNotEmpty || chartData != null)
                      SizedBox(
                        height: Get.height * 0.4,
                        width: Get.width * 0.5,
                        child: SfCartesianChart(
                          borderWidth: 1,
                          borderColor: Colors.black,
                          key: _cartesianChartKey,
                          enableAxisAnimation: false,
                          zoomPanBehavior:
                              ZoomPanBehavior(zoomMode: ZoomMode.xy),
                          plotAreaBorderWidth: 1,
                          title: ChartTitle(text: titleCont.text),
                          legend: const Legend(isVisible: true),
                          series: getChartSeries(chartData),

                          // primaryXAxis: NumericAxis(
                          //   edgeLabelPlacement: EdgeLabelPlacement.shift,
                          // ),
                          primaryXAxis: DateTimeAxis(
                              edgeLabelPlacement: EdgeLabelPlacement.shift,
                              dateFormat: DateFormat.Hms(),

                              // dateFormat: DateFormat.Hms(),
                              // axisLabelFormatter: (axisLabelRenderArgs) {
                              intervalType: DateTimeIntervalType.auto,

                              // desiredIntervals: toInt(10),
                              enableAutoIntervalOnZooming: true,
                              // initialZoomFactor: 1,
                              axisLabelFormatter: (axisLabelRenderArgs) {
                                final DateTime dateTime =
                                    DateTime.fromMillisecondsSinceEpoch(
                                            axisLabelRenderArgs.value.toInt())
                                        .toUtc();
                                final String formattedLabel =
                                    DateFormat.Hms().format(dateTime);
                                return ChartAxisLabel(
                                    formattedLabel, TextStyle());
                              },
                              desiredIntervals: 10,
                              isVisible: true,
                              // interval: 1,
                              majorGridLines: const MajorGridLines(width: 0)),
                          primaryYAxis: const NumericAxis(
                            axisLine: AxisLine(width: 0),
                            majorTickLines:
                                MajorTickLines(color: Colors.transparent),
                          ),
                          tooltipBehavior: TooltipBehavior(enable: true),
                        ),
                      ),

                    const SizedBox(
                      height: 10,
                    ),

                    SizedBox(
                      height: 50,
                      width: Get.width * 0.5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: (Get.width * 0.4) - 5,
                            height: double.infinity,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorApp.lapisLazuli,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                onPressed: () async {
                                  try {
                                    await _renderChartAsImage();
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                                child: const Text(
                                  'Save',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                )),
                          ),
                          SizedBox(
                            width: (Get.width * 0.1) - 5,
                            height: double.infinity,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorApp.lapisLazuli,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                onPressed: () {
                                  setState(() {
                                    chartData.clear();
                                    selectedKeys.clear();
                                    titleCont.clear();
                                  });
                                },
                                child: const Icon(
                                  Icons.settings_backup_restore,
                                  color: Colors.white,
                                )),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
