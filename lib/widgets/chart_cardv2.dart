import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/models/chart_models.dart';

class ChartCardV2 extends StatefulWidget {
  final NewDoubleAxisChartModel chartInfo;
  final String deviceID, xAxis;

  ChartCardV2({
    Key? key,
    required this.deviceID,
    required this.chartInfo,
    required this.xAxis,
  }) : super(key: key);

  @override
  State<ChartCardV2> createState() => _ChartCardState();
}

final supabase = Supabase.instance.client;

class _ChartCardState extends State<ChartCardV2> {
  List<DoubleModelChart> doubleChartData = [];
  List<SingleModelChart> singleChartData = [];
  bool isLoading = false;

  Future getListData() async {
    PostgrestList chartData = await Isolate.run(() {
      var data = supabase
          .from('device_log')
          .select()
          .eq('device_id', widget.deviceID)
          .order('created_at', ascending: false)
          .limit(10);

      return data;
    });

    return chartData;
  }

  Future<void> getChartData(String deviceID) async {
    setState(() {
      isLoading = true;
    });
    try {
      PostgrestList chartData = await supabase
          .from('device_log')
          .select()
          .eq('device_id', widget.deviceID)
          .order('created_at', ascending: false)
          .limit(10);

      // PostgrestList chartData = await getListData();

      print(' CHART DATA ========================= $chartData');

      if (widget.chartInfo.type == 'Double Axis') {
        for (var element in chartData) {
          doubleChartData.add(DoubleModelChart(
              DateTime.parse(element['created_at'].toString()),
              element['value'][widget.chartInfo.selectedYAxis1],
              element['value'][widget.chartInfo.selectedYAxis2]));
        }
        print(chartData[0]['created_at']);
        // await Isolate.run(() {
        //   for (var element in chartData) {
        //     doubleChartData.add(DoubleModelChart(
        //         DateTime.parse(element['created_at']),
        //         element['value'][widget.chartInfo.selectedYAxis1],
        //         element['value'][widget.chartInfo.selectedYAxis2]));
        //   }
        // });
      } else {
        for (var element in chartData) {
          singleChartData.add(SingleModelChart(
            DateTime.parse(element['created_at'].toString()),
            element['value'][widget.chartInfo.selectedYAxis1],
          ));
        }
        print(chartData[0]['created_at']);
        // await Isolate.run(() {
        //   for (var element in chartData) {
        //     singleChartData.add(SingleModelChart(
        //       DateTime.parse(element['created_at']),
        //       element['value'][widget.chartInfo.selectedYAxis1],
        //     ));
        //   }
        // });
      }
      print(
          "Data fetched successfully. Double Chart Data: $doubleChartData, Single Chart Data: $singleChartData");
    } catch (e) {
      print("Error fetching data: $e");
      rethrow;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getChartData(widget.deviceID);
  }

  @override
  void dispose() {
    singleChartData.clear();
    doubleChartData.clear();
    super.dispose();
  }

  List<LineSeries<SingleModelChart, DateTime>> getSingleModelChart(
      List<SingleModelChart> paramSingle) {
    return <LineSeries<SingleModelChart, DateTime>>[
      LineSeries<SingleModelChart, DateTime>(
        dataSource: paramSingle,
        xValueMapper: (SingleModelChart xAxisMapper, _) => xAxisMapper.xAxis,
        yValueMapper: (SingleModelChart yAxisMapper, _) => yAxisMapper.yAxis,
        name: widget.chartInfo.selectedYAxis1,
        markerSettings: const MarkerSettings(isVisible: true),
      ),
    ];
  }

  List<LineSeries<DoubleModelChart, DateTime>> getDoubleModelChart(
      List<DoubleModelChart> paramDouble) {
    return <LineSeries<DoubleModelChart, DateTime>>[
      LineSeries<DoubleModelChart, DateTime>(
        dataSource: paramDouble,
        xValueMapper: (DoubleModelChart xAxisMapper, _) => xAxisMapper.xAxis,
        yValueMapper: (DoubleModelChart yAxisMapper, _) => yAxisMapper.y1Axis,
        name: widget.chartInfo.selectedYAxis1,
        markerSettings: const MarkerSettings(isVisible: true),
      ),
      LineSeries<DoubleModelChart, DateTime>(
        dataSource: paramDouble,
        xValueMapper: (DoubleModelChart xAxisMapper, _) => xAxisMapper.xAxis,
        yValueMapper: (DoubleModelChart yAxisMapper, _) => yAxisMapper.y2Axis,
        name: widget.chartInfo.selectedYAxis2,
        markerSettings: const MarkerSettings(isVisible: true),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 1, color: ColorApp.lapisLazuli)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Container(
                    color: ColorApp.lapisLazuli,
                    height: 30,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {},
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                doubleChartData.isEmpty && singleChartData.isEmpty
                    ? const Center(
                        child: Text(
                          'No Log Found',
                          style: TextStyle(fontSize: 20),
                        ),
                      )
                    : Expanded(
                        child: SfCartesianChart(
                          enableAxisAnimation: false,
                          plotAreaBorderWidth: 1,
                          title: ChartTitle(text: widget.chartInfo.title),
                          legend: const Legend(isVisible: true),
                          series: widget.chartInfo.type == 'Double Axis'
                              ? getDoubleModelChart(doubleChartData)
                              : getSingleModelChart(singleChartData),
                          primaryXAxis: const DateTimeAxis(
                            isVisible: false,
                            interval: 1,
                            majorGridLines: MajorGridLines(width: 0),
                          ),
                          primaryYAxis: const NumericAxis(
                            axisLine: AxisLine(width: 0),
                            majorTickLines:
                                MajorTickLines(color: Colors.transparent),
                          ),
                          tooltipBehavior: TooltipBehavior(enable: true),
                        ),
                      ),
              ],
            ),
          );
  }
}
