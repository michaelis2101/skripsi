import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ta_web/classes/colors_cl.dart';

class InfoDialog extends StatefulWidget {
  String widgetId,
      dataKey,
      widgetType,
      deviceID,
      deviceName,
      widgetName,
      dataType;
  double minGauge, maxGauge;
  InfoDialog(
      {super.key,
      required this.widgetId,
      required this.dataKey,
      required this.deviceID,
      required this.widgetType,
      required this.minGauge,
      required this.maxGauge,
      required this.deviceName,
      required this.widgetName,
      required this.dataType});

  @override
  State<InfoDialog> createState() => _InfoDialogState();
}

class _InfoDialogState extends State<InfoDialog> {
  int ts = 0;
  String timestamp = '';
  String deviceName = '';

  bool isLoading = false;
  // var dt = DateTime.fromMillisecondsSinceEpoch();

  void getDeviceName() async {
    setState(() {
      isLoading = true;
    });
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref()
          .child('devices/${widget.deviceID}/deviceName')
          .get();

      setState(() {
        deviceName = snapshot.value.toString();
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void getDeviceLastTS() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref()
          .child('devices/${widget.deviceID}/lastUpdated/timestamp')
          .get();

      var dt = DateTime.fromMillisecondsSinceEpoch(
          int.parse(snapshot.value.toString()));

      setState(() {
        timestamp = DateFormat('MM/dd/yyyy, hh:mm a').format(dt);
      });

      print(snapshot.value);
      print(timestamp);
    } catch (e) {
      print(e);
    } finally {
      isLoading = false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceLastTS();
    getDeviceName();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: ColorApp.lapisLazuli,
            ),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Id : ${widget.widgetId}'),
              Text('Name : ${widget.widgetName}'),
              Text('Type : ${widget.widgetType}'),
              Text('Data Key : ${widget.dataKey}'),
              Text('Device Id : ${widget.deviceID}'),
              Text('Device Name : $deviceName'),
              Text('Last Data Received : $timestamp'),
              Text('Data Type : ${widget.dataType}'),
              Text('Min Value : ${widget.minGauge}'),
              Text('Max Value : ${widget.maxGauge}'),
            ],
          );
  }
}
