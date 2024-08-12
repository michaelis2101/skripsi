import 'package:get/get.dart';
import 'package:ta_web/models/datastream_model.dart';

class NewDiviceCont extends GetxController {
  RxString widgetP1 = '-'.obs;
  RxString widgetP2 = '-'.obs;
  RxString widgetP3 = '-'.obs;
  RxString widgetP4 = '-'.obs;
  RxString widgetP5 = '-'.obs;

  RxString titleP1 = '-'.obs;
  RxString titleP2 = '-'.obs;
  RxString titleP3 = '-'.obs;
  RxString titleP4 = '-'.obs;
  RxString titleP5 = '-'.obs;

  RxDouble minGaugeVal1 = 0.0.obs;
  RxDouble maxGaugeVal1 = 100.0.obs;

  RxDouble minGaugeVal2 = 0.0.obs;
  RxDouble maxGaugeVal2 = 100.0.obs;

  RxDouble minGaugeVal3 = 0.0.obs;
  RxDouble maxGaugeVal3 = 100.0.obs;

  RxDouble minGaugeVal4 = 0.0.obs;
  RxDouble maxGaugeVal4 = 100.0.obs;

  RxDouble minGaugeVal5 = 0.0.obs;
  RxDouble maxGaugeVal5 = 100.0.obs;

  RxList<DataStream> dataStreams = <DataStream>[].obs;

  void addDataStream(DataStream dataStream) {
    dataStreams.add(dataStream);
  }

  void removeDataStream(int index) {
    dataStreams.removeAt(index);
  }

  //fungsi buat P1

  void updateP1Info(String title, String widget) {
    titleP1.value = title;
    widgetP1.value = widget;
  }

  void removeP1Data() {
    titleP1.value = '-';
    widgetP1.value = '-';
  }

  void updateGaugeVal1(double min, max) {
    minGaugeVal1.value = min;
    maxGaugeVal1.value = max;
  }

  //fungsi buat P2
  void updateP2Info(String title, String widget) {
    titleP2.value = title;
    widgetP2.value = widget;
  }

  void removeP2Data() {
    titleP2.value = '-';
    widgetP2.value = '-';
  }

  void updateGaugeVal2(double min, max) {
    minGaugeVal2.value = min;
    maxGaugeVal2.value = max;
  }

//fungsi buat P3
  void updateP3Info(String title, String widget) {
    titleP3.value = title;
    widgetP3.value = widget;
  }

  void removeP3Data() {
    titleP3.value = '-';
    widgetP3.value = '-';
  }

  void updateGaugeVal3(double min, max) {
    minGaugeVal3.value = min;
    maxGaugeVal3.value = max;
  }

  //fungsi buat P4
  void updateP4Info(String title, String widget) {
    titleP4.value = title;
    widgetP4.value = widget;
  }

  void removeP4Data() {
    titleP4.value = '-';
    widgetP4.value = '-';
  }

  void updateGaugeVal4(double min, max) {
    minGaugeVal4.value = min;
    maxGaugeVal4.value = max;
  }

  //fungsi buat P5
  void updateP5Info(String title, String widget) {
    titleP5.value = title;
    widgetP5.value = widget;
  }

  void removeP5Data() {
    titleP5.value = '-';
    widgetP5.value = '-';
  }

  void updateGaugeVal5(double min, max) {
    minGaugeVal5.value = min;
    maxGaugeVal5.value = max;
  }
}
