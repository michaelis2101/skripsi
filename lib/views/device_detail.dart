import 'dart:math';

import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/models/log_model.dart';
import 'package:ta_web/services/devices_service.dart';
import 'package:ta_web/services/note_service.dart';
import 'package:ta_web/views/device_tutor.dart';
import 'package:ta_web/widgets/add_device_note.dart';
import 'package:ta_web/widgets/device_chart.dart';
import 'package:ta_web/widgets/device_dashboard.dart';
import 'package:ta_web/widgets/device_log.dart';
import 'package:ta_web/widgets/note_view.dart';
import 'package:ta_web/widgets/widget_card.dart';

class DeviceDetail extends StatefulWidget {
  String deviceName, deviceID;

  DeviceDetail({super.key, required this.deviceName, required this.deviceID});

  @override
  State<DeviceDetail> createState() => _DeviceDetailState();
}

// final DatabaseReference dbRef =
//     FirebaseDatabase.instance.ref().child('devices').child(id);

class _DeviceDetailState extends State<DeviceDetail> {
  String deviceId = '';
  String deviceName = '';
  String user = '';
  String owner = '';
  String status = '';
  String createdAt = '';

  int selectedIndex = 0;

  String? currentValue;

  bool isLoading = false;
  final supabase = Supabase.instance.client;

  // Map<String, dynamic> deviceData = {};

  List<Map<String, dynamic>> deviceData = [];

  // List<Map<String, dynamic>> noteList = [
  //   {'title': 'Abcdef', 'content': 'content123', 'createdAt': '12/12/2012'},
  //   {
  //     'title': 'Abcdef',
  //     'content': 'content123hdfsdhkdjshfksdjfhsdkjhfsdjkfhsdjkhfjkdfhkjsdhfk',
  //     'createdAt': '12/12/2014'
  //   },
  // ];

  List<Map<String, dynamic>> noteList = [];

  String formatDateTime(String isoDate) {
    DateTime parsedDate = DateTime.parse(isoDate);
    String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
    return formattedDate;
  }

  Future<void> getNoteList() async {
    setState(() {
      noteList.clear();
    });
    try {
      noteList = await NoteService().getNoteList(widget.deviceID);
      setState(() {
        noteList = noteList;
      });
    } catch (e) {
      rethrow;
    } finally {
      setState(() {});
    }
  }

