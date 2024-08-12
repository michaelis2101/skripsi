import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_web/models/chart_models.dart';
import 'package:ta_web/models/dynamicdevice_model.dart';
import 'package:ta_web/models/log_model.dart';
import 'package:ta_web/models/newdevice_model.dart';
import 'package:ta_web/models/note_model.dart';
import 'package:ta_web/models/widget_model.dart';

class DevicesService {
  final supabase = Supabase.instance.client;

  Future<void> createDynamicDevice(DynamicDevice param) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("devices/${param.deviceId}");

    try {
      await ref.set({
        'owner': param.owner,
        'user': param.user,
        'deviceName': param.deviceName,
        'value': {},
        'widgets': {}
      });
    } catch (e) {
      // print(e);
    } finally {
      await supabase.from('devices').insert({
        'id': param.deviceId,
        'device_name': param.deviceName,
        'owner': param.user,
        'user': param.owner,
        'status': 'Waiting Value'
      });
    }
  }

  Future<void> changeDeviceName(String deviceId, String newName) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("devices/$deviceId");

    try {
      await ref.update({'deviceName': newName});
    } catch (e) {
      print(3);
    } finally {
      await supabase
          .from('devices')
          .update({'device_name': newName}).eq('id', deviceId);
    }
  }

  // Future<void> deleteDevice(String deviceID) async {
  //   DatabaseReference ref = FirebaseDatabase.instance.ref("devices/$deviceID");
  //   try {
  //     await ref.remove();
  //   } catch (e) {
  //     print(e);
  //   } finally {
  //     await supabase.from('devices').delete().eq('id', deviceID);
  //     await supabase.from('device_widgets').delete().eq('device_id', deviceID);
  //     await supabase.from('device_notes').delete().eq('device_id', deviceID);
  //     await supabase.from('device_log').delete().eq('device_id', deviceID);
  //   }
  // }

  Future<void> deleteDevice(String deviceID) async {
    DatabaseReference deviceRef =
        FirebaseDatabase.instance.ref("devices/$deviceID");
    DatabaseReference dashboardsRef =
        FirebaseDatabase.instance.ref("dashboards");

    try {
      // Remove the device from the 'devices' node
      await deviceRef.remove();

      // Find and remove widgets in 'dashboards' that reference the deleted deviceID
      final dashboardsSnapshot = await dashboardsRef.get();
      if (dashboardsSnapshot.exists) {
        final dashboards = dashboardsSnapshot.value as Map<dynamic, dynamic>;
        for (final dashboardId in dashboards.keys) {
          final widgetsRef = dashboardsRef.child("$dashboardId/widgets");
          final widgetsSnapshot = await widgetsRef.get();
          if (widgetsSnapshot.exists) {
            final widgets = widgetsSnapshot.value as Map<dynamic, dynamic>;
            for (final widgetId in widgets.keys) {
              final widget = widgets[widgetId];
              if (widget["deviceId"] == deviceID) {
                await widgetsRef.child(widgetId).remove();
              }
            }
          }
        }
      }
    } catch (e) {
      print(e);
    } finally {
      await supabase.from('devices').delete().eq('id', deviceID);
      await supabase.from('device_widgets').delete().eq('device_id', deviceID);
      await supabase.from('device_notes').delete().eq('device_id', deviceID);
      await supabase.from('device_log').delete().eq('device_id', deviceID);
    }
  }

  Future<void> updateDeviceStatus(String deviceId) async {
    try {
      await supabase
          .from('devices')
          .update({'status': 'Connected'}).match({'id': deviceId});
    } catch (e) {
      // print(e);
    }
  }

  Future<PostgrestList> getDeviceInfo(String deviceId) async {
    try {
      var response = await supabase.from('devices').select().eq('id', deviceId);
      // print(response);

      return response;
    } catch (e) {
      // print(e);
      rethrow;
    }
  }

  Future<PostgrestList> getDevices(String email) async {
    try {
      var response = await supabase.from('devices').select().eq('user', email);
      // print(response);

      return response;
    } catch (e) {
      // print(e);
      rethrow;
    }
  }

  //==========================================================================
  Future<void> createNewWidget(WidgetModel param, String deviceId,
      String widgetId, String widgetName, String dataType) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("devices/$deviceId/widgets/$widgetId");

    try {
      await ref.set({
        'widgetName': widgetName,
        'key': param.key,
        'type': param.type,
        'minValue': param.minValue,
        'maxValue': param.maxValue,
        'dataType': dataType
      });
    } catch (e) {
      print(e);
    } finally {
      // await supabase.from('device_widget').insert({
      //   'id': widgetId,
      //   'selected_key': param.key,
      //   'type': param.type,
      //   'min_value': int.parse(param.minValue.toString()),
      //   'max_value': int.parse(param.maxValue.toString()),
      //   'widget_name': widgetName,
      //   'device_id': deviceId
      // });
    }
  }

  Future<void> createNewChart(
      String title, String deviceId, String chartId) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("devices/$deviceId/charts/$chartId");
    try {
      await ref.set({
        'title': title,
        'X-Axis': 'created_at',
        // 'type' : param.type,
        // 'Y-Axis1': param.selectedYAxis1,
        // 'Y-Axis2': param.selectedYAxis2
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteWidget(String deviceId, String widgetId) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("devices/$deviceId/widgets/$widgetId");

    try {
      await ref.remove();
    } catch (e) {
      rethrow;
    } finally {}
  }

  Future<void> changeWidgetName(
      String deviceId, String widgetId, String widgetName) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("devices/$deviceId/widgets/$widgetId");

    try {
      await ref.update({'widgetName': widgetName});
    } catch (e) {
      rethrow;
    } finally {}
  }

  Future<void> changeWidgetUnit(
      String deviceId, String widgetId, String unit) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("devices/$deviceId/widgets/$widgetId");
    try {
      await ref.update({'unit': unit});
    } catch (e) {
      rethrow;
    } finally {
      await supabase
          .from('device_widgets')
          .update({'unit': unit}).eq('id', widgetId);
    }
  }

  Future<String> getWidgetUnit(String widgetId, String unit) async {
    String getUnit;
    try {
      List<Map<String, dynamic>> listUnit = await supabase
          .from('device_widgets')
          .select('unit')
          .eq('id', widgetId);
      // print(listUnit);
      getUnit = listUnit[0]['unit'];
      return getUnit;
    } catch (e) {
      // print(e);
      return null.toString();
    }
  }
  //==========================================================================

  Future<void> createNewDevice(String timestamp, NewDevice newDevice) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("devices/${newDevice.deviceId}");

    // final timestamp = await FirebaseDatabase.instance
    //     .ref()
    //     .child('.info/serverTimeInMillis')
    //     .once();

    await ref.set({
      'owner': newDevice.owner,
      'user': newDevice.user,
      'deviceName': newDevice.deviceName,
      // 'minGaugeValue': newDevice.minGaugeVal,
      // 'maxGaugeValue': newDevice.maxGaugeVal,
      //minminal gauge
      'minGaugeValueP1': newDevice.minGaugeValP1,
      'minGaugeValueP2': newDevice.minGaugeValP2,
      'minGaugeValueP3': newDevice.minGaugeValP3,
      'minGaugeValueP4': newDevice.minGaugeValP4,
      'minGaugeValueP5': newDevice.minGaugeValP5,
      //maximal gauge
      'maxGaugeValueP1': newDevice.maxGaugeValP1,
      'maxGaugeValueP2': newDevice.maxGaugeValP2,
      'maxGaugeValueP3': newDevice.maxGaugeValP3,
      'maxGaugeValueP4': newDevice.maxGaugeValP4,
      'maxGaugeValueP5': newDevice.maxGaugeValP5,
      'createdAt': timestamp,
      'P1': newDevice.P1,
      'P2': newDevice.P1,
      'P3': newDevice.P1,
      'P4': newDevice.P1,
      'P5': newDevice.P1,
      'P1Title': newDevice.P1Title,
      'P2Title': newDevice.P2Title,
      'P3Title': newDevice.P3Title,
      'P4Title': newDevice.P4Title,
      'P5Title': newDevice.P5Title,
      'P1Widget': newDevice.P1Widget,
      'P2Widget': newDevice.P2Widget,
      'P3Widget': newDevice.P3Widget,
      'P4Widget': newDevice.P4Widget,
      'P5Widget': newDevice.P5Widget,
    });
  }
}
