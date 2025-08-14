import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/widgets/g_widget_card.dart';
import 'package:ta_web/widgets/new_dashboard.dart';
import 'package:ta_web/widgets/g_db_newwidget_dialog.dart';

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
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 32),

            // Dashboard Controls
            _buildDashboardControls(),
            const SizedBox(height: 24),

            // Main Dashboard Content
            if (selectedDashboardId != null)
              _buildDashboardContent(dashboardRef),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorApp.lapisLazuli,
                ColorApp.lapisLazuli.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ColorApp.lapisLazuli.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.dashboard_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Global Dashboard',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: ColorApp.lapisLazuli,
            fontFamily: "Nunito",
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildDashboardControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Dashboard Selector
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.dashboard_customize_rounded,
                      color: ColorApp.lapisLazuli,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Select Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ColorApp.lapisLazuli,
                        fontFamily: "Nunito",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                    color: Colors.grey[50],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<Map<String, dynamic>>(
                      isExpanded: true,
                      hint: dashboardListLoading
                          ? Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: ColorApp.lapisLazuli,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Loading dashboards...',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Choose a dashboard to display',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                      value: selectedDashboard,
                      onChanged: (value) async {
                        try {
                          setState(() {
                            selectedDashboard = value!;
                            selectedDashboardName = value['name'] as String;
                            selectedDashboardId = value['id'] as String;
                          });
                        } catch (e) {
                          rethrow;
                        }
                      },
                      items: dashboardListLoading
                          ? []
                          : dashboardsList
                              .map((dashboard) =>
                                  DropdownMenuItem<Map<String, dynamic>>(
                                    value: dashboard,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: ColorApp.lapisLazuli
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Icon(
                                            Icons.dashboard_outlined,
                                            size: 16,
                                            color: ColorApp.lapisLazuli,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            dashboard['name'] as String,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                      buttonStyleData: ButtonStyleData(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      iconStyleData: IconStyleData(
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: ColorApp.lapisLazuli,
                        ),
                        iconSize: 24,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Create Dashboard Button
          Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorApp.lapisLazuli,
                  ColorApp.lapisLazuli.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ColorApp.lapisLazuli.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Get.defaultDialog(
                    barrierDismissible: false,
                    title: 'Create New Dashboard',
                    titleStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      color: ColorApp.lapisLazuli,
                    ),
                    content: NewDashboardDialog(
                      refreshDashboardList: () async {
                        await getDashboardList();
                        setState(() {
                          selectedDashboard = dashboardsList.isNotEmpty
                              ? dashboardsList[0]
                              : null;
                          selectedDashboardName = selectedDashboard != null
                              ? selectedDashboard!['name']
                              : null;
                          selectedDashboardId = selectedDashboard != null
                              ? selectedDashboard!['id']
                              : null;
                        });
                      },
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Create Dashboard',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: "Nunito",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  Widget _buildDashboardContent(DatabaseReference dashboardRef) {
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - 300,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          StreamBuilder(
            stream: dashboardRef.onValue,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                var userDashboards = snapshot.data!.snapshot.value;

                if (userDashboards == null) {
                  return _buildNoDashboardState();
                }

                if (!userDashboards.containsKey('widgets')) {
                  return _buildEmptyWidgetState();
                } else {
                  var dashboardWidgets = userDashboards['widgets'];

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

                  return _buildWidgetsGrid(widgetsList);
                }
              } else if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              } else {
                return _buildLoadingState();
              }
            },
          ),
          // Floating Add Widget Button
          Positioned(
            bottom: 24,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorApp.lapisLazuli,
                    ColorApp.lapisLazuli.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: ColorApp.lapisLazuli.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => NewWidgetDialog(
                        dashboardId: selectedDashboardId!,
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Add Widget',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Nunito",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  Widget _buildNoDashboardState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.dashboard_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Dashboard Data',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The selected dashboard could not be loaded',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidgetState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ColorApp.lapisLazuli.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.widgets_outlined,
                size: 48,
                color: ColorApp.lapisLazuli,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Widgets Created',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: ColorApp.lapisLazuli,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start building your dashboard by adding your first widget',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorApp.lapisLazuli,
                    ColorApp.lapisLazuli.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: ColorApp.lapisLazuli.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => NewWidgetDialog(
                        dashboardId: selectedDashboardId!,
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Create Your First Widget',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Nunito",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetsGrid(List<Map<String, dynamic>> widgetsList) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.widgets_rounded,
                color: ColorApp.lapisLazuli,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Dashboard Widgets',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ColorApp.lapisLazuli,
                  fontFamily: "Nunito",
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ColorApp.lapisLazuli.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widgetsList.length} widget${widgetsList.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorApp.lapisLazuli,
                    fontFamily: "Nunito",
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widgetsList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 4 / 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              var widgetData = widgetsList[index];
              return GlobalDashBoardCard(
                dashboardId: selectedDashboardId!,
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
            },
          ),
          const SizedBox(height: 80), // Space for floating button
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something Went Wrong',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load dashboard data',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                color: Colors.red[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: ColorApp.lapisLazuli,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Loading dashboard...',
              style: TextStyle(
                color: ColorApp.lapisLazuli,
                fontSize: 16,
                fontFamily: "Nunito",
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
