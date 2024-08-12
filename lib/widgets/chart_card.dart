import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/models/chart_models.dart';
import 'dart:async';

class ChartCard extends StatefulWidget {
  final NewDoubleAxisChartModel chartInfo;
  final String deviceID, xAxis;

  ChartCard({
    Key? key,
    required this.deviceID,
    required this.chartInfo,
    required this.xAxis,
  }) : super(key: key);

  @override
  State<ChartCard> createState() => _ChartCardState();
}

final supabase = Supabase.instance.client;

class _ChartCardState extends State<ChartCard> {
  List<DoubleModelChart> doubleChartData = [];
  List<SingleModelChart> singleChartData = [];
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();

    final sbStream = supabase
        .from('device_log')
        .stream(primaryKey: ['id'])
        .eq('device_id', widget.deviceID)
        .order('created_at', ascending: false)
        .limit(15);

    _subscription = sbStream.listen((value) {
      if (value != null && value.isNotEmpty) {
        setState(() {
          if (widget.chartInfo.type == 'Double Axis') {
            doubleChartData = value.map<DoubleModelChart>((data) {
              return DoubleModelChart(
                DateTime.parse(data['created_at'].toString()),
                data['value'][widget.chartInfo.selectedYAxis1],
                data['value'][widget.chartInfo.selectedYAxis2],
              );
            }).toList();
          } else {
            singleChartData = value.map<SingleModelChart>((data) {
              return SingleModelChart(
                DateTime.parse(data['created_at'].toString()),
                data['value'][widget.chartInfo.selectedYAxis1],
              );
            }).toList();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
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
                    onTap: () {},
                    child: const Icon(
                      Icons.remove_circle,
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                          // minimum: DateTime(
                          //     2024, 05, 15),
                          // maximum: DateTime.now(),
                          interval: 1,
                          majorGridLines: const MajorGridLines(width: 0)),
                      primaryYAxis: const NumericAxis(
                        axisLine: AxisLine(width: 0),
                        majorTickLines:
                            MajorTickLines(color: Colors.transparent),
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
