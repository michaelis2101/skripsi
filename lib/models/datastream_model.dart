class DataStream {
  String pinTitle;
  String virtualPin;
  // String functionality;
  String selectedWidget;
  double minGaugeVal, maxGaugeVal;

  DataStream({
    required this.pinTitle,
    required this.virtualPin,
    // required this.functionality,
    required this.selectedWidget,
    required this.minGaugeVal,
    required this.maxGaugeVal,
  });

  Map<String, dynamic> toJson() {
    return {
      'pinName': pinTitle,
      'virtualPin': virtualPin,
      // 'functionality': functionality,
      'selectedWidget': selectedWidget,
    };
  }

  factory DataStream.fromJson(Map<String, dynamic> json) {
    return DataStream(
      pinTitle: json['pinTitle'],
      virtualPin: json['virtualPin'],
      // functionality: json['functionality'],
      selectedWidget: json['selectedWidget'],
      minGaugeVal: json['minGaugeVal'],
      maxGaugeVal: json['maxGaugeVal'],
    );
  }
}
