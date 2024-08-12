import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_web/models/user_model.dart';

class UserService extends GetxController {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  final supabase = Supabase.instance.client;

  Future<void> addNewUser(UserModel user) async {
    await users.add({
      'username': user.username,
      'email': user.email,
      'uid': user.uid,
      'role': 'user'
    });
  }

  Future<void> addNewUsertoSB(UserModel user) async {
    await supabase.from('users').insert({
      'username': user.username,
      'email': user.email,
      'uid': user.uid,
      'role': 'user',
      // 'created_at': DateTime.now().toIso8601String()
    });
  }

  Future<void> newSetting(String email) async {
    await supabase.from('settings').insert({
      'email': email,
      'profile_pic':
          'https://firebasestorage.googleapis.com/v0/b/project-st-iot.appspot.com/o/default_asset%2Fdefaultpfp.png?alt=media&token=882c5086-0c64-4285-b452-ca0b021707b6'
    });
  }

  Future<String?> getUsername(String uid) async {
    try {
      QuerySnapshot query = await users.where('uid', isEqualTo: uid).get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.get('username');
      } else {
        return null;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return null;
    }
  }

  Future<bool> checkNewUser(String email) async {
      QuerySnapshot query = await users.where('email', isEqualTo: email).get();
      if (query.docs.isNotEmpty) {
        return false;
      } else {
        return true;
      }
  }

  Future<String?> getUserDocumentID(String uid) async {
    try {
      QuerySnapshot query = await users.where('uid', isEqualTo: uid).get();

      return query.docs.first.id;
    } catch (e) {
      return e.toString();
    }
  }

  Future<PostgrestList> getUserInfo(String email) async {
    try {
      var response = await supabase.from('users').select().eq('email', email);
      // print(response);

      return response;
    } catch (e) {
      // print(e);
      rethrow;
    }
  }

  Future<PostgrestList> getUserSettings(String email) async {
    try {
      var response =
          await supabase.from('settings').select().eq('email', email);
      return response;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> changePfp(
      String email, PlatformFile newPic, String oldPic) async {
    final storage = FirebaseStorage.instance;

    try {
      if (oldPic !=
          'https://firebasestorage.googleapis.com/v0/b/project-st-iot.appspot.com/o/default_asset%2Fdefaultpfp.png?alt=media&token=882c5086-0c64-4285-b452-ca0b021707b6') {
        final oldPicRef = storage.refFromURL(oldPic);
        await oldPicRef.delete();
      }

      final Uint8List? fileBytes = newPic.bytes;

      final picName = newPic.name;

      final newPicRef = storage.ref().child('settings/$email/${picName}_pfp');
      await newPicRef.putData(fileBytes!);

      final downloadURL = await newPicRef.getDownloadURL();

      await supabase
          .from('settings')
          .update({'profile_pic': downloadURL}).eq('email', email);
    } catch (e) {
      print(e);
    }
  }

  Future<void> changeUsername(String uid, String newname) async {
    try {
      await supabase.from('users').update({'username': newname}).eq('uid', uid);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateSelectedDashboard(String email, String dashboardid) async {
    try {
      supabase
          .from('settings')
          .update({'selected_dashboard': dashboardid}).eq('email', email);
    } catch (e) {
      print(e);
    }
  }
}
