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
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.to(
                () => DeviceDetail(
                      deviceName: deviceName,
                      deviceID: deviceId,
                    ),
                transition: Transition.rightToLeft);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                // Device Name
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorApp.lapisLazuli.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.devices_rounded,
                          size: 16,
                          color: ColorApp.lapisLazuli,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          deviceName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Device ID
                Expanded(
                  flex: 2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      deviceId,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Status
                Expanded(
                  flex: 1,
                  child: Center(
                    child: StreamBuilder(
                      stream: FirebaseDatabase.instance
                          .ref()
                          .child('devices/$deviceId/status/status')
                          .onValue,
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          var status = snapshot.data.snapshot.value;

                          if (status == null || status == 'offline') {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.red[500],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Offline',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontFamily: 'Nunito',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.green[500],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Online',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontFamily: 'Nunito',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        } else if (snapshot.hasError) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[500],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'N/A',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontFamily: 'Nunito',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: ColorApp.lapisLazuli.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    color: ColorApp.lapisLazuli,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Loading...',
                                  style: TextStyle(
                                    color: ColorApp.lapisLazuli,
                                    fontFamily: 'Nunito',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),

                // User
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: Colors.blue[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        padding: const EdgeInsets.all(8),
                        onSelected: (value) async {
                          if (value == 'newname') {
                            Get.defaultDialog(
                              title: 'Rename $deviceName',
                              titleStyle: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                                color: ColorApp.lapisLazuli,
                              ),
                              content: EditDeviceName(
                                deviceID: deviceId,
                              ),
                            );
                          }

                          if (value == 'delete') {
                            Get.defaultDialog(
                              title: 'Delete $deviceName',
                              titleStyle: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                                color: Colors.red[600],
                              ),
                              content: DeleteDevice(deviceID: deviceId),
                            );
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white,
                        elevation: 8,
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'newname',
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          ColorApp.lapisLazuli.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                      color: ColorApp.lapisLazuli,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Edit Name',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      size: 16,
                                      color: Colors.red[600],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Delete Device',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
