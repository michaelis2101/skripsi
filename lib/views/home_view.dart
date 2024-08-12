import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_network/image_network.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/models/user_model.dart';
import 'package:ta_web/services/auth_service.dart';
import 'package:ta_web/services/dashboard_service.dart';
import 'package:ta_web/services/devices_service.dart';
import 'package:ta_web/services/user_service.dart';
import 'package:ta_web/views/device_detail.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  User? user = FirebaseAuth.instance.currentUser;
  String email = '';

  bool isLoading = false;
  bool isDashboardLoading = false;
  // List<Map<String,dynamic>>
  Map<String, dynamic> userInfo = {};
  Map<String, dynamic> userSetting = {};
  List<Map<String, dynamic>> devicesList = [];
  List<Map<String, dynamic>> dashboardList = [];

  Future<void> refreshDashboard() async {
    setState(() {
      isDashboardLoading = true;
      dashboardList.clear();
    });

    try {
      var newDashboard = await DashboardService().getDashboards(email);
      setState(() {
        dashboardList = newDashboard;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isDashboardLoading = false;
      });
    }
  }

  void getUserInfo() async {
    setState(() {
      isLoading = true;

      email = user!.email!;
    });

    print(user!.uid);

    try {
      List<Map<String, dynamic>> userData =
          await UserService().getUserInfo(email);
      userInfo = userData.first;

      List<Map<String, dynamic>> userSettings =
          await UserService().getUserSettings(email);

      userSetting = userSettings.first;

      devicesList = await DevicesService().getDevices(email);
      dashboardList = await DashboardService().getDashboards(email);

      print(dashboardList);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // setState(() {
    //   email = user!.email!;
    // });
    getUserInfo();
  }

  List<Map<String, dynamic>> dashboardListDummy = [
    {
      'id': "asdasd",
      'name': "Dashboard 1",
    },
    {
      'id': "qwert",
      'name': "Dashboard 2",
    }
  ];
  List<Map<String, dynamic>> devicesListDummy = [
    {
      'id': "asdasd",
      'name': "Device 1",
    },
    {
      'id': "qwert",
      'name': "Device 2",
    }
  ];
  // List<Map<String, dynamic>> dashboardDevicesDummy = [
  //   {
  //     'id': "asdasd",
  //     'name': "Dashboard 1",
  //   },
  //   {
  //     'id': "qwert",
  //     'name': "Dashboard 2",
  //   }
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      // Icon(
                      //   Icons.home,
                      //   size: 30,
                      // ),
                      // SizedBox(
                      //   width: 5,
                      // ),
                      Text(
                        'Home',
                        style: TextStyle(fontSize: 30),
                      ),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.3,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: ColorApp.lapisLazuli,
                              spreadRadius: 2,
                              blurRadius: 4,
                              blurStyle: BlurStyle.inner,
                              offset: const Offset(0, 5))
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            width: 1,
                            color: ColorApp.lapisLazuli.withOpacity(0.5))),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    width: 3,
                                    color: ColorApp.lapisLazuli,
                                  )),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100)),
                                  child: userSetting['profile_pic'] != null
                                      ? ImageNetwork(
                                          image: userSetting['profile_pic'],
                                          height: 120,
                                          width: 120,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        )
                                      : ImageNetwork(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          image:
                                              'https://firebasestorage.googleapis.com/v0/b/project-st-iot.appspot.com/o/default_asset%2Fdefaultpfp.png?alt=media&token=882c5086-0c64-4285-b452-ca0b021707b6',
                                          height: 120,
                                          width: 120),
                                ),
                                // child: CircleAvatar(
                                //   radius: 60,
                                //   // child: Icon(Icons.person),
                                //   backgroundImage: userSetting['profile_pic'] !=
                                //           null
                                //       ? NetworkImage(userSetting['profile_pic'])
                                //       : const NetworkImage(
                                //           'https://firebasestorage.googleapis.com/v0/b/project-st-iot.appspot.com/o/default_asset%2Fdefaultpfp.png?alt=media&token=882c5086-0c64-4285-b452-ca0b021707b6'),
                                // ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Welcome Back, ${userInfo['username']}!',
                                  style: const TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Text(
                                  'What can we assist you with today?',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 19.7,
                  ),
                  SizedBox(
                    width: Get.width,
                    height: Get.height * 0.666666667 - 53,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate the width for each container based on the available width
                        double containerWidth = constraints.maxWidth / 3 - 10;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    width: 1,
                                    color:
                                        ColorApp.lapisLazuli.withOpacity(0.5)),
                              ),
                              width: containerWidth,
                              height: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Your Dashboards',
                                      style: TextStyle(fontSize: 25),
                                    ),
                                    if (isDashboardLoading)
                                      const Center(
                                          child: CircularProgressIndicator()),
                                    if (!isDashboardLoading &&
                                        dashboardList.isEmpty)
                                      Expanded(
                                        child: Center(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 120,
                                                child: SvgPicture.asset(
                                                  '../assets/svg/notfound.svg',
                                                ),
                                              ),
                                              const Text(
                                                'No Dashboard Created',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    if (!isDashboardLoading &&
                                        dashboardList.isNotEmpty)
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: dashboardList.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            var db = dashboardList[index];
                                            // print(db);

                                            return Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: ListTile(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                onTap: () {},
                                                title:
                                                    Text(db['dashboard_name']),
                                                trailing:
                                                    PopupMenuButton<String>(
                                                  icon: const Icon(Icons
                                                      .more_horiz_outlined),
                                                  onSelected: (value) {
                                                    if (value == 'delete') {
                                                      Get.defaultDialog(
                                                          title:
                                                              'Delete Dashboard?',
                                                          content:
                                                              isDashboardLoading
                                                                  ? Center(
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                      color: ColorApp
                                                                          .lapisLazuli,
                                                                    ))
                                                                  : Column(
                                                                      children: [
                                                                        Text(
                                                                            'Are you sure want to delete ${db['dashboard_name']}? '),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              50,
                                                                          width:
                                                                              double.infinity,
                                                                          child: ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(side: BorderSide(width: 1, color: ColorApp.lapisLazuli), borderRadius: const BorderRadius.all(Radius.circular(10)))),
                                                                              onPressed: () async {
                                                                                try {
                                                                                  await DashboardService().deleteDashboard(db['id']);
                                                                                } catch (e) {
                                                                                  print(e);
                                                                                } finally {
                                                                                  await refreshDashboard();
                                                                                  Get.back();
                                                                                }
                                                                              },
                                                                              child: Text(
                                                                                'Yes',
                                                                                style: TextStyle(color: ColorApp.lapisLazuli),
                                                                              )),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              50,
                                                                          width:
                                                                              double.infinity,
                                                                          child: ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: const RoundedRectangleBorder(side: BorderSide(width: 1, color: Colors.red), borderRadius: BorderRadius.all(Radius.circular(10)))),
                                                                              onPressed: () {
                                                                                Get.back();
                                                                              },
                                                                              child: const Text(
                                                                                'No',
                                                                                style: TextStyle(color: Colors.white),
                                                                              )),
                                                                        )
                                                                      ],
                                                                    ));
                                                    }
                                                  },
                                                  itemBuilder: (context) => [
                                                    const PopupMenuItem<String>(
                                                      value: 'delete',
                                                      child: ListTile(
                                                        leading:
                                                            Icon(Icons.delete),
                                                        title: Text('Delete'),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    width: 1,
                                    color:
                                        ColorApp.lapisLazuli.withOpacity(0.5)),
                              ),
                              width: containerWidth,
                              height: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Your Devices',
                                      style: TextStyle(fontSize: 25),
                                    ),
                                    if (devicesList.isEmpty)
                                      Expanded(
                                        child: Center(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 120,
                                                child: SvgPicture.asset(
                                                  '../assets/svg/notfound.svg',
                                                ),
                                              ),
                                              const Text(
                                                'No Device FOund',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: devicesList.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            var db = devicesList[index];

                                            return Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: ListTile(
                                                // leading: Icon(Icons.circle),

                                                leading: StreamBuilder(
                                                  stream: FirebaseDatabase
                                                      .instance
                                                      .ref()
                                                      .child(
                                                          'devices/${db['id']}/status/status')
                                                      .onValue,
                                                  builder: (context,
                                                      AsyncSnapshot snapshot) {
                                                    if (snapshot.hasData) {
                                                      var status = snapshot
                                                          .data.snapshot.value;

                                                      if (status == null ||
                                                          status == 'offline') {
                                                        return const Tooltip(
                                                          message: 'Offline',
                                                          child: Icon(
                                                            Icons.circle_sharp,
                                                            color: Colors.red,
                                                            size: 18,
                                                          ),
                                                        );
                                                      } else {
                                                        return const Tooltip(
                                                          message: 'Online',
                                                          child: Icon(
                                                            Icons.circle_sharp,
                                                            color: Colors.green,
                                                            size: 18,
                                                          ),
                                                        );
                                                      }
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return const Tooltip(
                                                        message: 'Loading...',
                                                        child: Icon(
                                                          Icons.circle_sharp,
                                                          color: Colors.grey,
                                                          size: 18,
                                                        ),
                                                      );
                                                    } else {
                                                      return const Icon(
                                                        Icons.circle_sharp,
                                                        color: Colors.grey,
                                                        size: 18,
                                                      );
                                                    }
                                                  },
                                                ),

                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                onTap: () {
                                                  Get.to(
                                                      transition: Transition
                                                          .rightToLeftWithFade,
                                                      DeviceDetail(
                                                          deviceName:
                                                              db['device_name'],
                                                          deviceID: db['id']));
                                                },
                                                title: Text(db['device_name']),
                                                // trailing: IconButton(
                                                //     onPressed: () {},
                                                //     icon: const Icon(Icons
                                                //         .more_horiz_outlined)),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    width: 1,
                                    color:
                                        ColorApp.lapisLazuli.withOpacity(0.5)),
                              ),
                              width: containerWidth,
                              height: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Settings',
                                      style: TextStyle(fontSize: 25),
                                    ),
                                    ListTile(
                                      trailing: Icon(
                                        Icons.logout_outlined,
                                        color: ColorApp.lapisLazuli,
                                      ),
                                      // hoverColor: ColorApp.lapisLazuli,

                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      title: const Text('Logout'),
                                      onTap: () {
                                        Get.defaultDialog(
                                            // middleTextStyle: const TextStyle(fontSize: 120),
                                            title: 'Log Out?',
                                            // middleText: 'Are you sure want to delete $widgetName?',
                                            content: Container(
                                              // width: 40,
                                              // color: Colors.amber,
                                              child: Column(
                                                children: [
                                                  const Text(
                                                    'Are you sure want to sign out?',
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  SizedBox(
                                                    height: 50,
                                                    width: double.infinity,
                                                    child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                                side: BorderSide(
                                                                    width: 1,
                                                                    color: ColorApp
                                                                        .lapisLazuli),
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                        Radius.circular(
                                                                            10)))),
                                                        onPressed: () {
                                                          try {
                                                            Auth().signOut();
                                                          } catch (e) {
                                                            print(e);
                                                          } finally {
                                                            Get.back();
                                                          }
                                                        },
                                                        child: Text(
                                                          'Yes',
                                                          style: TextStyle(
                                                              color: ColorApp
                                                                  .lapisLazuli),
                                                        )),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  SizedBox(
                                                    height: 50,
                                                    width: double.infinity,
                                                    child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.red,
                                                            shape: const RoundedRectangleBorder(
                                                                side: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .red),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10)))),
                                                        onPressed: () {
                                                          Get.back();
                                                        },
                                                        child: const Text(
                                                          'No',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )),
                                                  )
                                                ],
                                              ),
                                            ));
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
