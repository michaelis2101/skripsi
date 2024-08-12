import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:ta_web/classes/colors_cl.dart';

class GaugePreview extends StatefulWidget {
  double minVal, maxVal;
  String title;

  GaugePreview(
      {super.key,
      required this.minVal,
      required this.maxVal,
      required this.title});

  @override
  State<GaugePreview> createState() => _GaugePreviewState();
}

class _GaugePreviewState extends State<GaugePreview> {
  @override
  Widget build(BuildContext context) {
    double annotation =
        double.parse(double.parse('${widget.maxVal / 1.5}').toStringAsFixed(1));

    return SfRadialGauge(
      title: GaugeTitle(
          text: widget.title,
          textStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 25)),
      enableLoadingAnimation: true,
      axes: <RadialAxis>[
        RadialAxis(
          annotations: [
            GaugeAnnotation(
                widget: Text(
              annotation.toString(),
              style: const TextStyle(fontSize: 60, fontFamily: 'Nunito'),
            ))
          ],
          minimum: widget.minVal,
          maximum: widget.maxVal,
          pointers: <GaugePointer>[
            // MarkerPointer(
            //   value: 120,
            //   enableAnimation: true,
            //   color: ColorApp.lapisLazuli,
            // )
            RangePointer(
              value: widget.maxVal / 1.5,
              enableAnimation: true,
              color: ColorApp.lapisLazuli,
            ),
          ],
        ),
      ],
    );
  }
}
