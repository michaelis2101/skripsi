import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/services/dashboard_service.dart';
import 'package:uuid/uuid.dart';

class NewDashboardDialog extends StatefulWidget {
  final Future<void> Function() refreshDashboardList;

  NewDashboardDialog({super.key, required this.refreshDashboardList});

  @override
  State<NewDashboardDialog> createState() => _NewDashboardDialogState();
}

class _NewDashboardDialogState extends State<NewDashboardDialog> {
  TextEditingController dashboardNameCont = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  bool isLoading = false;

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

  Future<void> createDashboardAndRefreshList() async {
    // final supabase = sb.;
    String dashboardID = const Uuid().v4();

    if (dashboardNameCont.text.isEmpty) {
      Get.snackbar("Error", "Dashboard Name cannot be empty");
    } else {
      setState(() {
        isLoading = true;
      });
      try {
        await DashboardService().createNewDashboard(
            dashboardID, dashboardNameCont.text, user!.email!);

        await widget.refreshDashboardList();
      } catch (e) {
        Get.snackbar('Error', e.toString());
        rethrow;
      } finally {
        setState(() {
          isLoading = false;
        });
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * 0.3,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Name',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: dashboardNameCont,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                prefixIconColor: ColorApp.lapisLazuli,
                labelStyle: const TextStyle(color: Colors.grey),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                disabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                // hintText: 'Pin Title',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            if (isLoading)
              SizedBox(
                height: 110,
                child: Center(
                  child: CircularProgressIndicator(
                    color: ColorApp.lapisLazuli,
                  ),
                ),
              ),
            if (!isLoading)
              Column(
                children: [
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () async {
                          String dashboardID = generateDashboardId();

                          if (dashboardNameCont.text.isEmpty) {
                            Get.snackbar(
                                "Error", "Dashboard Name cannot be empty");
                          } else {
                            setState(() {
                              isLoading = true;
                            });
                            try {
                              await createDashboardAndRefreshList();
                              // await DashboardService().createNewDashboard(
                              //     dashboardID,
                              //     dashboardNameCont.text,
                              //     user!.email!);

                              // widget.refreshDashboardList?.call();
                              // await createDashboardAndRefreshList();
                            } catch (e) {
                              Get.snackbar('Error', e.toString());
                              rethrow;
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ColorApp.lapisLazuli,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: const Text(
                          'Create New Dashboard',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        )),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(
                                width: 1, color: ColorApp.lapisLazuli),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                        onPressed: () => Get.back(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                              color: ColorApp.lapisLazuli, fontSize: 20),
                        )),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
