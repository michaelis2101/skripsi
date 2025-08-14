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

            // Main Content
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    // Stats Overview
                    _buildStatsOverview(),
                    const SizedBox(height: 24),

                    // Devices Table
                    _buildDevicesTable(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorApp.lapisLazuli,
                    ColorApp.lapisLazuli.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: ColorApp.lapisLazuli.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.devices_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Devices Management',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: ColorApp.lapisLazuli,
                fontFamily: "Nunito",
              ),
            ),
          ],
        ),
        Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorApp.lapisLazuli,
                ColorApp.lapisLazuli.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ColorApp.lapisLazuli.withOpacity(0.3),
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
                Get.defaultDialog(
                  barrierDismissible: false,
                  title: "Add Device",
                  titleStyle: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    color: ColorApp.lapisLazuli,
                  ),
                  content: const NewDevDialog(),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                      "Add Device",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Nunito",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildStatsOverview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorApp.lapisLazuli.withOpacity(0.1),
            ColorApp.lapisLazuli.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorApp.lapisLazuli.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: ColorApp.lapisLazuli,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Manage your IoT devices, monitor status, and configure settings',
            style: TextStyle(
              fontSize: 16,
              color: ColorApp.lapisLazuli,
              fontFamily: "Nunito",
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  Widget _buildDevicesTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorApp.lapisLazuli,
                  ColorApp.lapisLazuli.withOpacity(0.9),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Device Name",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Nunito",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Device ID",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Nunito",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      "Status",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Nunito",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "User",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Nunito",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      "Actions",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Nunito",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Content
          StreamBuilder(
            stream: dbRef.orderByChild('user').equalTo(email).onValue,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                var devices = snapshot.data!.snapshot.value;

                if (devices == null) {
                  return _buildEmptyState();
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

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userDevice.length,
                  itemBuilder: (context, index) {
                    final device = userDevice[index];
                    return CustomTile(
                      deviceName: device["name"],
                      deviceId: device["deviceId"],
                      owner: device["owner"],
                      user: device["user"],
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return _buildErrorState();
              } else {
                return _buildLoadingState();
              }
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.devices_other_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Devices Found',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first IoT device to monitor and manage',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
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
            'Unable to load devices. Please check your connection and try again',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              color: Colors.red[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: ColorApp.lapisLazuli,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your devices...',
            style: TextStyle(
              color: ColorApp.lapisLazuli,
              fontSize: 16,
              fontFamily: "Nunito",
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
