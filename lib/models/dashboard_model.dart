class DashboardModel {
  String deviceID, widgetName, widgetType, widgetID, dataKey;

  double minVal, maxVal;

  DashboardModel(
      {required this.deviceID,
      required this.widgetName,
      required this.dataKey,
      required this.widgetType,
      required this.widgetID,
      required this.minVal,
      required this.maxVal});
}
