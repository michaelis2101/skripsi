import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_network/image_network.dart';
import 'package:ta_web/classes/colors_cl.dart';
import 'package:ta_web/models/note_model.dart';
import 'package:ta_web/services/note_service.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteView extends StatefulWidget {
  VoidCallback refreshNoteList;
  String noteID;
  NoteView({super.key, required this.noteID, required this.refreshNoteList});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  bool isNoteLoading = false;
  bool isEditLoading = false;
  bool isAttachmentLoading = false;
  // bool isNoteUploading = false;

  bool isTitleEditing = false;
  bool isTContentEditing = false;

  bool isNoteDeleting = false;

  List<Map<String, dynamic>> noteData = [];
  List<Map<String, dynamic>> attachmentData = [];

  Future<void> getAttachmentsData(String noteID) async {
    setState(() {
      isAttachmentLoading = true;
    });
    try {
      var response = await NoteService().getAttachmentList(noteID);

      setState(() {
        attachmentData = response;
      });
    } catch (e) {
      rethrow;
    } finally {
      setState(() {
        isAttachmentLoading = false;
      });
    }
  }

  Future<void> getNoteData(String noteID) async {
    setState(() {
      isNoteLoading = true;
    });
    try {
      var response = await NoteService().getNoteData(noteID);

      setState(() {
        titleController.text = response[0]['title'];
        contentController.text = response[0]['content'];
      });
    } catch (e) {
      rethrow;
    } finally {
      setState(() {
        isNoteLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNoteData(widget.noteID);
    getAttachmentsData(widget.noteID);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * 0.4,
      child: isNoteLoading
          ? Center(
              child: CircularProgressIndicator(
              color: ColorApp.lapisLazuli,
            ))
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Device Note",
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 24),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                          onTap: () {
                            Get.defaultDialog(
                              title: "Delete Note",
                              content: Column(
                                children: [
                                  const Text(
                                      "Are you sure you want to delete this note?"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  if (isNoteLoading)
                                    SizedBox(
                                        height: 105,
                                        child: Center(
                                            child: CircularProgressIndicator(
                                          color: ColorApp.lapisLazuli,
                                        ))),
                                  if (!isNoteLoading)
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 50,
                                          width: double.infinity,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          width: 1,
                                                          color: ColorApp
                                                              .lapisLazuli),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  10)))),
                                              onPressed: () async {
                                                setState(() {
                                                  isNoteDeleting = true;
                                                });
                                                try {
                                                  await NoteService()
                                                      .deleteNote(widget.noteID,
                                                          attachmentData);
                                                } catch (e) {
                                                  print(e);
                                                } finally {
                                                  widget.refreshNoteList();
                                                  setState(() {
                                                    isNoteDeleting = false;
                                                  });
                                                  // Get.back();
                                                  Get.until(
                                                      (route) => route.isFirst);
                                                }
                                              },
                                              child: Text(
                                                'Yes',
                                                style: TextStyle(
                                                    color:
                                                        ColorApp.lapisLazuli),
                                              )),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        SizedBox(
                                          height: 50,
                                          width: double.infinity,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: Colors
                                                                  .red),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10)))),
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: const Text(
                                                'No',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                        ),
                                      ],
                                    )
                                ],
                              ),
                            );
                          },
                          child: const Icon(Icons.delete)),
                    )
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: const BoxDecoration(
                      border: Border.symmetric(
                          horizontal:
                              BorderSide(width: 0.2, color: Colors.grey))),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  "Title",
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
                ),
                SizedBox(
                  // height: Get.width * 0.2,
                  width: double.infinity,
                  child: TextField(
                      readOnly: isTitleEditing ? false : true,
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
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isTitleEditing = !isTitleEditing;
                                });
                              },
                              icon: isTitleEditing
                                  ? const Icon(Icons.edit_off)
                                  : const Icon(Icons.edit)))),
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
                    readOnly: isTContentEditing ? false : true,
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
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(bottom: 100),
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  isTContentEditing = !isTContentEditing;
                                });
                              },
                              icon: isTContentEditing
                                  ? const Icon(Icons.edit_off)
                                  : const Icon(Icons.edit)),
                        )
                        // hintText: 'Pin Title',
                        ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (attachmentData.isNotEmpty)
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Attachments",
                        style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
                      ),
                      // IconButton(
                      //     onPressed: () {
                      //       // _selectFiles();
                      //     },
                      //     icon: const Icon(
                      //       Icons.add_box_rounded,
                      //       color: Colors.black,
                      //     ))
                    ],
                  ),
                if (attachmentData.isNotEmpty)
                  SizedBox(
                    height: Get.width * 0.1,
                    // width: ,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: attachmentData.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisSpacing: 2,
                              crossAxisCount: 1,
                              childAspectRatio: 3 / 4),
                      itemBuilder: (context, index) {
                        var attch = attachmentData[index];

                        String fileName = attch['file_name'];

                        String fileExt = fileName.split('.').last;
                        print(fileExt);
                        print(attch);

                        return Padding(
                          padding: const EdgeInsets.all(3),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                // color: Colors.pink
                                border: Border.all(width: 0.5)),
                            child: getImageWidget(
                                attch['file_url'], fileExt, fileName),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 10),
                if (isEditLoading)
                  SizedBox(
                    height: 110,
                    width: double.infinity,
                    child: Center(
                        child: CircularProgressIndicator(
                            color: ColorApp.lapisLazuli)),
                  ),
                if (!isEditLoading && (isTitleEditing || isTContentEditing))
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
                              if (titleController.text.isEmpty ||
                                  contentController.text.isEmpty) {
                                Get.snackbar('Warning', 'Note Cannot be Empty',
                                    backgroundColor: Colors.white);
                              } else {
                                try {
                                  setState(() {
                                    isEditLoading = true;
                                  });
                                  await NoteService().updateNote(
                                      widget.noteID,
                                      titleController.text,
                                      contentController.text);
                                } catch (e) {
                                  rethrow;
                                } finally {
                                  setState(() {
                                    isEditLoading = false;
                                  });
                                  widget.refreshNoteList();
                                  Get.back();
                                }
                              }
                            },
                            child: const Text(
                              'Save',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
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
                            onPressed: () => setState(() {
                                  isTitleEditing = false;
                                  isTContentEditing = false;
                                }),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                  color: ColorApp.lapisLazuli, fontSize: 20),
                            )),
                      ),
                    ],
                  ).animate().fadeIn(),
                // if (_files.isNotEmpty)
                //   SizedBox(
                //     height: (_files.length < 2) ? Get.width * 0.05 : Get.width * 0.1,
                //     width: double.infinity,
                //     child: ListView.builder(
                //         itemCount: _files.length,
                //         itemBuilder: (context, index) {
                //           return Padding(
                //             padding: const EdgeInsets.symmetric(vertical: 5),
                //             child: Container(
                //               decoration: BoxDecoration(
                //                 color: Colors.white,
                //                 borderRadius: BorderRadius.circular(10),
                //               ),
                //               child: ListTile(
                //                 // onLongPress: () => _removeFile(index),
                //                 leading: const Icon(Icons.file_present),
                //                 title: Text(_files[index].name),
                //                 trailing: InkWell(
                //                   onTap: () => _removeFile(index),
                //                   child: const Icon(Icons.delete),
                //                 ),
                //               ),
                //             ).animate().slide(),
                //           );
                //         }),
                //   ),
                // const SizedBox(
                //   height: 10,
                // ),
                // if (isNoteUploading)
                //   SizedBox(
                //     height: 110,
                //     width: double.infinity,
                //     child: Center(
                //       child: CircularProgressIndicator(
                //         color: ColorApp.lapisLazuli,
                //       ),
                //     ).animate().fadeIn(),
                //   ),
                // if (!isNoteUploading)
                //   Column(
                //     children: [
                //       SizedBox(
                //         height: 50,
                //         width: double.infinity,
                //         child: ElevatedButton(
                //             style: ElevatedButton.styleFrom(
                //                 backgroundColor: ColorApp.lapisLazuli,
                //                 shape: RoundedRectangleBorder(
                //                     borderRadius: BorderRadius.circular(10))),
                //             onPressed: () async {
                //               NoteModel newNote = NoteModel(
                //                   content: contentController.text,
                //                   title: titleController.text);

                //               if (titleController.text.isEmpty ||
                //                   contentController.text.isEmpty) {
                //                 Get.snackbar('Warning', 'Note Cannot be Empty',
                //                     backgroundColor: Colors.white);
                //               } else {
                //                 try {
                //                   setState(() {
                //                     isNoteUploading = true;
                //                   });

                //                   await NoteService().createDeviceNotes(
                //                       widget.deviceID, newNote, _files);
                //                 } catch (e) {
                //                   rethrow;
                //                 } finally {
                //                   setState(() {
                //                     isNoteUploading = false;
                //                   });
                //                   Get.back();
                //                 }
                //               }
                //             },
                //             child: const Text(
                //               'Create New Note',
                //               style: TextStyle(color: Colors.white, fontSize: 20),
                //             )),
                //       ),
                //       const SizedBox(
                //         height: 10,
                //       ),
                //       SizedBox(
                //         height: 50,
                //         width: double.infinity,
                //         child: ElevatedButton(
                //             style: ElevatedButton.styleFrom(
                //                 backgroundColor: Colors.white,
                //                 side:
                //                     BorderSide(width: 1, color: ColorApp.lapisLazuli),
                //                 shape: RoundedRectangleBorder(
                //                   borderRadius: BorderRadius.circular(10),
                //                 )),
                //             onPressed: () => Get.back(),
                //             child: Text(
                //               'Cancel',
                //               style: TextStyle(
                //                   color: ColorApp.lapisLazuli, fontSize: 20),
                //             )),
                //       ),
                //     ],
                //   ),
              ],
            ),
    );
  }
}

