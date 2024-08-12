import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/services/user_service.dart';
import 'package:ta_web/widgets/g_db_newwidget_dialog.dart';
import 'package:ta_web/widgets/g_widget_card.dart';
import 'package:ta_web/widgets/main_dashboard.dart';
import 'package:ta_web/widgets/new_dashboard.dart';

class GlobalDashboard extends StatefulWidget {
  const GlobalDashboard({super.key});

  @override
  State<GlobalDashboard> createState() => _GlobalDashboardState();
}

class _GlobalDashboardState extends State<GlobalDashboard> {
  Map<String, dynamic>? selectedDashboard;
  String? selectedDashboardName;
  String? selectedDashboardId;
  User? user = FirebaseAuth.instance.currentUser;
  bool isWidgetEmpty = false;

  bool isLoading = false;
  bool dashboardListLoading = false;
  bool changingDashboardloading = false;

  List<String> dashboards = [];
  List<Map<String, dynamic>> dashboardsObject = [];
  List<Map<String, dynamic>> dashboardsList = [];

  final dashboardListRef = FirebaseDatabase.instance.ref().child('dashboards');

  Future<void> getDashboardList() async {
    setState(() {
      dashboardListLoading = true;
    });

    try {
      var snapshot = await dashboardListRef
          .orderByChild('user')
          .equalTo(user!.email!)
          .get();
      List<Map<String, dynamic>> tempDashboardList = [];

      if (snapshot.exists) {
        Map<dynamic, dynamic>? snapshotValueMap =
            snapshot.value as Map<dynamic, dynamic>?;
        //=====================================================
        snapshotValueMap?.forEach((key, value) {
          tempDashboardList.add(
              {'id': key.toString(), 'name': value['dashboardName'] as String});
        });
        //======================================================

        setState(() {
          dashboardsList = tempDashboardList;
        });
      } else {
        setState(() {
          dashboardsList = [];
        });
      }

      // print('dashboardList: ${snapshot.value}');
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        dashboardListLoading = false;
      });
    }
  }

  void testLoading() => setState(() {
        isLoading = !isLoading;
      });

  String generateDashboardId() {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    String id = '';

    for (int i = 0; i < 11; i++) {
      id += chars[random.nextInt(chars.length)];
    }

    return id;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getUserDashboard();
    getDashboardList();
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseReference dashboardRef = FirebaseDatabase.instance
        .ref()
        .child('dashboards/$selectedDashboardId');
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 30),
                ),
                Container(
                  width: Get.width * 0.6666666666666667,
                  decoration: BoxDecoration(
                      color: ColorApp.lapisLazuli,
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 50,
                          width: Get.width / 3,
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton2<Map<String, dynamic>>(
                            isExpanded: true,
                            hint: dashboardListLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: ColorApp.lapisLazuli,
                                    ),
                                  )
                                : const Text(
                                    'Select Dashboard',
                                    style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 18,
                                        // fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                            value: selectedDashboard,
                            onChanged: (value) async {
                              try {
                                setState(() {
                                  selectedDashboard = value!;
                                  selectedDashboardName =
                                      value['name'] as String;
                                  selectedDashboardId = value['id'] as String;
                                });
                                // await UserService().updateSelectedDashboard(
                                //     user!.email!, selectedDashboardId!);
                              } catch (e) {
                                rethrow;
                              } finally {
                                // setState(() {
                                //   changingDashboardloading = false;
                                // });
                              }

                              print('selectedDashboard = $selectedDashboard');
                              print(
                                  'selectedDashboardName = $selectedDashboardName');
                              print(
                                  'selectedDashboardId = $selectedDashboardId');
                            },
                            items: dashboardListLoading
                                ? []
                                : dashboardsList
                                    .map((dashboard) =>
                                        DropdownMenuItem<Map<String, dynamic>>(
                                          value: dashboard,
                                          child: Text(
                                            dashboard['name'] as String,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                    .toList(),
                            style: const TextStyle(fontSize: 18),
                            buttonStyleData: ButtonStyleData(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            iconStyleData: IconStyleData(
                                icon: const Icon(
                                    Icons.arrow_drop_down_circle_outlined),
                                iconSize: 14,
                                iconEnabledColor: ColorApp.lapisLazuli),
                            dropdownStyleData: DropdownStyleData(
                                // maxHeight: 50,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(10))),
                                width: MediaQuery.of(context).size.width / 3,
                                // width: MediaQuery.of(context).size.width * 0.29,
                                padding: const EdgeInsets.all(8)),
                          )),
                        ),
                        SizedBox(
                            height: 50,
                            width: Get.width / 6.5,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.defaultDialog(
                                    barrierDismissible: false,
                                    title: 'Create New Dashboard',
                                    content: NewDashboardDialog(
                                      refreshDashboardList: () async {
                                        await getDashboardList();
                                        setState(() {
                                          selectedDashboard =
                                              dashboardsList.isNotEmpty
                                                  ? dashboardsList[0]
                                                  : null;
                                          selectedDashboardName =
                                              selectedDashboard != null
                                                  ? selectedDashboard!['name']
                                                  : null;
                                          selectedDashboardId =
                                              selectedDashboard != null
                                                  ? selectedDashboard!['id']
                                                  : null;
                                        });
                                        // getDashboardList();
                                        // setState(() {
                                        //   selectedDashboard = selectedDashboard;
                                        //   // selectedDashboard!.clear();
                                        //   // selectedDashboardName = null;

                                        //   // selectedDashboardId = null;
                                        // });
                                        // getDashboardList().then((_) {
                                        //   setState(() {
                                        //     // Update selectedDashboard to the first item in dashboardsList
                                        //     selectedDashboard =
                                        //         dashboardsList.isNotEmpty
                                        //             ? dashboardsList[0]
                                        //             : null;
                                        //     // Optionally, update selectedDashboardName and selectedDashboardId
                                        //     selectedDashboardName =
                                        //         selectedDashboard != null
                                        //             ? selectedDashboard!['name']
                                        //             : null;
                                        //     selectedDashboardId =
                                        //         selectedDashboard != null
                                        //             ? selectedDashboard!['id']
                                        //             : null;
                                        //   });
                                        // });
                                      },
                                    ));
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                              child: Text('Create Dashboard',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: ColorApp.lapisLazuli)),
                            ))
                      ],
                    ),
                  ),
                ).animate().slideX(begin: 1, end: 0),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            if (selectedDashboardId != null)
              Container(
                // color: Colors.pink,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(width: 1, color: ColorApp.lapisLazuli)),
                height: Get.height - 86,
                width: double.infinity,
                // height: Get.height - 65,
                // child: MainDashboard(
                //   dashboardId: selectedDashboardId!,
                // ),

                child: Stack(
                  children: [
                    StreamBuilder(
                      stream: dashboardRef.onValue,
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          var userDashboards = snapshot.data!.snapshot.value;

                          if (userDashboards == null) {
                            return const Center(
                                child: Text(
                              'No Data Found',
                              style:
                                  TextStyle(fontFamily: 'Nunito', fontSize: 40),
                            ));
                          }

                          if (!userDashboards.containsKey('widgets')) {
                            // setState(() {
                            isWidgetEmpty = true;
                            print(isWidgetEmpty);
                            // });
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('No Widget Created'),
                                  const Text(
                                      'Press this button to create a widget'),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    height: 50,
                                    width: 200,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          Get.defaultDialog(
                                            title: 'Create New Widget',
                                            content: NewWidgetDialogDB(
                                                userEmail: user!.email!,
                                                dsahboardId:
                                                    selectedDashboardId!),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                ColorApp.lapisLazuli,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10))),
                                        child: const Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            Text(
                                              'Create Widget',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            )
                                          ],
                                        )),
                                  )
                                ],
                              ),
                            );
                          } else {
                            // setState(() {
                            isWidgetEmpty = false;
                            print(isWidgetEmpty);

                            var dashboardWidgets = userDashboards['widgets'];

                            print(dashboardWidgets);

                            List<Map<String, dynamic>> widgetsList = [];

                            dashboardWidgets.forEach((widgetID, widgetData) {
                              widgetsList.add({
                                'id': widgetID,
                                'deviceID': widgetData['deviceID'],
                                'key': widgetData['key'],
                                'name': widgetData['widgetName'],
                                'type': widgetData['type'],
                                'dataType': widgetData['dataType'],
                                'minValue': widgetData['minValue'],
                                'maxValue': widgetData['maxValue'],
                                'unit': widgetData['unit'],
                              });
                            });

                            print(widgetsList);

                            return Padding(
                              padding: const EdgeInsets.all(8),
                              child: GridView.builder(
                                itemCount: widgetsList.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        childAspectRatio: 4 / 3,
                                        // childAspectRatio: 5 / 8,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 20),
                                itemBuilder: (context, index) {
                                  var widgetData = widgetsList[index];
                                  // return SizedBox();
                                  // print(widgetData);

                                  return GlobalDashBoardCard(
                                    dashboardId: selectedDashboardId!!!!!,
                                    widgetId: widgetData['id'],
                                    widgetName: widgetData['name'],
                                    dataKey: widgetData['key'],
                                    dataType: widgetData['dataType'].toString(),
                                    widgetType: widgetData['type'],
                                    deviceId: widgetData['deviceID'],
                                    deviceName: widgetData['name'],
                                    minVal: widgetData['minValue'],
                                    maxVal: widgetData['maxValue'],
                                    unit: widgetData['unit'] ?? '',
                                  );
                                  // minVal:
                                  //     double.parse(widgetData['minValue']),
                                  // maxVal:
                                  //     double.parse(widgetData['maxValue']));
                                },
                              ),
                            );

                            // });
                            // return Text('ada widget');
                          }
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              color: ColorApp.lapisLazuli,
                            ),
                          );
                        }
                      },
                    ),
                    // if (isWidgetEmpty)
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                            onPressed: () {
                              Get.defaultDialog(
                                title: 'Create New Widget',
                                content: NewWidgetDialogDB(
                                    userEmail: user!.email!,
                                    dsahboardId: selectedDashboardId!),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: ColorApp.lapisLazuli,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            child: const Text(
                              'Create New Widget',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            )),
                      ),
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
