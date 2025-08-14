import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/classes/input_cl.dart';
import 'package:ta_web/services/dashboard_service.dart';
import 'package:ta_web/widgets/info_dialog.dart';

class GlobalDashBoardCard extends StatelessWidget {
  String widgetName,
      dataKey,
      dataType,
      widgetType,
      widgetId,
      deviceId,
      deviceName,
      dashboardId;
  String? unit;
  double minVal, maxVal;
  GlobalDashBoardCard(
      {super.key,
      required this.dashboardId,
      required this.widgetName,
      required this.dataKey,
      required this.dataType,
      required this.widgetType,
      required this.widgetId,
      required this.deviceId,
      required this.deviceName,
      required this.minVal,
      required this.maxVal,
      this.unit});

  @override
  Widget build(BuildContext context) {
    final valCont = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref()
        .child('devices/$deviceId/value/$dataKey');

    void updateSwitchValue(bool value) {
      int intValue = value ? 1 : 0;
      dbRef.set(intValue);
    }

    TextEditingController newNameCont = TextEditingController();
    TextEditingController unitController = TextEditingController();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Modern Header
          _buildWidgetHeader(newNameCont, unitController),

          // Widget Content
          Expanded(
            child: _buildWidgetContent(valCont, formKey, dbRef),
          )
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildWidgetHeader(
      TextEditingController newNameCont, TextEditingController unitController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorApp.lapisLazuli,
            ColorApp.lapisLazuli.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getWidgetIcon(),
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widgetName,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '($dataKey)',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDeviceStatus(),
              ],
            ),
          ),
          _buildActionMenu(newNameCont, unitController),
        ],
      ),
    );
  }

  Widget _buildActionMenu(
      TextEditingController newNameCont, TextEditingController unitController) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.more_vert_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      elevation: 8,
      onSelected: (value) {
        _handleMenuAction(value, newNameCont, unitController);
      },
      itemBuilder: (context) => [
        _buildPopupMenuItem(
          value: 'unit',
          icon: Icons.straighten_outlined,
          title: 'Add Unit',
          iconColor: Colors.blue,
        ),
        _buildPopupMenuItem(
          value: 'info',
          icon: Icons.info_outline_rounded,
          title: 'Widget Info',
          iconColor: Colors.green,
        ),
        _buildPopupMenuItem(
          value: 'rename',
          icon: Icons.edit_outlined,
          title: 'Rename',
          iconColor: Colors.orange,
        ),
        _buildPopupMenuItem(
          value: 'delete',
          icon: Icons.delete_outline_rounded,
          title: 'Delete',
          iconColor: Colors.red,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String title,
    required Color iconColor,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceStatus() {
    return StreamBuilder(
      stream: FirebaseDatabase.instance
          .ref()
          .child('devices/$deviceId/status/status')
          .onValue,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          var status = snapshot.data.snapshot.value;
          bool isOnline = status != null && status != 'offline';

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isOnline
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOnline
                    ? Colors.green.withValues(alpha: 0.3)
                    : Colors.red.withValues(alpha: 0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // const SizedBox(width: 6),
                  // Text(
                  //   isOnline ? 'Online' : 'Offline',
                  //   style: const TextStyle(
                  //     color: Colors.white,
                  //     fontFamily: 'Nunito',
                  //     fontSize: 12,
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'N/A',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildWidgetContent(TextEditingController valCont,
      GlobalKey<FormState> formKey, DatabaseReference dbRef) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: StreamBuilder(
        stream: dbRef.onValue,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            var value = snapshot.data.snapshot.value;

            if (value == null) {
              return _buildNoDataState();
            }

            switch (widgetType) {
              case 'String':
                return _buildStringWidget(value);
              case 'Gauge':
                return _buildGaugeWidget(value);
              case 'Switch':
                return _buildSwitchWidget(value, dbRef);
              case 'Input':
                return _buildInputWidget(value, valCont, formKey, dbRef);
              default:
                return _buildDefaultWidget(value);
            }
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else {
            return _buildLoadingState();
          }
        },
      ),
    );
  }

  IconData _getWidgetIcon() {
    switch (widgetType) {
      case 'String':
        return Icons.text_fields_rounded;
      case 'Gauge':
        return Icons.speed_rounded;
      case 'Switch':
        return Icons.toggle_on_rounded;
      case 'Input':
        return Icons.input_rounded;
      default:
        return Icons.widgets_rounded;
    }
  }

  void _handleMenuAction(String value, TextEditingController newNameCont,
      TextEditingController unitController) {
    switch (value) {
      case 'unit':
        _showUnitDialog(unitController);
        break;
      case 'info':
        _showInfoDialog();
        break;
      case 'rename':
        _showRenameDialog(newNameCont);
        break;
      case 'delete':
        _showDeleteDialog();
        break;
    }
  }

  void _showUnitDialog(TextEditingController unitController) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.straighten_outlined,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Add/Change Units',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ColorApp.lapisLazuli,
                  fontFamily: "Nunito",
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: unitController,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: "Nunito",
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    hintText: 'Enter unit (e.g., °C, %, kg)',
                    prefixIcon: Icon(Icons.straighten_outlined,
                        color: ColorApp.lapisLazuli),
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: "Nunito",
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: ColorApp.lapisLazuli, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            unitController.clear();
                            Get.back();
                          },
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 50,
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
                          onTap: () async {
                            if (unitController.text.isEmpty) {
                              Get.snackbar(
                                'Warning',
                                'Unit cannot be empty',
                                backgroundColor: Colors.orange[50],
                                colorText: Colors.orange[700],
                                icon: Icon(Icons.warning_outlined,
                                    color: Colors.orange[700]),
                                snackPosition: SnackPosition.TOP,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                              return;
                            }

                            try {
                              await DashboardService().changeWidgetUnit(
                                dashboardId,
                                widgetId,
                                unitController.text,
                              );
                              Get.back();
                              Get.snackbar(
                                'Success',
                                'Unit updated successfully',
                                backgroundColor: Colors.green[50],
                                colorText: Colors.green[700],
                                icon: Icon(Icons.check_circle_outline,
                                    color: Colors.green[700]),
                                snackPosition: SnackPosition.TOP,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                            } catch (e) {
                              print(e);
                              Get.snackbar(
                                'Error',
                                'Failed to update unit',
                                backgroundColor: Colors.red[50],
                                colorText: Colors.red[700],
                                icon: Icon(Icons.error_outline,
                                    color: Colors.red[700]),
                                snackPosition: SnackPosition.TOP,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                            } finally {
                              unitController.clear();
                            }
                          },
                          child: const Center(
                            child: Text(
                              'Update',
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.green,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Widget Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ColorApp.lapisLazuli,
                  fontFamily: "Nunito",
                ),
              ),
              const SizedBox(height: 20),
              InfoDialog(
                widgetId: widgetId.toString(),
                dataKey: dataKey.toString(),
                dataType: dataType.toString(),
                deviceName: deviceName.toString(),
                widgetName: widgetName.toString(),
                widgetType: widgetType.toString(),
                maxGauge: maxVal,
                minGauge: minVal,
                deviceID: deviceId.toString(),
              ),
              const SizedBox(height: 20),
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
                        'Close',
                        style: TextStyle(
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

  void _showRenameDialog(TextEditingController newNameCont) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Colors.orange,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Rename Widget',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ColorApp.lapisLazuli,
                  fontFamily: "Nunito",
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: newNameCont,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: "Nunito",
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    hintText: 'Enter new widget name',
                    prefixIcon: Icon(Icons.widgets_outlined,
                        color: ColorApp.lapisLazuli),
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: "Nunito",
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: ColorApp.lapisLazuli, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            newNameCont.clear();
                            Get.back();
                          },
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 50,
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
                          onTap: () async {
                            if (newNameCont.text.isEmpty) {
                              Get.snackbar(
                                'Warning',
                                'Widget name cannot be empty',
                                backgroundColor: Colors.orange[50],
                                colorText: Colors.orange[700],
                                icon: Icon(Icons.warning_outlined,
                                    color: Colors.orange[700]),
                                snackPosition: SnackPosition.TOP,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                              return;
                            }

                            try {
                              await DashboardService().renameDashboardWidget(
                                dashboardId,
                                widgetId,
                                newNameCont.text.toString(),
                              );
                              Get.back();
                              Get.snackbar(
                                'Success',
                                'Widget renamed successfully',
                                backgroundColor: Colors.green[50],
                                colorText: Colors.green[700],
                                icon: Icon(Icons.check_circle_outline,
                                    color: Colors.green[700]),
                                snackPosition: SnackPosition.TOP,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                            } catch (e) {
                              print(e);
                              Get.snackbar(
                                'Error',
                                'Failed to rename widget',
                                backgroundColor: Colors.red[50],
                                colorText: Colors.red[700],
                                icon: Icon(Icons.error_outline,
                                    color: Colors.red[700]),
                                snackPosition: SnackPosition.TOP,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                            } finally {
                              newNameCont.clear();
                            }
                          },
                          child: const Center(
                            child: Text(
                              'Rename',
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red[600],
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Delete Widget',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.red[600],
                  fontFamily: "Nunito",
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to delete "$widgetName"? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: "Nunito",
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 50,
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
                                  .deleteWidget(widgetId, dashboardId);
                              Get.back();
                              Get.snackbar(
                                'Success',
                                'Widget deleted successfully',
                                backgroundColor: Colors.green[50],
                                colorText: Colors.green[700],
                                icon: Icon(Icons.check_circle_outline,
                                    color: Colors.green[700]),
                                snackPosition: SnackPosition.TOP,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                            } catch (e) {
                              print(e);
                              Get.snackbar(
                                'Error',
                                'Failed to delete widget',
                                backgroundColor: Colors.red[50],
                                colorText: Colors.red[700],
                                icon: Icon(Icons.error_outline,
                                    color: Colors.red[700]),
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.data_usage_outlined,
              size: 32,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Data Found',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Waiting for device data',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStringWidget(dynamic value) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value.toString(),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: ColorApp.lapisLazuli,
            ),
          ),
          if (unit != null) ...[
            const SizedBox(height: 8),
            Text(
              unit.toString(),
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildGaugeWidget(dynamic value) {
    return Center(
      child: SfRadialGauge(
        enableLoadingAnimation: true,
        axes: <RadialAxis>[
          RadialAxis(
            annotations: [
              GaugeAnnotation(
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        color: ColorApp.lapisLazuli,
                      ),
                    ),
                    if (unit != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        unit.toString(),
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ],
                ),
              )
            ],
            minimum: minVal,
            maximum: maxVal,
            pointers: <GaugePointer>[
              RangePointer(
                value: (value is double || value is int) ? value : 0,
                enableAnimation: true,
                color: ColorApp.lapisLazuli,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSwitchWidget(dynamic value, DatabaseReference dbRef) {
    bool switchValue = (value as double) > 0;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: AnimatedToggleSwitch.dual(
          current: switchValue,
          first: false,
          second: true,
          height: 120,
          indicatorSize: const Size.fromHeight(100),
          borderWidth: 6,
          iconBuilder: (value) => Icon(
            Icons.power_settings_new_rounded,
            size: 32,
            color: value == false ? Colors.red[600] : Colors.green[600],
          ),
          textBuilder: (value) => Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                value == false ? 'OFF' : 'ON',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          styleBuilder: (value) => ToggleStyle(
            backgroundColor:
                value == false ? Colors.red[400] : Colors.green[500],
            indicatorColor: Colors.white,
          ),
          style: ToggleStyle(
            borderColor: Colors.transparent,
            borderRadius: BorderRadius.circular(60),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            indicatorBorderRadius: BorderRadius.circular(50),
          ),
          onChanged: (value) {
            int intValue = value ? 1 : 0;
            dbRef.set(intValue);
          },
        ),
      ),
    );
  }

  Widget _buildInputWidget(dynamic value, TextEditingController valCont,
      GlobalKey<FormState> formKey, DatabaseReference dbRef) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: valCont,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Data cannot be empty';
                  }
                  if (dataType == 'Numeric' &&
                      !RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                inputFormatters: (dataType == 'Numeric' ||
                        value.runtimeType == int ||
                        value.runtimeType == double)
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : [],
                keyboardType: dataType == 'Numeric'
                    ? TextInputType.number
                    : TextInputType.text,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: Icon(
                    dataType == 'Numeric'
                        ? Icons.numbers_rounded
                        : Icons.text_fields_rounded,
                    color: ColorApp.lapisLazuli,
                  ),
                  hintText: 'Enter ${dataType.toLowerCase()} value',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontFamily: "Nunito",
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: ColorApp.lapisLazuli, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            // const SizedBox(height: 12),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            //   decoration: BoxDecoration(
            //     color: Colors.blue[50],
            //     borderRadius: BorderRadius.circular(8),
            //     border: Border.all(color: Colors.blue[200]!),
            //   ),
            //   child: Text(
            //     'Data Type: ${value.runtimeType == int ? 'Numeric' : dataType}',
            //     style: TextStyle(
            //       fontSize: 12,
            //       color: Colors.blue[700],
            //       fontFamily: 'Nunito',
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            // ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 48,
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
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      try {
                        if (dataType == 'Numeric') {
                          dbRef.set(double.parse(valCont.text));
                        } else {
                          dbRef.set(valCont.text);
                        }
                        valCont.clear();
                        Get.snackbar(
                          'Success',
                          'Value submitted successfully',
                          backgroundColor: Colors.green[50],
                          colorText: Colors.green[700],
                          icon: Icon(Icons.check_circle_outline,
                              color: Colors.green[700]),
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                          duration: const Duration(seconds: 2),
                        );
                      } catch (e) {
                        print(e);
                        Get.snackbar(
                          'Error',
                          'Failed to submit value',
                          backgroundColor: Colors.red[50],
                          colorText: Colors.red[700],
                          icon:
                              Icon(Icons.error_outline, color: Colors.red[700]),
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      }
                    }
                  },
                  child: const Center(
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
    );
  }

  Widget _buildDefaultWidget(dynamic value) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.widgets_outlined,
              size: 32,
              color: Colors.grey[500],
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 32,
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Data',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Please try again',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              color: Colors.red[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: ColorApp.lapisLazuli,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading data...',
            style: TextStyle(
              color: ColorApp.lapisLazuli,
              fontSize: 14,
              fontFamily: "Nunito",
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
