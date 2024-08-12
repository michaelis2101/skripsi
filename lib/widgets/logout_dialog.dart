import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ta_web/classes/colors_cl.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
        width: 300,
        decoration: const BoxDecoration(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Logout'),
            Row(
              children: [
                InkWell(
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: ColorApp.lapisLazuli, width: 1),
                        borderRadius: BorderRadius.circular(100)),
                    child: const Text(
                      'No',
                      style: TextStyle(fontFamily: 'Nunito'),
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        border:
                            Border.all(color: ColorApp.lapisLazuli, width: 1),
                        borderRadius: BorderRadius.circular(100)),
                    child: const Text(
                      'Yes',
                      style: TextStyle(fontFamily: 'Nunito'),
                    ),
                  ),
                ),
              ],
            )
          ],
        ));
  }
}
