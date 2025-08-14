import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/models/chart_models.dart';
import 'package:ta_web/services/devices_service.dart';
import 'package:ta_web/widgets/chart_card.dart';
import 'package:ta_web/widgets/chart_cardv2.dart';
import 'package:ta_web/widgets/chart_cardv3.dart';
import 'package:ta_web/widgets/createchart_dialog.dart';
import 'package:uuid/uuid.dart';

class DeviceCharts extends StatefulWidget {
  DeviceCharts({super.key, required this.deviceId, required this.valueKeys});

  String deviceId;
  List<String> valueKeys;

  @override
  State<DeviceCharts> createState() => _DeviceChartsState();
}

final supabase = Supabase.instance.client;

class _DeviceChartsState extends State<DeviceCharts> {
  List<DoubleModelChart> dummyChartData = [];

  bool createChartLoading = false;

  bool isChartAvailable = false;

  // List<Map<String, dynamic>> dummyData = [
  //   {
  //     "time": "2024-05-18T21:37:06.168342+00:00",
  //     'value': {
  //       'val1': 12,
  //       'val2': 77,
  //     }
  //   },
  //   {
  //     "time": "2024-05-18T21:04:47.28919+00:00",
  //     'value': {
  //       'val1': 25,
  //       'val2': 105,
  //     }
  //   },
  //   {
  //     "time": "2024-05-18T21:04:47.28919+00:00",
  //     'value': {
  //       'val1': 67,
  //       'val2': 45,
  //     }
  //   },
  //   {
  //     "time": "2024-05-18T20:58:08.237813+00:00",
  //     'value': {
  //       'val1': 56,
  //       'val2': 105,
  //     }
  //   },
  //   {
  //     "time": "2024-05-18T20:20:58.570295+00:00",
  //     'value': {
  //       'val1': 11,
  //       'val2': 105,
  //     }
  //   },
  // ];

  // void setChartData(List<Map<String, dynamic>> param) async {
  //   setState(() {
  //     for (var value in param) {
  //       dummyChartData.add(DoubleModelChart(
  //         DateTime.parse(value['time']),
  //         value['value']['val1'].toDouble(),
  //         value['value']['val2'].toDouble(),
  //       ));
  //     }
  //   });
  //   print(dummyChartData);
  // }

  // List<LineSeries<DoubleModelChart, DateTime>> getDoubleModelChart() {
  //   return <LineSeries<DoubleModelChart, DateTime>>[
  //     LineSeries<DoubleModelChart, DateTime>(
  //       dataSource: dummyChartData,
  //       xValueMapper: (DoubleModelChart xAxisMapper, _) => xAxisMapper.xAxis,
  //       yValueMapper: (DoubleModelChart yAxisMapper, _) => yAxisMapper.y1Axis,
  //       name: 'val1',
  //       markerSettings: const MarkerSettings(isVisible: true),
  //     ),
  //     LineSeries<DoubleModelChart, DateTime>(
  //       dataSource: dummyChartData,
  //       xValueMapper: (DoubleModelChart xAxisMapper, _) => xAxisMapper.xAxis,
  //       yValueMapper: (DoubleModelChart yAxisMapper, _) => yAxisMapper.y2Axis,
  //       name: 'val2',
  //       markerSettings: const MarkerSettings(isVisible: true),
  //     ),
  //   ];
  // }

