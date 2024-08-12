import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/views/device_detail.dart';
import 'package:ta_web/widgets/delete_device.dart';
import 'package:ta_web/widgets/edit_device_name.dart';

class CustomTile extends StatelessWidget {
  String deviceName, deviceId, owner, user;
  CustomTile(
      {super.key,
      required this.deviceId,
      required this.deviceName,
      required this.owner,
      required this.user});

  TextEditingController newNameCont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(
            () => DeviceDetail(
                  deviceName: deviceName,
                  deviceID: deviceId,
                ),
            transition: Transition.rightToLeft);
      },
      child: Container(
        width: Get.width,
        height: 50,
        decoration: const BoxDecoration(
            border: Border.symmetric(
                horizontal: BorderSide(width: 1, color: Colors.black45))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: Get.width * 0.15,
                child: Text(
                  deviceName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.black, fontFamily: 'Nunito'),
                ),
              ),
              SizedBox(
                width: Get.width * 0.15,
                child: Text(
                  deviceId,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.black, fontFamily: 'Nunito'),
                ),
              ),
              SizedBox(
                width: Get.width * 0.15,
                // child: Text(
                //   owner,
                //   overflow: TextOverflow.ellipsis,
                //   style: const TextStyle(
                //       color: Colors.black, fontFamily: 'Nunito'),
                // ),
                child: StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref()
                      .child('devices/$deviceId/status/status')
                      .onValue,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      var status = snapshot.data.snapshot.value;

                      if (status == null || status == 'offline') {
                        return const Row(
                          children: [
                            Icon(
                              Icons.circle_sharp,
                              color: Colors.red,
                              size: 18,
                            ),
                            SizedBox(width: 5),
                            Text('Offline')
                          ],
                        );
                      } else {
                        return const Row(
                          children: [
                            Icon(
                              Icons.circle_sharp,
                              color: Colors.green,
                              size: 18,
                            ),
                            SizedBox(width: 5),
                            Text('Online')
                          ],
                        );
                      }
                    } else if (snapshot.hasError) {
                      return const Row(
                        children: [
                          Icon(
                            Icons.circle_sharp,
                            color: Colors.grey,
                            size: 18,
                          ),
                          SizedBox(width: 5),
                          Text('N/A')
                        ],
                      );
                    } else {
                      return Row(
                        children: [
                          SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: ColorApp.lapisLazuli,
                              )),
                          const Text('Loading...')
                        ],
                      );
                    }
                  },
                ),
              ),
              SizedBox(
                width: Get.width * 0.15,
                child: Text(
                  user,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.black, fontFamily: 'Nunito'),
                ),
              ),
              SizedBox(
                width: Get.width * 0.15,
                // child: IconButton(
                //     onPressed: () {},
                //     icon: const Icon(Icons.more_horiz_rounded)),

                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz_rounded),
                  onSelected: (value) async {
                    if (value == 'newname') {
                      Get.defaultDialog(
                          title: 'Rename $deviceName',
                          content: EditDeviceName(
                            deviceID: deviceId,
                          ));
                    }

                    if (value == 'delete') {
                      Get.defaultDialog(
                          title: 'Delete $deviceName',
                          content: DeleteDevice(deviceID: deviceId));
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'newname',
                      child: ListTile(
                        leading: Icon(Icons.mode_edit_outline_rounded),
                        title: Text('Edit Device Name'),
                      ),
                    ),
                    // const PopupMenuItem<String>(
                    //   value: 'transfer',
                    //   child: ListTile(
                    //     leading: Icon(Icons.sync_alt_rounded),
                    //     title: Text('Transfer Device'),
                    //   ),
                    // ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('Delete Device'),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
