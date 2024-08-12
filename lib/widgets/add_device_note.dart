import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/models/note_model.dart';
import 'package:ta_web/services/note_service.dart';

class AddDeviceNote extends StatefulWidget {
  VoidCallback refreshNoteList;
  String deviceID;
  AddDeviceNote(
      {super.key, required this.deviceID, required this.refreshNoteList});

  @override
  State<AddDeviceNote> createState() => _AddDeviceNoteState();
}

class _AddDeviceNoteState extends State<AddDeviceNote> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  bool isNoteUploading = false;

  List<PlatformFile> _files = [];

  Future<void> _selectFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        _files.addAll(result.files);
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _files.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * 0.4,
      // height: Get.height * 0.745,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Title",
            style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
          ),
          SizedBox(
            // height: Get.width * 0.2,
            width: double.infinity,
            child: TextField(
                controller: titleController,
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
                )),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Content",
            style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
          ),
          SizedBox(
            height: Get.width * 0.1,
            width: double.infinity,
            child: TextField(
                maxLines: 30,
                controller: contentController,
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
                )),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Attachments",
                style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
              ),
              IconButton(
                  onPressed: () {
                    _selectFiles();
                  },
                  icon: const Icon(
                    Icons.add_box_rounded,
                    color: Colors.black,
                  ))
            ],
          ),
          if (_files.isNotEmpty)
            SizedBox(
              height: (_files.length < 2) ? Get.width * 0.05 : Get.width * 0.1,
              width: double.infinity,
              child: ListView.builder(
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          // onLongPress: () => _removeFile(index),
                          leading: const Icon(Icons.file_present),
                          title: Text(_files[index].name),
                          trailing: InkWell(
                            onTap: () => _removeFile(index),
                            child: const Icon(Icons.delete),
                          ),
                        ),
                      ).animate().slide(),
                    );
                  }),
            ),
          const SizedBox(
            height: 10,
          ),
          if (isNoteUploading)
            SizedBox(
              height: 110,
              width: double.infinity,
              child: Center(
                child: CircularProgressIndicator(
                  color: ColorApp.lapisLazuli,
                ),
              ).animate().fadeIn(),
            ),
          if (!isNoteUploading)
            Column(
              children: [
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: ColorApp.lapisLazuli,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () async {
                        NoteModel newNote = NoteModel(
                            content: contentController.text,
                            title: titleController.text);

                        if (titleController.text.isEmpty ||
                            contentController.text.isEmpty) {
                          Get.snackbar('Warning', 'Note Cannot be Empty',
                              backgroundColor: Colors.white);
                        } else {
                          try {
                            setState(() {
                              isNoteUploading = true;
                            });

                            await NoteService().createDeviceNotes(
                                widget.deviceID, newNote, _files);
                          } catch (e) {
                            rethrow;
                          } finally {
                            setState(() {
                              isNoteUploading = false;
                            });
                            widget.refreshNoteList();
                            Get.back();
                          }
                        }
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white, fontSize: 20),
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
                          side:
                              BorderSide(width: 1, color: ColorApp.lapisLazuli),
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
            ),
        ],
      ),
    );
  }
}