  Future<void> getDeviceData() async {
    setState(() {
      isLoading = true;
    });

    try {
      deviceData = await DevicesService().getDeviceInfo(widget.deviceID);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        deviceId = deviceData[0]['id'];
        deviceName = widget.deviceName;
        // deviceName = deviceData[0]['device_name'];
        user = deviceData[0]['user'];
        owner = deviceData[0]['owner'];
        status = deviceData[0]['status'];
        createdAt = deviceData[0]['created_at'].toString();

        isLoading = false;
      });
    }
  }

  String generateLogId() {
    const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    String id = '';

    for (int i = 0; i < 10; i++) {
      id += chars[random.nextInt(chars.length)];
    }

    return id;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceData();
    getNoteList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorApp.lapisLazuli,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        automaticallyImplyLeading: false,
        title: Text(
          widget.deviceName,
          style: const TextStyle(
              fontFamily: "Nunito", fontSize: 30, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          // color: Colors.amber,
          // height: Get.height,
          width: Get.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 150,
                    width: Get.width,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              if (!isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  // padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 150,
                          width: Get.width / 3,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1, color: ColorApp.lapisLazuli),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Device Info',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    StreamBuilder(
                                      stream: FirebaseDatabase.instance
                                          .ref()
                                          .child(
                                              'devices/$deviceId/status/status')
                                          .onValue,
                                      builder:
                                          (context, AsyncSnapshot snapshot) {
                                        if (snapshot.hasData) {
                                          var status =
                                              snapshot.data.snapshot.value;

                                          if (status == null ||
                                              status == 'offline') {
                                            return const Row(
                                              children: [
                                                Icon(
                                                  Icons.circle_sharp,
                                                  color: Colors.red,
                                                  size: 18,
                                                ),
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
                                              Text('N/A')
                                            ],
                                          );
                                        } else {
                                          return Row(
                                            children: [
                                              SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: ColorApp.lapisLazuli,
                                                  )),
                                              const Text('Loading...')
                                            ],
                                          );
                                        }
                                      },
                                    )
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('Device Id : $deviceId'),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Clipboard.setData(
                                            ClipboardData(text: deviceId));
                                      },
                                      child: const Tooltip(
                                        message: 'Copy Device Id',
                                        child: Icon(
                                          Icons.copy,
                                          size: 15,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Text('Owner : $owner'),
                                Text('User : $user'),
                                Text('Status : $status'),
                                Text('Created At : $createdAt')
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: Get.width * 0.64,
                          height: 150,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1, color: ColorApp.lapisLazuli),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: Column(
                            children: [
                              Container(
                                height: 30,
                                decoration: BoxDecoration(
                                    color: ColorApp.lapisLazuli,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(10))),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          'Notes',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    // color: Colors.pink,
                                    width: (Get.width * 0.64) * 0.9,
                                    height: 118,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10))),
                                    //notes card

                                    child: GridView.builder(
                                      itemCount: noteList.length,
                                      scrollDirection: Axis.horizontal,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 1,
                                              childAspectRatio: 5 / 8,
                                              crossAxisSpacing: 0,
                                              mainAxisSpacing: 0),
                                      itemBuilder: (context, index) {
                                        var note = noteList[index];

                                        return Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: InkWell(
                                            onTap: () {
                                              Get.defaultDialog(
                                                  title: '',
                                                  titleStyle: const TextStyle(
                                                      height: 0),
                                                  // title: null,

                                                  content: NoteView(
                                                    noteID: note['id'],
                                                    // refreshNoteList: getNoteList(),
                                                    refreshNoteList: () =>
                                                        getNoteList(),
                                                  ));
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.white54,
                                                  border: Border.all(
                                                      width: 1,
                                                      color: ColorApp
                                                          .lapisLazuli)),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    // width: double.infinity,
                                                    decoration: BoxDecoration(
                                                        color: ColorApp
                                                            .lapisLazuli,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10)),
                                                        border: Border.all(
                                                            width: 1,
                                                            color: ColorApp
                                                                .lightLapisLazuli)),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5),
                                                      child: Text(
                                                        formatDateTime(
                                                            note['created_at']
                                                                .toString()),
                                                        style: const TextStyle(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontSize: 14,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          note['title'],
                                                          // maxLines: ,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          note['content'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Get.defaultDialog(
                                          title: 'Add New Note',
                                          content: AddDeviceNote(
                                            deviceID: widget.deviceID,
                                            refreshNoteList: () {
                                              getNoteList();
                                            },
                                          ));
                                    },
                                    child: Container(
                                      width: (Get.width * 0.64) * 0.097,
                                      height: 118,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                            bottomRight: Radius.circular(10)),
                                        border: Border(
                                            left: BorderSide(
                                                width: 1,
                                                color: ColorApp.lapisLazuli)),
                                        // color: Colors.pinkAccent
                                      ),
                                      child: Center(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 80,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: ColorApp.lapisLazuli),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.note_add_rounded,
                                                  size: 40,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            const Text(
                                              'New Note',
                                              style: TextStyle(fontSize: 18),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              StreamBuilder(
                stream: FirebaseDatabase.instance
                    .ref()
                    .child('devices/${widget.deviceID}')
                    .onValue,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data.snapshot.value;

                    List<String> valueKeys = [];
                    List<String> stringValueKeys = [];
                    if (data == null) {
                      return const SizedBox(
                        // height: Get.height,
                        // width: Get.width,
                        child: Center(
                          child: Text('No Data Found'),
                        ),
                      );
                    }

                    if (data == null || !data.containsKey('value')) {
                      return SendValueTutorial(
                        deviceId: deviceId,
                      );
                    } else {
                      if (data.containsKey('value') && status != 'Connected') {
                        DevicesService().updateDeviceStatus(widget.deviceID);
                      }

                      Map<String, dynamic> deviceValue = data['value'];

                      //check the data type first, if the data string then do not add to the 'valueKeys' List, create a new list to save the key with string data type
                      // deviceValue.forEach((key, value) {
                      //   valueKeys.add(key);
                      // });

                      deviceValue.forEach((key, value) {
                        if (value is String) {
                          // If the value is a string, add the key to the stringValueKeys list
                          stringValueKeys.add(key);
                        } else {
                          // If the value is not a string, add the key to the valueKeys list
                          valueKeys.add(key);
                        }
                      });

                      // print(stringValueKeys);

                      List<String> allKeys = [];
                      allKeys.addAll(valueKeys);
                      allKeys.addAll(stringValueKeys);

                      LogModel newVal = LogModel(
                          deviceId: deviceId,
                          value: deviceValue.toString(),
                          deviceName: widget.deviceName);

                      try {
                        // insertDataToLog(newVal, data);
                      } catch (e) {
                        print(e);
                      }

                      return Container(
                        height: Get.height - 150 - 72,
                        width: Get.width,
                        child: ContainedTabBarView(
                            tabBarProperties: TabBarProperties(
                                labelStyle: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                                unselectedLabelStyle: TextStyle(
                                    fontSize: 18, color: ColorApp.lapisLazuli),
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicatorColor: ColorApp.lapisLazuli,
                                indicator: BoxDecoration(
                                    color: ColorApp.lapisLazuli,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        width: 1, color: ColorApp.lapisLazuli)),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8)),
                            // tabBarViewProperties: TabBarViewProperties(),
                            onChange: (p0) {
                              // print(p0);
                              // setState(() {
                              //   selectedIndex = p0;
                              // });
                            },
                            tabs: const [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Device Dashboard',
                                  style: TextStyle(
                                    fontSize: 18,
                                    // color: selectedIndex == 0
                                    //     ? Colors.white
                                    //     : ColorApp.lapisLazuli
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Data Charts',
                                  style: TextStyle(
                                    fontSize: 18,
                                    // color: selectedIndex == 0
                                    //     ? Colors.white
                                    //     : ColorApp.lapisLazuli
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Device Log',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            ],
                            views: [
                              DeviceDashboard(
                                deviceID: widget.deviceID,
                                valueKeys: allKeys,
                                deviceName: widget.deviceName,
                              ),
                              DeviceCharts(
                                deviceId: widget.deviceID,
                                valueKeys: valueKeys,
                              ),
                              DeviceLog(
                                deviceId: widget.deviceID,
                                keys: valueKeys,
                              )
                            ]),
                      );
                    }
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
            ],
          ),
        ),
      ),
    );
  }
}
