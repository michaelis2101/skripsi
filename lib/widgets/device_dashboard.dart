import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/widgets/createwidget_dialog.dart';
import 'package:ta_web/widgets/widget_card.dart';

class DeviceDashboard extends StatefulWidget {
  String deviceID, deviceName;
  List<String> valueKeys;

  DeviceDashboard(
      {super.key,
      required this.deviceID,
      required this.valueKeys,
      required this.deviceName});

  @override
  State<DeviceDashboard> createState() => _DeviceDashboardState();
}

class _DeviceDashboardState extends State<DeviceDashboard> {
  bool isValued = true;

  DateTime? _requestStartTime;
  List<int> _latencies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseDatabase.instance
            .ref()
            .child('devices/${widget.deviceID}')
            .onValue,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data.snapshot.value;

            if (data == null) {
              return const SizedBox(
                // height: Get.height,
                // width: Get.width,
                child: Center(
                  child: Text('No Data Found'),
                ),
              );
            }

            if (data == null || !data.containsKey('widgets')) {
              isValued = false;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('No Widget Created'),
                    const Text('Press this button to create a widget'),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 50,
                      width: 200,
                      child: ElevatedButton(
                          onPressed: () {
                            Get.defaultDialog(
                                // barrierDismissible: false,
                                title: 'Create Widget',
                                // titleStyle:  TextStyle()
                                content: CreateWidget(
                                  keys: widget.valueKeys,
                                  deviceID: widget.deviceID,
                                  onWidgetCreated: () {
                                    setState(() {
                                      isValued = true;
                                    });
                                  },
                                ));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: ColorApp.lapisLazuli,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              Text(
                                'Create Widget',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              )
                            ],
                          )),
                    )
                  ],
                ),
              );
            }
            // return SizedBox();
            else {
              var deviceWidgets = data['widgets'];

              List<Map<String, dynamic>> widgets = [];

              deviceWidgets.forEach((widgetID, widgetData) {
                widgets.add({
                  'id': widgetID,
                  'widgetName': widgetData['widgetName'],
                  'key': widgetData['key'],
                  'type': widgetData['type'],
                  'minValue': widgetData['minValue'],
                  'maxValue': widgetData['maxValue'],
                  'unit': widgetData['unit']
                });
              });

              if (widgets.isNotEmpty) {
                isValued = true;
              }

              // print(widgets);

              // return Center(child: Text('Widget'));
              return Padding(
                padding: const EdgeInsets.all(8),
                child: GridView.builder(
                    itemCount: widgets.length,
                    scrollDirection: Axis.horizontal,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 5 / 8,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 20),
                    itemBuilder: (context, index) {
                      var widgetData = widgets[index];

                      // print(widgetData);

                      return WidgetCard(
                        id: widgetData['id'],
                        dataKey: widgetData['key'],
                        widgetType: widgetData['type'],
                        minGauge: widgetData['minValue'],
                        maxGauge: widgetData['maxValue'],
                        deviceId: widget.deviceID,
                        deviceName: widget.deviceName,
                        widgetName: widgetData['widgetName'],
                        dataType: widgetData['dataType'] == null
                            ? 'Numeric'
                            : widgetData['dataType'],
                        unit: widgetData['unit'] ?? '',
                      );
                    }),
              );
            }
            // isValued = true;

            // return
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: ColorApp.lapisLazuli,
              ),
            );
          }
        },
      ),
      floatingActionButton: !isValued
          ? const SizedBox()
          : SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(
                onPressed: () => Get.defaultDialog(
                    // barrierDismissible: false,
                    title: 'Create Widget',
                    // titleStyle:  TextStyle()
                    content: CreateWidget(
                      keys: widget.valueKeys,
                      deviceID: widget.deviceID,
                      onWidgetCreated: () {
                        setState(() {
                          isValued = true;
                        });
                      },
                    )),
                style: ElevatedButton.styleFrom(
                    backgroundColor: ColorApp.lapisLazuli,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    Text('Add Widget',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  ],
                ),
              ),
            ),
    );
  }
}
