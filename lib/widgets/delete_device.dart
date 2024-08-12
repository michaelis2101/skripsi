import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/services/devices_service.dart';

class DeleteDevice extends StatefulWidget {
  String deviceID;
  DeleteDevice({super.key, required this.deviceID});

  @override
  State<DeleteDevice> createState() => _DeleteWidgetState();
}

class _DeleteWidgetState extends State<DeleteDevice> {
  bool isLoading = false;

  Future<void> delete(String id) async {
    setState(() {
      isLoading = true;
    });

    try {
      await DevicesService().deleteDevice(id);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * 0.3,
      child: Column(
        children: [
          Text('Delete ${widget.deviceID}'),
          const SizedBox(
            height: 10,
          ),
          if (isLoading)
            SizedBox(
              height: 110,
              child: Center(
                child: CircularProgressIndicator(
                  color: ColorApp.lapisLazuli,
                ),
              ),
            ),
          if (!isLoading)
            Column(
              children: [
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () async {
                        await delete(widget.deviceID);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: ColorApp.lapisLazuli,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text(
                        'Delete Device',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )),
                )
              ],
            ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(width: 1, color: ColorApp.lapisLazuli),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                onPressed: () => Get.back(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: ColorApp.lapisLazuli, fontSize: 20),
                )),
          ),
        ],
      ),
    );
  }
}
