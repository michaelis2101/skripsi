import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:timezone/browser.dart' as tz;

class LogTile extends StatelessWidget {
  String deviceId, value, timestamp;
  // int timestamp;
  LogTile({
    Key? key,
    required this.timestamp,
    required this.deviceId,
    required this.value,
  }) : super(key: key);

  // Future<String> formatTimestampToLocal(
  //     BuildContext context, int timestampInMilliseconds) async {
  //   await tz.initializeTimeZone();

  //   final dateTime =
  //       DateTime.fromMillisecondsSinceEpoch(timestampInMilliseconds);

  //   // Get the GMT+7 time zone
  //   final gmt7TimeZone = tz.getLocation('Asia/Bangkok');

  //   // Convert timestamp to GMT+7 timezone
  //   final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss')
  //       .format(tz.TZDateTime.from(dateTime, gmt7TimeZone));

  //   return formattedDate;
  // }
  // Future<String> formatTimestampToLocal(int timestampInMilliseconds) async {
  //   try {
  //     await tz.initializeTimeZone();

  //     final dateTime =
  //         DateTime.fromMillisecondsSinceEpoch(timestampInMilliseconds);

  //     // Get the GMT+7 time zone
  //     final gmt7TimeZone = tz.getLocation('Asia/Bangkok');

  //     // Convert timestamp to GMT+7 timezone
  //     final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss')
  //         .format(tz.TZDateTime.from(dateTime, gmt7TimeZone));

  //     return formattedDate;
  //   } catch (e) {
  //     print('Error formatting timestamp: $e');
  //     return 'Error';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: const BoxDecoration(
          border: Border.symmetric(
              horizontal: BorderSide(width: 1, color: Colors.black45))),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
              width: (Get.width - 16) / 3,
              child: Align(
                  alignment: Alignment.center,
                  // child: Text(timestamp)),
                  child: Text(timestamp)),
            ),
            SizedBox(
              height: 50,
              width: (Get.width - 16) / 3,
              child: Align(alignment: Alignment.center, child: Text(deviceId)),
            ),
            SizedBox(
                // height: 50,
                width: (Get.width - 16) / 3,
                child: Text(value)),
          ],
        ),
      ),
    );
    ;
  }
}
