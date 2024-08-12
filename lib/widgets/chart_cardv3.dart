import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/models/chart_models.dart';
import 'dart:async';

import 'package:ta_web/widgets/exportlog_dialog.dart';

class ChartCardV3 extends StatefulWidget {
  final NewDynamicChartModel chartInfo;
  final String deviceID, xAxis;
  final List<String> valueKeys;

  const ChartCardV3({
    Key? key,
    required this.deviceID,
    required this.chartInfo,
    required this.xAxis,
    required this.valueKeys,
  }) : super(key: key);

  @override
  State<ChartCardV3> createState() => _ChartCardState();
}

final supabase = Supabase.instance.client;

class _ChartCardState extends State<ChartCardV3> {
  List<DynamicModelChart> chartData = [];
  List<String> timeStamp = [];
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();

    final sbStream = supabase
        .from('device_log')
        .stream(primaryKey: ['id'])
        .eq('device_id', widget.deviceID)
        .order('created_at', ascending: false)
        .limit(10);

    _subscription = sbStream.listen((value) {
      if (value != null && value.isNotEmpty) {
        setState(() {
          chartData = value.map<DynamicModelChart>((data) {
            Map<String, double> yAxes = {};
            for (var key in widget.chartInfo.selectedYAxes) {
              yAxes[key] = data['value'][key];
              // timeStamp = data['created_at'];
            }
            // print(data['created_at']);
            // print(DateTime.parse(data['created_at'].toString()));

            return DynamicModelChart(
              DateTime.parse(data['created_at'].toString()).toUtc(),
              yAxes,
            );
          }).toList();

          // chartInfo = value.map((data) {

          // } )
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  List<LineSeries<DynamicModelChart, DateTime>> getChartSeries(
      List<DynamicModelChart> data) {
    return widget.chartInfo.selectedYAxes.map((key) {
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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
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
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Get.to(ExportLog(
                          deviceID: widget.deviceID, keys: widget.valueKeys));
                    },
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.upload,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Export',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (chartData.isEmpty || chartData.length == 0)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: ColorApp.lapisLazuli,
                    ),
                    const Text(
                      'Gathering Value',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SfCartesianChart(
                  enableAxisAnimation: false,
                  zoomPanBehavior: ZoomPanBehavior(zoomMode: ZoomMode.xy),
                  plotAreaBorderWidth: 1,
                  title: ChartTitle(text: widget.chartInfo.title.toString()),
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
                        return ChartAxisLabel(formattedLabel, TextStyle());
                      },
                      desiredIntervals: 10,
                      isVisible: true,
                      // interval: 1,
                      majorGridLines: const MajorGridLines(width: 0)),
                  primaryYAxis: const NumericAxis(
                    axisLine: AxisLine(width: 0),
                    majorTickLines: MajorTickLines(color: Colors.transparent),
                  ),
                  tooltipBehavior: TooltipBehavior(enable: true),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
