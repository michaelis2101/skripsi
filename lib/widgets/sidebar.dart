import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/services/auth_service.dart';
import 'package:ta_web/services/user_service.dart';
import 'package:ta_web/widgets/logout_dialog.dart';

class CustomSidebar extends StatelessWidget {
  //  final SidebarXController _cont;

  // const CustomSidebar({super.key, required this._cont}) : _cont = cont,super(key: key);
  const CustomSidebar({Key? key, required SidebarXController controller})
      : _controller = controller,
        super(key: key);
  final SidebarXController _controller;

  // User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
          selectedItemDecoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(color: Colors.white, fontFamily: "Nunito"),
          // hoverTextStyle: TextStyle(color: ColorApp.lapisLazuli),
          // selectedTextStyle: TextStyle(color: ColorApp.lapisLazuli),
          hoverTextStyle:
              const TextStyle(color: Colors.white, fontFamily: "Nunito"),
          itemPadding: const EdgeInsets.all(10),
          itemTextPadding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: ColorApp.lapisLazuli,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          selectedIconTheme: IconThemeData(color: ColorApp.lapisLazuli),
          selectedItemPadding: const EdgeInsets.all(10),
          selectedItemTextPadding: const EdgeInsets.all(10),
          selectedTextStyle:
              TextStyle(color: ColorApp.lapisLazuli, fontFamily: 'Nunito')),
      extendedTheme: const SidebarXTheme(width: 200),
      footerDivider: Divider(color: Colors.white.withOpacity(0.8), height: 1),
      headerBuilder: (context, extended) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
              child: SvgPicture.asset(
            '../assets/svg/logo_wh.svg',
            fit: BoxFit.scaleDown,
            width: 200,
            height: 100,
          )),
        );
      },
      items: const [
        SidebarXItem(
          icon: Icons.home,
          label: 'Home',
        ),
        SidebarXItem(icon: Icons.dashboard, label: 'Dashboard'),
        SidebarXItem(icon: Icons.list, label: 'Devices List'),
        SidebarXItem(icon: Icons.settings, label: 'Settings'),
        // SidebarXItem(
        //   icon: Icons.logout_outlined,
        //   label: 'Logout',
        //   onTap: () {
        //     // Get.dialog(const LogoutDialog());
        //     Auth().signOut();
        //   },
        // ),
      ],
    );
  }
}
