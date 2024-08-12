import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/widgets/g_db_newwidget_dialog.dart';
import 'package:ta_web/widgets/g_widget_card.dart';

class MainDashboard extends StatefulWidget {
  String dashboardId;
  MainDashboard({super.key, required this.dashboardId});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  User? user = FirebaseAuth.instance.currentUser;
  String idDashboard = '';
  // dynamic userDashboards;
  bool isWidgetEmpty = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      idDashboard = widget.dashboardId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseReference dashboardRef =
        FirebaseDatabase.instance.ref().child('dashboards/$idDashboard');

    return Stack(
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
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 40),
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
                                title: 'Create New Widget',
                                content: NewWidgetDialogDB(
                                    userEmail: user!.email!,
                                    dsahboardId: idDashboard),
                              );
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
              } else {
                // setState(() {
                isWidgetEmpty = false;
                print(isWidgetEmpty);

                var dashboardWidgets = userDashboards['widgets'];

                List<Map<String, dynamic>> widgetsList = [];

                dashboardWidgets.forEach((widgetID, widgetData) {
                  widgetsList.add({
                    'id': widgetID,
                    'deviceID': widgetData['deviceID'],
                    'key': widgetData['key'],
                    'name': widgetData['widgetName'],
                    'type': widgetData['type'],
                    'minValue': widgetData['minValue'],
                    'maxValue': widgetData['maxValue'],
                  });
                });

                print(widgetsList);

                return Expanded(
                    child: Padding(
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

                      return GlobalDashBoardCard(
                          dashboardId: idDashboard,
                          widgetId: widgetData['id'],
                          widgetName: widgetData['name'],
                          dataKey: widgetData['key'],
                          widgetType: widgetData['type'],
                          dataType: widgetData['dataType'],
                          deviceId: widgetData['deviceID'],
                          deviceName: widgetData['name'],
                          minVal: double.parse(widgetData['minValue']),
                          maxVal: double.parse(widgetData['maxValue']));
                    },
                  ),
                ));

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
        if (!isWidgetEmpty)
          Positioned(
            bottom: 20,
            right: 20,
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ColorApp.lapisLazuli,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: const Text(
                    'Create New Widget',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  )),
            ),
          )
      ],
    );
  }
}
