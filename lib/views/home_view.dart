import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_network/image_network.dart';
import 'package:ta_web/classes/colors_cl.dart';
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
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: ColorApp.lapisLazuli,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading your dashboard...',
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
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 32),

                  // Welcome Card
                  _buildWelcomeCard(),
                  const SizedBox(height: 32),

                  // Main Content Grid
                  _buildMainContent(),
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
            Icons.home_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: ColorApp.lapisLazuli,
            fontFamily: "Nunito",
          ),
        ),
        const Spacer(),
        // _buildNotificationButton(),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  // Widget _buildNotificationButton() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.1),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: IconButton(
  //       onPressed: () {},
  //       icon: Icon(
  //         Icons.notifications_outlined,
  //         color: ColorApp.lapisLazuli,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorApp.lapisLazuli,
            ColorApp.lapisLazuli.withValues(alpha: 0.8),
            ColorApp.lapisLazuli.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ColorApp.lapisLazuli.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildProfileImage(),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontFamily: "Nunito",
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userInfo['username'] ?? 'User',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: "Nunito",
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'What can we assist you with today?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontFamily: "Nunito",
                  ),
                ),
              ],
            ),
          ),
          _buildStatsOverview(),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildProfileImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: SizedBox(
          height: 140,
          width: 140,
          child: userSetting['profile_pic'] != null
              ? ImageNetwork(
                  image: userSetting['profile_pic'],
                  height: 140,
                  width: 140,
                  borderRadius: BorderRadius.circular(17),
                )
              : ImageNetwork(
                  borderRadius: BorderRadius.circular(17),
                  image:
                      'https://firebasestorage.googleapis.com/v0/b/project-st-iot.appspot.com/o/default_asset%2Fdefaultpfp.png?alt=media&token=882c5086-0c64-4285-b452-ca0b021707b6',
                  height: 140,
                  width: 140,
                ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Column(
      children: [
        _buildStatItem('Dashboards', dashboardList.length.toString(),
            Icons.dashboard_outlined),
        const SizedBox(height: 16),
        _buildStatItem(
            'Devices', devicesList.length.toString(), Icons.devices_outlined),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: "Nunito",
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontFamily: "Nunito",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboards Section
            Expanded(
              child: _buildDashboardsCard(),
            ),
            const SizedBox(width: 16),

            // Devices Section
            Expanded(
              child: _buildDevicesCard(),
            ),
            const SizedBox(width: 16),

            // Settings Section
            Expanded(
              child: _buildSettingsCard(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDevicesCard() {
    return Container(
      height: 500,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorApp.lapisLazuli.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.devices_outlined,
                    color: ColorApp.lapisLazuli,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Devices',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: ColorApp.lapisLazuli,
                    fontFamily: "Nunito",
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[200], height: 1),
          Expanded(
            child: _buildDevicesList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 150.ms);
  }

  Widget _buildDevicesList() {
    if (devicesList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: SvgPicture.asset(
                '../assets/svg/notfound.svg',
                height: 80,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Devices Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontFamily: "Nunito",
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect your first device to get started',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: "Nunito",
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: devicesList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        var device = devicesList[index];
        return _buildDeviceItem(device);
      },
    );
  }

  Widget _buildDeviceItem(Map<String, dynamic> device) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: StreamBuilder(
          stream: FirebaseDatabase.instance
              .ref()
              .child('devices/${device['id']}/status/status')
              .onValue,
          builder: (context, AsyncSnapshot snapshot) {
            Widget statusIndicator;
            if (snapshot.hasData) {
              var status = snapshot.data.snapshot.value;
              if (status == null || status == 'offline') {
                statusIndicator = Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.circle,
                    color: Colors.red[600],
                    size: 12,
                  ),
                );
              } else {
                statusIndicator = Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.circle,
                    color: Colors.green[600],
                    size: 12,
                  ),
                );
              }
            } else {
              statusIndicator = Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.circle,
                  color: Colors.grey[400],
                  size: 12,
                ),
              );
            }

            return Tooltip(
              message: snapshot.hasData
                  ? (snapshot.data.snapshot.value == null ||
                          snapshot.data.snapshot.value == 'offline'
                      ? 'Offline'
                      : 'Online')
                  : 'Loading...',
              child: statusIndicator,
            );
          },
        ),
        title: Text(
          device['device_name'],
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: "Nunito",
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap: () {
          Get.to(
            transition: Transition.rightToLeftWithFade,
            DeviceDetail(
              deviceName: device['device_name'],
              deviceID: device['id'],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      height: 500,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorApp.lapisLazuli.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: ColorApp.lapisLazuli,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: ColorApp.lapisLazuli,
                    fontFamily: "Nunito",
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[200], height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // _buildSettingsItem(
                  //   icon: Icons.person_outline,
                  //   title: 'Profile',
                  //   subtitle: 'Manage your account',
                  //   onTap: () {},
                  // ),
                  // const SizedBox(height: 12),
                  // _buildSettingsItem(
                  //   icon: Icons.notifications_outlined,
                  //   title: 'Notifications',
                  //   subtitle: 'Configure alerts',
                  //   onTap: () {},
                  // ),
                  // const SizedBox(height: 12),
                  // _buildSettingsItem(
                  //   icon: Icons.security_outlined,
                  //   title: 'Security',
                  //   subtitle: 'Privacy & security',
                  //   onTap: () {},
                  // ),
                  // const SizedBox(height: 12),
                  // Divider(color: Colors.grey[200]),
                  // const SizedBox(height: 12),
                  _buildSettingsItem(
                    icon: Icons.logout_outlined,
                    title: 'Sign Out',
                    subtitle: 'Logout from your account',
                    onTap: _showLogoutDialog,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 250.ms);
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red[50]
                : ColorApp.lapisLazuli.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red[600] : ColorApp.lapisLazuli,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: "Nunito",
            color: isDestructive ? Colors.red[600] : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: "Nunito",
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showDeleteDashboardDialog(Map<String, dynamic> dashboard) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 300, // Make dialog width shorter
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.warning_outlined,
                  color: Colors.red[600],
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Delete Dashboard',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ColorApp.lapisLazuli,
                  fontFamily: "Nunito",
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "${dashboard['dashboard_name']}"?\nThis action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: "Nunito",
                ),
              ),
              const SizedBox(height: 24),
              // Column instead of Row for buttons
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Get.back(),
                    child: const Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: "Nunito",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12), // Vertical spacing between buttons
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      try {
                        await DashboardService()
                            .deleteDashboard(dashboard['id']);
                        await refreshDashboard();
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Dashboard deleted successfully',
                          backgroundColor: Colors.green[50],
                          colorText: Colors.green[700],
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      } catch (e) {
                        Get.back();
                        Get.snackbar(
                          'Error',
                          'Failed to delete dashboard',
                          backgroundColor: Colors.red[50],
                          colorText: Colors.red[700],
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      }
                    },
                    child: const Center(
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Nunito",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 300, // Limit the width to make dialog smaller
          padding: const EdgeInsets.all(20), // Reduce padding
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12), // Reduce padding
                decoration: BoxDecoration(
                  color: ColorApp.lapisLazuli.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.logout_outlined,
                  color: ColorApp.lapisLazuli,
                  size: 28, // Slightly smaller icon
                ),
              ),
              const SizedBox(height: 16), // Reduced spacing
              Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 20, // Slightly smaller text
                  fontWeight: FontWeight.w700,
                  color: ColorApp.lapisLazuli,
                  fontFamily: "Nunito",
                ),
              ),
              const SizedBox(height: 8), // Reduced spacing
              Text(
                'Are you sure you want to sign out of your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14, // Smaller text
                  color: Colors.grey[600],
                  fontFamily: "Nunito",
                ),
              ),
              const SizedBox(height: 16), // Reduced spacing

              // Cancel button
              Container(
                height: 45, // Slightly shorter button
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Get.back(),
                    child: const Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: "Nunito",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10), // Space between buttons

              // Sign Out button
              Container(
                height: 45, // Slightly shorter button
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorApp.lapisLazuli,
                      ColorApp.lapisLazuli.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      try {
                        Auth().signOut();
                        Get.back();
                      } catch (e) {
                        print(e);
                        Get.back();
                      }
                    },
                    child: const Center(
                      child: Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Nunito",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardsCard() {
    return Container(
      height: 500,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorApp.lapisLazuli.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.dashboard_outlined,
                    color: ColorApp.lapisLazuli,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Dashboards',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: ColorApp.lapisLazuli,
                    fontFamily: "Nunito",
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[200], height: 1),
          Expanded(
            child: _buildDashboardsList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  Widget _buildDashboardsList() {
    if (isDashboardLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: ColorApp.lapisLazuli),
            const SizedBox(height: 16),
            Text(
              'Loading dashboards...',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: "Nunito",
              ),
            ),
          ],
        ),
      );
    }

    if (dashboardList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: SvgPicture.asset(
                '../assets/svg/notfound.svg',
                height: 80,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Dashboards Created',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontFamily: "Nunito",
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first dashboard to get started',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: "Nunito",
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: dashboardList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        var db = dashboardList[index];
        return _buildDashboardItem(db);
      },
    );
  }

  Widget _buildDashboardItem(Map<String, dynamic> db) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorApp.lapisLazuli.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.analytics_outlined,
            color: ColorApp.lapisLazuli,
            size: 20,
          ),
        ),
        title: Text(
          db['dashboard_name'],
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: "Nunito",
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteDashboardDialog(db);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red[600], size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontFamily: "Nunito",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to dashboard
        },
      ),
    );
  }
}
