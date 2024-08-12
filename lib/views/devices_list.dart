import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/views/add_device.dart';
import 'package:ta_web/widgets/custom_tile.dart';
import 'package:ta_web/widgets/newdevice_dialog.dart';

class DevicesList extends StatefulWidget {
  const DevicesList({super.key});

  @override
  State<DevicesList> createState() => _DevicesListState();
}

List<Map<String, dynamic>> dummyDevices = [
  {
    "name": "Device 1",
    "id": "123123123",
    "owner": "owner@mail.com",
    "user": "user@mail.com"
  },
  {
    "name": "Device 2",
    "id": "234123345",
    "owner": "owner2@mail.com",
    "user": "user2@mail.com"
  },
];

final DatabaseReference dbRef =
    FirebaseDatabase.instance.ref().child('devices');

class _DevicesListState extends State<DevicesList> {
  User? user = FirebaseAuth.instance.currentUser;
  String email = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      email = user!.email!;
    });
  }

  @override
  Widget build(BuildContext context) {
    // print('Height : ${Get.height}');
    // print('Width : ${Get.width}');

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Devices List",
                    style: TextStyle(
                      fontFamily: "Nunito",
                      fontSize: 30,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 180,
                    child: ElevatedButton(
                        onPressed: () {
                          // Get.to(() => const AddDeviceScreen(),
                          //     transition: Transition.rightToLeft);
                          Get.defaultDialog(
                            barrierDismissible: false,
                            title: "Add Device",
                            titleStyle: const TextStyle(
                                fontFamily: 'Nunito', color: Colors.black),
                            content: const NewDevDialog(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ColorApp.lapisLazuli,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                            ),
                            Text("Add Device",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Nunito",
                                    fontSize: 16))
                          ],
                        )),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              // const Row(
              //   children: [
              //     Text(
              //       "No",
              //       style: TextStyle(fontFamily: "Nunito"),
              //     )
              //   ],
              // )
              Container(
                width: Get.width,
                height: 50,
                decoration: BoxDecoration(
                    color: ColorApp.lapisLazuli,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    border: const Border.symmetric(
                        horizontal:
                            BorderSide(width: 1, color: Colors.black45))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: Get.width * 0.15,
                        child: const Text("Name",
                            style: TextStyle(
                                color: Colors.white, fontFamily: "Nunito")),
                      ),
                      SizedBox(
                        width: Get.width * 0.15,
                        child: const Text("ID",
                            style: TextStyle(
                                color: Colors.white, fontFamily: "Nunito")),
                      ),
                      SizedBox(
                        width: Get.width * 0.15,
                        child: const Text("Status",
                            style: TextStyle(
                                color: Colors.white, fontFamily: "Nunito")),
                      ),
                      SizedBox(
                        width: Get.width * 0.15,
                        child: const Text("User",
                            style: TextStyle(
                                color: Colors.white, fontFamily: "Nunito")),
                      ),
                      SizedBox(
                        width: Get.width * 0.15,
                        child: const Center(
                          child: Text("Settings",
                              style: TextStyle(
                                  color: Colors.white, fontFamily: "Nunito")),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: Get.height - 70,
                width: Get.width,

                child: StreamBuilder(
                  stream: dbRef.orderByChild('user').equalTo(email).onValue,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      var devices = snapshot.data!.snapshot.value;

                      if (devices == null) {
                        return const Center(
                            child: Text(
                          'No Devices Found',
                          style: TextStyle(fontFamily: 'Nunito', fontSize: 40),
                        ));
                      }

                      List<Map<String, dynamic>> userDevice = [];

                      devices.forEach((deviceId, deviceInfo) {
                        userDevice.add({
                          'deviceId': deviceId,
                          'name': deviceInfo['deviceName'],
                          'owner': deviceInfo['owner'],
                          'user': deviceInfo['user'],
                        });
                      });

                      // print(userDevice);

                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userDevice.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final device = userDevice[index];
                          return CustomTile(
                              deviceName: device["name"],
                              deviceId: device["deviceId"],
                              owner: device["owner"],
                              user: device["user"]);
                        },
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Something went Wrong',
                          style: TextStyle(fontFamily: 'Nunito', fontSize: 40),
                        ),
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
                // child: ListView.builder(
                //   itemCount: dummyDevices.length,
                //   itemBuilder: (context, index) {
                //     final device = dummyDevices[index];
                //     return CustomTile(
                //         deviceName: device["name"],
                //         deviceId: device["id"],
                //         owner: device["owner"],
                //         status: device["user"]);
                //   },
                // ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
