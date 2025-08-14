import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:ta_web/services/auth_service.dart';
import 'package:ta_web/views/devices_list.dart';
import 'package:ta_web/views/global_dashboard.dart';
import 'package:ta_web/views/home_view.dart';
import 'package:ta_web/views/setting_view.dart';
import 'package:ta_web/widgets/logout_dialog.dart';
import 'package:ta_web/widgets/sidebar.dart';

class ScreenHandler extends StatefulWidget {
  const ScreenHandler({super.key});

  @override
  State<ScreenHandler> createState() => _ScreenHandlerState();
}

class _ScreenHandlerState extends State<ScreenHandler> {
  final _controller = SidebarXController(selectedIndex: 0, extended: false);
  // final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Builder(builder: (context) {
      final isSmallScreen = MediaQuery.of(context).size.width < 600;
      return Scaffold(
          key: _key,
          appBar: isSmallScreen
              ? AppBar(
                  title: const Text('FDSM'),
                  leading: IconButton(
                    onPressed: () {
                      _key.currentState?.openDrawer();
                    },
                    icon: const Icon(Icons.menu),
                  ),
                )
              : null,
          drawer: CustomSidebar(controller: _controller),
          body: Row(
            children: [
              if (!isSmallScreen) CustomSidebar(controller: _controller),
              Expanded(
                  child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    switch (_controller.selectedIndex) {
                      case 0:
                        _key.currentState?.closeDrawer();
                        return const HomeView();
                      case 1:
                        _key.currentState?.closeDrawer();
                        return const GlobalDashboard();
                      case 2:
                        _key.currentState?.closeDrawer();
                        return const DevicesList();
                      case 3:
                        _key.currentState?.closeDrawer();
                        return const SettingView();
                      // return const Center(
                      //   child: Text(
                      //     'Settings',
                      //     style: TextStyle(color: Colors.black, fontSize: 40),
                      //   ),
                      // );
                      // case 4:
                      //   _key.currentState?.closeDrawer();
                      //   return const Center(
                      //     child: Text(
                      //       'Logout',
                      //       style: TextStyle(color: Colors.black, fontSize: 40),
                      //     ),
                      //   );
                      // return ListTile(
                      //   onTap: () {
                      //     Get.dialog(const LogoutDialog());
                      //   },
                      // );
                      default:
                        _key.currentState?.openDrawer();
                        return const Center(
                          child: Text(
                            'Home',
                            style: TextStyle(color: Colors.black, fontSize: 40),
                          ),
                        );
                    }
                  },
                ),
              ))
            ],
          ));
    }));
  }
}
