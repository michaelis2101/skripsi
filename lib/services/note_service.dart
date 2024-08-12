import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_web/models/note_model.dart';
import 'package:uuid/uuid.dart';

class NoteService {
  final supabase = Supabase.instance.client;

  Future<void> deleteNote(
      String noteID, List<Map<String, dynamic>> attachments) async {
    try {
      await supabase.from('device_notes').delete().eq('id', noteID);
    } catch (e) {
      print(e);
    } finally {
      if (attachments.isNotEmpty) {
        FirebaseStorage storage = FirebaseStorage.instance;
        for (var attch in attachments) {
          if (attch.containsKey('file_url')) {
            try {
              Reference fileRef = storage.refFromURL(attch['file_url']);
              await fileRef.delete();
            } catch (e) {
              print(e);
            }
          }
        }
      }

      await supabase.from('attachments').delete().eq('note_id', noteID);
    }
  }

  Future<void> createDeviceNotes(
      String deviceId, NoteModel param, List<PlatformFile> attachment) async {
    final firebaseStorage = FirebaseStorage.instance;
    var noteID = const Uuid().v4();

    try {
      await supabase.from('device_notes').insert({
        'id': noteID,
        'device_id': deviceId,
        'title': param.title,
        'content': param.content
      });
    } catch (e) {
      rethrow;
    } finally {
      if (attachment.isNotEmpty) {
        for (var file in attachment) {
          final Uint8List? fileBytes = file.bytes;

          if (fileBytes == null) {
            print('Error: File bytes are null.');
            continue;
          }

          final fileName = file.name;

          try {
            Reference storageRef =
                firebaseStorage.ref().child('notes/$deviceId/$fileName');
            await storageRef.putData(fileBytes);

            final downloadURL = await storageRef.getDownloadURL();

            await supabase.from('attachments').insert({
              'note_id': noteID,
              'file_name': fileName,
              'file_url': downloadURL
            });
          } catch (e) {
            rethrow;
          }
        }
      }
    }
  }

  Future<void> updateNote(String noteID, String title, String content) async {
    try {
      await supabase.from('device_notes').update(
        {'title': title, 'content': content},
      ).eq('id', noteID);
    } catch (e) {
      rethrow;
    }
  }

  Future<PostgrestList> getNoteList(String deviceID) async {
    try {
      var response = await supabase
          .from('device_notes')
          .select()
          .eq('device_id', deviceID);

      // print(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<PostgrestList> getNoteData(String noteID) async {
    try {
      var response =
          await supabase.from('device_notes').select().eq('id', noteID);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<PostgrestList> getAttachmentList(String noteID) async {
    try {
      var response =
          await supabase.from('attachments').select().eq('note_id', noteID);

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
