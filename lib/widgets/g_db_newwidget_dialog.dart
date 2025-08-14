import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ta_web/models/dashboard_model.dart';
import 'package:ta_web/services/dashboard_service.dart';
import 'package:uuid/uuid.dart';
import '../classes/colors_cl.dart';
import '../services/devices_service.dart';

class NewWidgetDialog extends StatefulWidget {
  // final Function(Map<String, dynamic>) onWidgetAdded;
  final String dashboardId;

  const NewWidgetDialog({super.key, required this.dashboardId});

  @override
  State<NewWidgetDialog> createState() => _NewWidgetDialogState();
}

class _NewWidgetDialogState extends State<NewWidgetDialog>
    with TickerProviderStateMixin {
  // Form controllers
  final TextEditingController widgetNameController = TextEditingController();
  final TextEditingController minValueCont = TextEditingController();
  final TextEditingController maxValueCont = TextEditingController();
  final DevicesService devicesService = DevicesService();

  // Animation controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Widget configuration
  Map<String, dynamic>? selectedDevice;
  String selectedDeviceName = '';
  String selectedDeviceId = '';
  String? selectedDeviceKey;
  String selectedWidgetType = 'String';
  Map<String, dynamic>? selectedValue;
  String dataType = 'Numeric'; // Default data type

  // Data lists
  List<Map<String, dynamic>> deviceList = [];
  List<String> selectedKeyList = [];
  List<String> widgetSelection = ['String', 'Switch', 'Gauge', 'Input'];

  // Loading states
  bool deviceListLoading = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDeviceList();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _slideAnimationController, curve: Curves.elasticOut),
    );

    _fadeAnimationController.forward();
    _slideAnimationController.forward();
  }

  // Helper method to safely convert Firebase data types
  Map<String, dynamic>? _convertFirebaseValue(dynamic value) {
    if (value == null) return null;

    if (value is Map) {
      // Convert any Map type to Map<String, dynamic>
      Map<String, dynamic> result = {};
      value.forEach((key, val) {
        if (key != null) {
          result[key.toString()] = val;
        }
      });
      return result;
    }

    return null;
  }

  Future<void> _loadDeviceList() async {
    setState(() {
      deviceListLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user?.email == null) {
        throw Exception('User not logged in');
      }

      // Get devices from Supabase
      final supabaseDevices = await devicesService.getDevices(user!.email!);

      // Get Firebase device data with values
      List<Map<String, dynamic>> devicesWithValues = [];

      for (var device in supabaseDevices) {
        final deviceId = device['id'].toString();
        final deviceName = device['device_name'] as String;

        try {
          // Get device value from Firebase
          final snapshot = await FirebaseDatabase.instance
              .ref('devices/$deviceId/value')
              .get();

          Map<String, dynamic> deviceData = {
            'id': deviceId,
            'name': deviceName,
            'value':
                snapshot.exists ? _convertFirebaseValue(snapshot.value) : null,
          };

          devicesWithValues.add(deviceData);
        } catch (e) {
          // Add device with null value if Firebase fails
          devicesWithValues.add({
            'id': deviceId,
            'name': deviceName,
            'value': null,
          });
        }
      }

      setState(() {
        deviceList = devicesWithValues;
        deviceListLoading = false;
      });
    } catch (e) {
      setState(() {
        deviceListLoading = false;
      });
      if (mounted) {
        _showErrorSnackBar('Failed to load devices: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: ColorApp.lapisLazuli,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    widgetNameController.dispose();
    minValueCont.dispose();
    maxValueCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxWidth: 600,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogHeader(),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWidgetNameField(),
                          const SizedBox(height: 20),
                          _buildDeviceSection(),
                          const SizedBox(height: 20),
                          _buildDataKeySection(),
                          const SizedBox(height: 20),
                          _buildWidgetTypeSection(),
                          const SizedBox(height: 20),
                          _buildMinMaxValuesSection(),
                          const SizedBox(height: 32),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorApp.lapisLazuli, ColorApp.lapisLazuli.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add_chart_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Widget',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create a new dashboard widget from your device data',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Nunito',
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.title_rounded, color: ColorApp.lapisLazuli, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Widget Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Nunito',
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            color: Colors.grey[50],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: widgetNameController,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            // onChanged: (value) {
            //   widgetNameController.text = value;
            // },
            decoration: InputDecoration(
              hintText: 'Enter widget name',
              hintStyle: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.grey[600],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(
                Icons.edit_rounded,
                color: ColorApp.lapisLazuli,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.devices_rounded, color: ColorApp.lapisLazuli, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Select Device',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Nunito',
                color: Colors.black87,
              ),
            ),
            if (deviceList.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ColorApp.lapisLazuli.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${deviceList.length} devices',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Nunito',
                    color: ColorApp.lapisLazuli,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDeviceDropdown(),
      ],
    );
  }

  Widget _buildDeviceDropdown() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        color: Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<Map<String, dynamic>>(
          isExpanded: true,
          value: selectedDevice,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedDevice = value;
                selectedDeviceName = value['name'] as String;
                selectedDeviceId = value['id'].toString();
                // Safely convert the value
                var rawValue = value['value'];
                selectedValue = _convertFirebaseValue(rawValue);
                selectedKeyList.clear();
                selectedDeviceKey = null;
              });

              // Only populate keys if value is not null and is a Map
              if (selectedValue != null &&
                  selectedValue is Map<String, dynamic>) {
                selectedValue!.forEach((key, val) {
                  selectedKeyList.add(key);
                });
              }
            }
          },
          items: deviceList
              .map((device) => DropdownMenuItem<Map<String, dynamic>>(
                    value: device,
                    enabled: true, // Allow all devices to be selected
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: device['value'] != null
                                ? ColorApp.lapisLazuli.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.devices_rounded,
                            size: 16,
                            color: device['value'] != null
                                ? ColorApp.lapisLazuli
                                : Colors.orange[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device['name'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w500,
                                  color: device['value'] != null
                                      ? Colors.black87
                                      : Colors.orange[800],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (device['value'] == null)
                                Text(
                                  'No data available - widget will show "No Data"',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Nunito',
                                    color: Colors.orange[600],
                                  ),
                                ),
                              if (device['value'] != null &&
                                  device['value'] is Map)
                                Text(
                                  '${(device['value'] as Map).length} data keys',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Nunito',
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          hint: deviceListLoading
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
                      'Loading devices...',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )
              : Text(
                  'Select a device',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
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
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            maxHeight: 300,
          ),
        ),
      ),
    );
  }

  Widget _buildDataKeySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.key_rounded, color: ColorApp.lapisLazuli, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Data Key',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Nunito',
                color: Colors.black87,
              ),
            ),
            if (selectedKeyList.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ColorApp.lapisLazuli.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${selectedKeyList.length} keys',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Nunito',
                    color: ColorApp.lapisLazuli,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDataKeyDropdown(),
      ],
    );
  }

  Widget _buildDataKeyDropdown() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        color: selectedKeyList.isEmpty ? Colors.grey[100] : Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          value: selectedDeviceKey,
          onChanged: selectedKeyList.isEmpty
              ? null
              : (String? newValue) {
                  setState(() {
                    selectedDeviceKey = newValue;
                  });
                },
          items: selectedKeyList.map((String key) {
            return DropdownMenuItem<String>(
              value: key,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ColorApp.lapisLazuli.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.data_object_rounded,
                      size: 16,
                      color: ColorApp.lapisLazuli,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    key,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          hint: Text(
            selectedKeyList.isEmpty
                ? 'Select a device first'
                : 'Select data key',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              color:
                  selectedKeyList.isEmpty ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: selectedKeyList.isEmpty
                  ? Colors.grey[400]
                  : ColorApp.lapisLazuli,
            ),
            iconSize: 24,
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.widgets_rounded, color: ColorApp.lapisLazuli, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Widget Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Nunito',
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildWidgetTypeDropdown(),
      ],
    );
  }

  Widget _buildWidgetTypeDropdown() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        color: Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          value: selectedWidgetType,
          onChanged: (String? newValue) {
            setState(() {
              selectedWidgetType = newValue!;
            });
          },
          items: widgetSelection.map((String type) {
            IconData icon;
            switch (type) {
              case 'String':
                icon = Icons.text_fields_rounded;
                break;
              case 'Switch':
                icon = Icons.toggle_on_rounded;
                break;
              case 'Gauge':
                icon = Icons.speed_rounded;
                break;
              case 'Input':
                icon = Icons.input_rounded;
                break;
              default:
                icon = Icons.widgets_rounded;
            }

            return DropdownMenuItem<String>(
              value: type,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ColorApp.lapisLazuli.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: ColorApp.lapisLazuli,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildMinMaxValuesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune_rounded, color: ColorApp.lapisLazuli, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Value Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Nunito',
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMinValueField()),
            const SizedBox(width: 16),
            Expanded(child: _buildMaxValueField()),
          ],
        ),
      ],
    );
  }

  Widget _buildMinValueField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum Value',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            color: Colors.grey[50],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: minValueCont,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.grey[600],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(
                Icons.arrow_downward_rounded,
                color: ColorApp.lapisLazuli,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaxValueField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maximum Value',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            color: Colors.grey[50],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: maxValueCont,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '100',
              hintStyle: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.grey[600],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(
                Icons.arrow_upward_rounded,
                color: ColorApp.lapisLazuli,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    bool isFormValid =
        widgetNameController.text.isNotEmpty && selectedDevice != null;

    // Show warning if device has no data keys
    // bool hasDataKeys = selectedDevice != null &&
    //     selectedDevice!['value'] != null &&
    //     selectedDeviceKey != null;

    return Column(
      children: [
        // Warning message for devices without data
        if (selectedDevice != null && selectedDevice!['value'] == null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              border: Border.all(color: Colors.orange[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This device has no data. The widget will display "No Data" until the device sends data.',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Nunito',
                      color: Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      isFormValid && !isSubmitting ? _submitWidget : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isFormValid ? ColorApp.lapisLazuli : Colors.grey[300],
                    foregroundColor: Colors.white,
                    elevation: isFormValid ? 3 : 0,
                    shadowColor: ColorApp.lapisLazuli.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Add Widget',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitWidget() async {
    if (widgetNameController.text.isEmpty || selectedDevice == null) {
      _showErrorSnackBar('Please fill in all required fields');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // final widgetData = {
      //   'name': widgetNameController.text.trim(),
      //   'deviceName': selectedDeviceName,
      //   'deviceId': selectedDeviceId,
      //   'dataKey':
      //       selectedDeviceKey ?? 'no_data', // Use placeholder if no data key
      //   'widgetType': selectedWidgetType,
      //   'device': selectedDevice,
      //   'hasData': selectedDeviceKey != null,
      // };

      // widget.onWidgetAdded(widgetData);

      String widgetId = const Uuid().v4();
      DashboardModel newWidget = DashboardModel(
        dataKey: selectedDeviceKey!,
        deviceID: selectedDeviceId,
        widgetName: widgetNameController.text,
        // widgetName: widgetNameCont.text,
        widgetType: selectedWidgetType,
        widgetID: widgetId,
        minVal: minValueCont.text.isEmpty ? 0 : double.parse(minValueCont.text),
        maxVal:
            maxValueCont.text.isEmpty ? 100 : double.parse(maxValueCont.text),
      );

      // addNewWidget(
      //     newWidget,
      //     selectedDataType.toString() == 'null'
      //         ? 'Numeric'
      //         : selectedDataType!.toString());
      await DashboardService().createNewWidget(
        widget.dashboardId,
        newWidget,
        dataType,
      );

      if (selectedDeviceKey != null) {
        _showSuccessSnackBar('Widget added successfully!');
      } else {
        _showSuccessSnackBar(
            'Widget added! It will show data when device sends it.');
      }

      // Small delay before closing to show success message
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to add widget: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }
}