Widget getImageWidget(String fileUrl, String fileExt, String fileName) {
  if (fileExt == 'png' ||
      fileExt == 'jpg' ||
      fileExt == 'jpeg' ||
      fileExt == 'gif') {
    return InkWell(
      onTap: () {
        Get.defaultDialog(
          title: fileName,
          content: Container(
            height: Get.height * 0.8,
            width: Get.width * 0.8,
            child: ImageNetwork(
              image: fileUrl,
              height: Get.height * 0.8,
              width: Get.width * 0.8,
              fitWeb: BoxFitWeb.scaleDown,
              // onTap: (){},
            ),
            // child: Image(
            //   image: NetworkImage(fileUrl),
            //   // height: double.infinity,
            //   fit: BoxFit.fitHeight,
            //   errorBuilder: (context, error, stackTrace) {
            //     return const Center(child: Icon(Icons.error));
            //   },
            // ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ImageNetwork(
          image: fileUrl,
          height: 150,
          width: 200,
          onTap: () {
            Get.defaultDialog(
              title: fileName,
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: Get.height * 0.7,
                    width: Get.width * 0.8,
                    child: ImageNetwork(
                      onLoading: CircularProgressIndicator(
                          color: ColorApp.lapisLazuli),
                          
                      image: fileUrl,
                      height: Get.height * 0.7,
                      width: Get.width * 0.8,
                      fitWeb: BoxFitWeb.scaleDown,
                      // onTap: () {},
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 50,
                    width: 400,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: ColorApp.lapisLazuli,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () async {
                        if (await canLaunchUrl(Uri.parse(fileUrl))) {
                          await launchUrl(Uri.parse(fileUrl));
                        } else {
                          throw 'Could not launch $fileUrl';
                        }
                      },
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download, color: Colors.white),
                          Text('Save Image',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
          // fitWeb: BoxFitWeb.,
        ),
        // child: Image(
        //   image: NetworkImage(fileUrl),
        //   height: double.infinity,
        //   fit: BoxFit.fitHeight,
        //   errorBuilder: (context, error, stackTrace) {
        //     return const Center(child: Icon(Icons.error));
        //   },
        // ),
      ),
    );
  } else {
    return InkWell(
      onTap: () async {
        if (await canLaunchUrl(Uri.parse(fileUrl))) {
          await launchUrl(Uri.parse(fileUrl));
        } else {
          throw 'Could not launch $fileUrl';
        }
      },
      child: SizedBox(
        height: double.infinity,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.download,
                size: 60,
              ),
              Text(
                fileName,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
