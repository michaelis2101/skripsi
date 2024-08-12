import 'package:flutter/material.dart';
import 'package:ta_web/widgets/gauge_preview.dart';
import 'package:ta_web/widgets/lkv_preview.dart';
import 'package:ta_web/widgets/switch_preview.dart';

class WidgetPreview extends StatefulWidget {
  String widgetType, title;
  double minVal, maxVal;

  WidgetPreview(
      {super.key,
      required this.widgetType,
      required this.minVal,
      required this.maxVal,
      required this.title});

  @override
  State<WidgetPreview> createState() => _WidgetPreviewState();
}

class _WidgetPreviewState extends State<WidgetPreview> {
  double previewHeight = 300;
  double previewWidth = 400;

  @override
  Widget build(BuildContext context) {
    if (widget.widgetType == 'String') {
      return Container(

          // height: MediaQuery.of(context).size.height * ,
          height: previewHeight,
          width: previewWidth,
          decoration: BoxDecoration(boxShadow: const [
            BoxShadow(offset: Offset(3, 3), blurRadius: 11)
          ], color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: LKVPreview(title: widget.title));
    }

    if (widget.widgetType == 'Gauge') {
      return Container(
          // height: MediaQuery.of(context).size.height * ,
          height: previewHeight,
          width: previewWidth,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(offset: Offset(3, 3), blurRadius: 11)
              ]),
          child: Center(
            child: GaugePreview(
              title: widget.title,
              minVal: widget.minVal,
              maxVal: widget.maxVal,
            ),
          ));
    }

    if (widget.widgetType == 'Button') {
      return Container(
          // height: MediaQuery.of(context).size.height * ,
          height: previewHeight,
          width: previewWidth,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: const Center(
            child: Text('Button'),
          ));
    }

    // if (widget.widgetType == 'Button') {
    //   return Container(
    //       // height: MediaQuery.of(context).size.height * ,
    //       height: previewHeight,
    //       width: previewWidth,
    //       decoration: const BoxDecoration(color: Colors.white),
    //       child: const Center(
    //         child: Text('Button'),
    //       ));
    // }

    if (widget.widgetType == 'Switch') {
      return Container(
          // height: MediaQuery.of(context).size.height * ,
          height: previewHeight,
          width: previewWidth,
          decoration: BoxDecoration(boxShadow: const [
            BoxShadow(offset: Offset(3, 3), blurRadius: 11)
          ], color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: SwitchPreview(title: widget.title),
          ));
    }

    if (widget.widgetType == 'Chart') {
      return Container(
          // height: MediaQuery.of(context).size.height * ,
          height: previewHeight,
          width: previewWidth,
          decoration: const BoxDecoration(color: Colors.white),
          child: const Center(
            child: Text('Chart'),
          ));
    } else {
      return const SizedBox();
    }
  }
}
