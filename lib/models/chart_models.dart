// class _ChartData {
//   _ChartData(this.x, this.y, this.y2);
//   final double x;
//   final double y;
//   final double y2;
// }

class NewDoubleAxisChartModel {
  String chartId, title, type, selectedYAxis1, selectedYAxis2;

  NewDoubleAxisChartModel(
      {required this.chartId,
      required this.title,
      required this.type,
      required this.selectedYAxis1,
      required this.selectedYAxis2});
}
// class NewDoubleAxisChartModel {
//   String chartId, title, selectedYAxis1, selectedYAxis2;

//   NewDoubleAxisChartModel(
//        this.chartId, this.title, this.selectedYAxis1, this.selectedYAxis2);
// }

class SingleModelChart {
  DateTime xAxis;
  double yAxis;
  SingleModelChart(this.xAxis, this.yAxis);
}

class DoubleModelChart {
  DateTime xAxis;
  double y1Axis;
  double y2Axis;
  DoubleModelChart(this.xAxis, this.y1Axis, this.y2Axis);
}

// class NewDynamicChartModel {
//   String chartId, title, type;
//   List<String> selectedYAxes;

//   NewDynamicChartModel({
//     required this.chartId,
//     required this.title,
//     required this.type,
//     required this.selectedYAxes,
//   });
// }

class NewDynamicChartModel {
  String chartId, title;
  List<String> selectedYAxes;

  NewDynamicChartModel({
    required this.chartId,
    required this.title,
    required this.selectedYAxes,
  });
}

class DynamicModelChart {
  DateTime xAxis;
  Map<String, double> yAxes;

  DynamicModelChart(this.xAxis, this.yAxes);
}


// class DoubleModelChart {
//   double xAxis;
//   double y1Axis;
//   double y2Axis;

//   DoubleModelChart(DateTime time, this.y1Axis, this.y2Axis)
//       : xAxis = time.millisecondsSinceEpoch.toDouble();

//   @override
//   String toString() {
//     return 'DoubleModelChart(xAxis: $xAxis, y1Axis: $y1Axis, y2Axis: $y2Axis)';
//   }
// }
