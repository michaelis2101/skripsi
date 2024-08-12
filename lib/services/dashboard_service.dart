import 'package:firebase_database/firebase_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_web/models/dashboard_model.dart';

class DashboardService {
  final supabase = Supabase.instance.client;

  Future<void> createNewDashboard(
      String dashboardId, String dashboardName, String userEmail) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("dashboards/$dashboardId");

    try {
      await ref.set(
          {'dashboardName': dashboardName, 'widgets': {}, 'user': userEmail});
    } catch (e) {
      rethrow;
    } finally {
      await supabase.from('dashboards').insert({
        'id': dashboardId,
        'dashboard_name': dashboardName,
        'user': userEmail
      });
    }
  }

  Future<PostgrestList> getDashboards(String email) async {
    try {
      var response =
          await supabase.from('dashboards').select().eq('user', email);
      // print(response);

      return response;
    } catch (e) {
      // print(e);
      rethrow;
    }
  }

  Future<void> renameDashboardWidget(
      String dbID, String widgetID, String newName) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("dashboards/$dbID/widgets/$widgetID");

    try {
      await ref.update({
        'widgetName': newName,
      });
    } catch (e) {
      print(e);
    } finally {
      await supabase
          .from('dashboard_widgets')
          .update({'widget_name': newName}).eq('id', widgetID);
    }
  }

  Future<void> createNewWidget(
      String dashboardId, DashboardModel param, String dataType) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("dashboards/$dashboardId/widgets/${param.widgetID}");

    try {
      await ref.set({
        'deviceID': param.deviceID,
        'widgetName': param.widgetName,
        'type': param.widgetType,
        'dataType': dataType,
        'key': param.dataKey,
        'minValue': param.minVal,
        'maxValue': param.maxVal
      });
    } catch (e) {
      print(e);
    } finally {
      await supabase.from('dashboard_widgets').insert({
        'id': param.widgetID,
        'dashboard_id': dashboardId,
        'device_id': param.deviceID,
        'key': param.dataKey,
        'type': param.widgetType,
        'data_type': dataType,
        'widget_name': param.widgetName,
        'min_value': param.minVal,
        'max_value': param.maxVal
      });
    }
  }

  Future<void> changeWidgetUnit(
      String dashboardID, String widgetID, String unit) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("dashboards/$dashboardID/widgets/$widgetID");

    try {
      await ref.update({'unit': unit});
    } catch (e) {
      print(e);
    } finally {
      await supabase
          .from('dashboard_widgets')
          .update({'unit': unit}).eq('id', widgetID);
    }
  }

  Future<void> deleteWidget(String widgetID, String dashboardId) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("dashboards/$dashboardId/widgets/$widgetID");
    try {
      await ref.remove();
    } catch (e) {
      rethrow;
    } finally {
      await supabase.from('dashboard_widgets').delete().eq('id', widgetID);
    }
  }

  Future<void> deleteDashboard(String dashboardId) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('dashboards/$dashboardId');

    try {
      await ref.remove();
    } catch (e) {
      print(e);
    } finally {
      await supabase.from('dashboards').delete().eq('id', dashboardId);
      await supabase
          .from('dashboard_widgets')
          .delete()
          .eq('dashboard_id', dashboardId);
    }
  }
}