  Future<void> createNewChart() async {
    // setState(() {
    //   createChartLoading = true;
    // });

    String id = const Uuid().v4();

    try {
      await DevicesService().createNewChart("Live Chart", widget.deviceId, id);
    } catch (e) {
      print(e);
    } finally {
      // widget.onWidgetCreated();
      // setState(() {
      //   createChartLoading = false;
      // });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // setChartData(dummyData);
    // createNewChart();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    dummyChartData.clear();
    super.dispose();
  }

  late Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final sbStream = supabase
        .from('device_log')
        .stream(primaryKey: ['id'])
        .eq('device_id', widget.deviceId)
        .order('created_at', ascending: false)
        .limit(20);

    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseDatabase.instance
            .ref()
            .child('devices/${widget.deviceId}')
            .onValue,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            // var data = snapshot.data.snapshot.value;

            data =
                Map<String, dynamic>.from(snapshot.data.snapshot.value as Map);

            if (!data.containsKey('charts')) {
              // If there are no charts, create a new chart
              createNewChart();
              return const Center(
                child:
                    CircularProgressIndicator(), // Show a loading indicator while creating the chart
              );
            }

            if (!data.containsKey('charts')) {
              // setState(() {
              //   isChartAvailable = true;
              // });
              return const SizedBox();
              // return Center(
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       const Text('No Chart Created'),
              //       const Text('Press this button to create a chart'),
              //       const SizedBox(
              //         height: 10,
              //       ),
              //       SizedBox(
              //         height: 50,
              //         width: 200,
              //         child: ElevatedButton(
              //             onPressed: () {
              //               Get.defaultDialog(
              //                   // barrierDismissible: false,
              //                   title: 'Create New Chart',
              //                   // titleStyle:  TextStyle()
              //                   content: CreateChart(
              //                       deviceID: widget.deviceId,
              //                       keys: widget.valueKeys));
              //             },
              //             style: ElevatedButton.styleFrom(
              //                 backgroundColor: ColorApp.lapisLazuli,
              //                 shape: RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(10))),
              //             child: const Row(
              //               crossAxisAlignment: CrossAxisAlignment.center,
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 Icon(
              //                   Icons.add_rounded,
              //                   color: Colors.white,
              //                   size: 20,
              //                 ),
              //                 Text(
              //                   'Create Chart',
              //                   style: TextStyle(
              //                       color: Colors.white, fontSize: 18),
              //                 )
              //               ],
              //             )),
              //       )
              //     ],
              //   ),
              // );
            } else {
              var deviceCharts = data['charts'];

              List<Map<String, dynamic>> charts = [];

              deviceCharts.forEach((chartID, chartData) {
                charts.add({
                  'id': chartID.toString(),
                  'X-Axis': chartData['X-Axis'].toString(),
                  'title': chartData['title'].toString(),
                });
              });

              print(charts);

              return Padding(
                padding: const EdgeInsets.all(8),
                child: GridView.builder(
                  itemCount: charts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 16 / 5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 20),
                  itemBuilder: (context, index) {
                    var chartData = charts[index];

                    // NewDoubleAxisChartModel chartInfo = NewDoubleAxisChartModel(
                    //     chartId: chartData['id'],
                    //     title: chartData['title'],
                    //     type: chartData['type'],
                    //     selectedYAxis1: chartData['Y-Axis1'],
                    //     selectedYAxis2: chartData['Y-Axis2']);

                    NewDynamicChartModel dynamicChart = NewDynamicChartModel(
                        chartId: chartData['id'].toString(),
                        title: chartData['title'].toString(),
                        // type: chartData['type'],
                        selectedYAxes: widget.valueKeys);

                    // return ChartCard(
                    //   chartInfo: chartInfo,
                    //   xAxis: chartData['X-Axis'],
                    //   deviceID: widget.deviceId,
                    // );
                    // return ChartCardV2(
                    //   chartInfo: chartInfo,
                    //   xAxis: chartData['X-Axis'],
                    //   deviceID: widget.deviceId,
                    // );
                    return ChartCardV3(
                      chartInfo: dynamicChart,
                      xAxis: chartData['X-Axis'].toString(),
                      deviceID: widget.deviceId.toString(),
                      valueKeys: widget.valueKeys,
                    );
                  },
                ),
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

      // body: const SizedBox(),
      // floatingActionButton: SizedBox(
      //   height: 50,
      //   width: 210,
      //   child: ElevatedButton(
      //     onPressed: () => Get.defaultDialog(
      //         title: 'Create New Chart',
      //         content: CreateChart(
      //             deviceID: widget.deviceId, keys: widget.valueKeys)),
      //     style: ElevatedButton.styleFrom(
      //         backgroundColor: ColorApp.lapisLazuli,
      //         shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(10))),
      //     child: const Row(
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         Icon(Icons.add, color: Colors.white),
      //         Text('Create Chart',
      //             style: TextStyle(color: Colors.white, fontSize: 20)),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
