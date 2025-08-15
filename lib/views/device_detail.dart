import 'dart:math';

import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/services/devices_service.dart';
import 'package:ta_web/services/note_service.dart';
import 'package:ta_web/views/device_tutor.dart';
import 'package:ta_web/widgets/add_device_note.dart';
import 'package:ta_web/widgets/device_chart.dart';
import 'package:ta_web/widgets/device_dashboard.dart';
import 'package:ta_web/widgets/device_log.dart';
import 'package:ta_web/widgets/note_view.dart';

class DeviceDetail extends StatefulWidget {
  final String deviceName, deviceID;

  const DeviceDetail(
      {super.key, required this.deviceName, required this.deviceID});

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

  Widget _buildDeviceInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - more compact
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorApp.lapisLazuli,
                  ColorApp.lapisLazuli.withOpacity(0.8)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.info_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Device Information',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      color: Colors.white,
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref()
                      .child('devices/$deviceId/status/status')
                      .onValue,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      var status = snapshot.data.snapshot.value;
                      bool isOnline = status != null && status != 'offline';

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOnline
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              color: isOnline ? Colors.green : Colors.red,
                              size: 8,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              isOnline ? 'Online' : 'Offline',
                              style: TextStyle(
                                color: isOnline ? Colors.green : Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        child: const Text(
                          'Loading...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          // Content - more compact layout with fixed height to match notes section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: SizedBox(
              height: 120, // Fixed height to match notes section
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactInfoRow(
                            Icons.fingerprint_rounded, 'ID', deviceId,
                            copyable: true),
                      ),
                      Expanded(
                        child: _buildCompactInfoRow(
                            Icons.person_rounded, 'Owner', owner),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactInfoRow(
                            Icons.account_circle_rounded, 'User', user),
                      ),
                      Expanded(
                        child: _buildCompactInfoRow(
                            Icons.settings_rounded, 'Status', status),
                      ),
                    ],
                  ),
                  _buildCompactInfoRow(Icons.calendar_today_rounded, 'Created',
                      formatDateTime(createdAt)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoRow(IconData icon, String label, String value,
      {bool copyable = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: ColorApp.lapisLazuli.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            color: ColorApp.lapisLazuli,
            size: 12,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black87,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (copyable)
          InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              Get.snackbar(
                'Copied!',
                'Device ID copied to clipboard',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: ColorApp.lapisLazuli,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.copy_rounded,
                size: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - more compact to match device info card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorApp.lapisLazuli,
                  ColorApp.lapisLazuli.withOpacity(0.8)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.sticky_note_2_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Device Notes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${noteList.length} notes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content - more compact layout to match device info card height
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: SizedBox(
              height:
                  120, // Fixed height to match the compact device info content
              child: Row(
                children: [
                  // Notes List
                  Expanded(
                    child: noteList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.note_add_rounded,
                                  size: 32,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'No notes yet',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Add your first note',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: noteList.length,
                            itemBuilder: (context, index) {
                              var note = noteList[index];
                              return Container(
                                width: 120,
                                margin: const EdgeInsets.only(right: 8),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      Get.defaultDialog(
                                        title: '',
                                        titleStyle: const TextStyle(height: 0),
                                        content: NoteView(
                                          noteID: note['id'],
                                          refreshNoteList: () => getNoteList(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey[200]!),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: ColorApp.lapisLazuli
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              formatDateTime(note['created_at']
                                                  .toString()),
                                              style: TextStyle(
                                                fontSize: 8,
                                                color: ColorApp.lapisLazuli,
                                                fontFamily: 'Nunito',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            note['title'],
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Nunito',
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Expanded(
                                            child: Text(
                                              note['content'],
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: Colors.grey[700],
                                                fontFamily: 'Nunito',
                                              ),
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(width: 8),
                  // Add Note Button - more compact
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Get.defaultDialog(
                          title: 'Add New Note',
                          content: AddDeviceNote(
                            deviceID: widget.deviceID,
                            refreshNoteList: () => getNoteList(),
                          ),
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 100,
                        decoration: BoxDecoration(
                          color: ColorApp.lapisLazuli.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: ColorApp.lapisLazuli.withOpacity(0.3)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ColorApp.lapisLazuli,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add Note',
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w600,
                                color: ColorApp.lapisLazuli,
                              ),
                              textAlign: TextAlign.center,
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
        ],
      ),
    );
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
        elevation: 0,
        backgroundColor: ColorApp.lapisLazuli,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.devices_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.deviceName,
                    style: const TextStyle(
                      fontFamily: "Nunito",
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Device Details',
                    style: TextStyle(
                      fontFamily: "Nunito",
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorApp.lapisLazuli,
                ColorApp.lapisLazuli.withOpacity(0.8)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Loading State
                  if (isLoading)
                    Container(
                      margin: const EdgeInsets.all(16),
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  // Device Info Section
                  if (!isLoading)
                    Container(
                      // margin: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Device Info Card
                          Expanded(
                            flex: 1,
                            child: _buildDeviceInfoCard(),
                          ),
                          const SizedBox(width: 16),
                          // Notes Section
                          Expanded(
                            flex: 2,
                            child: _buildNotesSection(),
                          ),
                        ],
                      ),
                    ),
                  // Data Visualization Tabs
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
                          return Container(
                            margin: const EdgeInsets.all(16),
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.data_usage_rounded,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No Data Found',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                      fontFamily: 'Nunito',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'This device hasn\'t sent any data yet',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                      fontFamily: 'Nunito',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (data == null || !data.containsKey('value')) {
                          return SendValueTutorial(deviceId: deviceId);
                        } else {
                          if (data.containsKey('value') &&
                              status != 'Connected') {
                            DevicesService()
                                .updateDeviceStatus(widget.deviceID);
                          }

                          Map<String, dynamic> deviceValue =
                              Map<String, dynamic>.from(data['value'] as Map);

                          deviceValue.forEach((key, value) {
                            if (value is String) {
                              stringValueKeys.add(key);
                            } else {
                              valueKeys.add(key);
                            }
                          });

                          List<String> allKeys = [];
                          allKeys.addAll(valueKeys);
                          allKeys.addAll(stringValueKeys);

                          return Container(
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              height:
                                  550, // Fixed reasonable height for TabBar section
                              child: ContainedTabBarView(
                                tabBarProperties: TabBarProperties(
                                  height: 50,
                                  labelStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w600,
                                  ),
                                  unselectedLabelStyle: TextStyle(
                                    fontSize: 16,
                                    color: ColorApp.lapisLazuli,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicatorColor: ColorApp.lapisLazuli,
                                  indicator: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        ColorApp.lapisLazuli,
                                        ColorApp.lapisLazuli.withOpacity(0.8)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ColorApp.lapisLazuli
                                            .withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  margin: const EdgeInsets.all(8),
                                ),
                                tabs: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.dashboard_rounded, size: 18),
                                        SizedBox(width: 8),
                                        Text('Dashboard'),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.analytics_rounded, size: 18),
                                        SizedBox(width: 8),
                                        Text('Charts'),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.list_alt_rounded, size: 18),
                                        SizedBox(width: 8),
                                        Text('Logs'),
                                      ],
                                    ),
                                  ),
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
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      } else if (snapshot.hasError) {
                        return Container(
                          margin: const EdgeInsets.all(16),
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 64,
                                  color: Colors.red[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error Loading Data',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[600],
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  snapshot.error.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red[500],
                                    fontFamily: 'Nunito',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          margin: const EdgeInsets.all(16),
                          height:
                              300, // Fixed reasonable height for loading state
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: ColorApp.lapisLazuli,
                                  strokeWidth: 3,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading Device Data...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
