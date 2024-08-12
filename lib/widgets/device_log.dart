import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/widgets/exportlog_dialog.dart';
import 'package:ta_web/widgets/log_tile.dart';

class DeviceLog extends StatefulWidget {
  DeviceLog({super.key, required this.deviceId, required this.keys});

  final String deviceId;
  final List<String> keys;

  @override
  State<DeviceLog> createState() => _DeviceLogState();
}

final supabase = Supabase.instance.client;

class _DeviceLogState extends State<DeviceLog> {
  List<Map<String, dynamic>>? val = [];

  @override
  Widget build(BuildContext context) {
    final sbStream = supabase
        .from('device_log')
        .stream(primaryKey: ['id'])
        .eq('device_id', widget.deviceId)
        .order('created_at', ascending: false)
        .limit(20);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
            stream: sbStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                val = snapshot.data as List<Map<String, dynamic>>?;

                if (val == null) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: ColorApp.lapisLazuli,
                    ),
                  );
                }

                if (val!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Log Found',
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: ColorApp.lapisLazuli,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)),
                            border: const Border.symmetric(
                                horizontal: BorderSide(
                                    width: 1, color: Colors.black45))),
                        child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 50,
                                  width: (Get.width - 16) / 3,
                                  child: const Align(
                                    alignment: Alignment.center,
                                    child: Text("Timestamp",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Nunito")),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  width: (Get.width - 16) / 3,
                                  child: const Align(
                                    alignment: Alignment.center,
                                    child: Text("Device ID",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Nunito")),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  width: (Get.width - 16) / 3,
                                  child: const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Value",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Nunito")),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      Container(
                        height: Get.height - 350,
                        width: double.infinity,
                        child: ListView.builder(
                          itemCount: val!.length,
                          itemBuilder: (context, index) {
                            final log = val![index];

                            return LogTile(
                                timestamp: log['created_at'],
                                deviceId: log['device_id'],
                                value: log['value'].toString());
                          },
                        ),
                      ),
                    ],
                  );
                }
              } else if (snapshot.hasError) {
                return const Center(child: Text('Something Went Wrong'));
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    color: ColorApp.lapisLazuli,
                  ),
                );
              }
            }),
      ),
      floatingActionButton: SizedBox(
        height: 50,
        width: 200,
        child: ElevatedButton(
          onPressed: () {
            Get.to(
                transition: Transition.rightToLeftWithFade,
                ExportLog(
                  deviceID: widget.deviceId,
                  keys: widget.keys,
                ));
          },
          // Get.defaultDialog(title: 'Export Log', content: ExportLog()),
          style: ElevatedButton.styleFrom(
              backgroundColor: ColorApp.lapisLazuli,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Export Log',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
