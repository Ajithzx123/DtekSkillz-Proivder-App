import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import '../../../app/generalImports.dart';
import '../customVideoPlayer/playVideoScreen.dart';

class UploadProofBottomSheet extends StatefulWidget {

  //
  const UploadProofBottomSheet({
    super.key,
    this.preSelectedFiles,
  });
  final List<Map<String, dynamic>>? preSelectedFiles;

  @override
  State<UploadProofBottomSheet> createState() => _UploadProofBottomSheetState();
}

class _UploadProofBottomSheetState extends State<UploadProofBottomSheet> with ChangeNotifier {
  //
  late ValueNotifier<List<Map<String, dynamic>>> uploadedMedia =
      ValueNotifier(widget.preSelectedFiles ?? []);

  Future<void> selectMedia() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          '3g2',
          '3gp',
          'aaf',
          'asf',
          'avchd',
          'avi',
          'drc',
          'flv',
          'm2v',
          'm3u8',
          'm4p',
          'm4v',
          'mkv',
          'mng',
          'mov',
          'mp2',
          'mp4',
          'mpe',
          'mpeg',
          'mpg',
          'mpv',
          'mxf',
          'nsv',
          'ogg',
          'ogv',
          'qt',
          'rm',
          'rmvb',
          'roq',
          'svi',
          'vob',
          'webm',
          'wmv',
          'yuv',
          'jpg',
          'jpeg',
          'jfif',
          'pjpeg',
          'pjp',
          'png',
          'svg',
          'gif',
          'apng',
          'webp',
          'avif'
        ],
      );

      if (result != null) {
        final List<Map<String, dynamic>> files = result.paths.map((String? path) {
          final String? mimeType = lookupMimeType(path!);

          final List<String> extension = mimeType!.split('/');

          return {'file': File(path), 'fileType': extension.first};
        }).toList();

        // if files are already added previously, then remove that file from new file list
        for (int i = 0; i < uploadedMedia.value.length; i++) {
          for (int j = 0; j < files.length; j++) {
            if (uploadedMedia.value[i]['file'].path == files[j]['file'].path) {
              files.removeAt(j);
            }
          }
        }
        uploadedMedia.value = uploadedMedia.value + files;
      } else {
        // User canceled the picker
      }
    } catch (_) {
    }

    /* final List<XFile> listOfSelectedImage = await imagePicker.pickMultiImage();
    if (listOfSelectedImage.isNotEmpty) {
      uploadedMedia.value = listOfSelectedImage;
    }*/
  }

  Widget _getHeading({required String heading}) {
    return Text(heading,
        style: TextStyle(
          color: Theme.of(context).colorScheme.blackColor,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.normal,
          fontSize: 20.0,
        ),
        textAlign: TextAlign.start,);
  }

  @override
  void dispose() {
    uploadedMedia.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Row _getCloseAndTimeSlotNavigateButton() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.pop(context, uploadedMedia.value);
            },
            child: Container(
                height: 44,
                decoration: BoxDecoration(boxShadow: const [
                  BoxShadow(
                      color: Color(0x1c343f53),
                      offset: Offset(0, -3),
                      blurRadius: 10,)
                ], color: Theme.of(context).colorScheme.secondaryColor,),
                child: Center(
                  child: Text(
                    'close'.translate(context: context),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.blackColor,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        fontSize: 14.0,),
                  ),
                ),),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.pop(context, uploadedMedia.value);
            },
            child: Container(
                height: 44,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x1c343f53),
                        offset: Offset(0, -3),
                        blurRadius: 10,)
                  ],
                  color: Theme.of(context).colorScheme.accentColor,
                ),
                child: // Apply Filter
                    Center(
                  child: ValueListenableBuilder(
                    valueListenable: uploadedMedia,
                    builder: (BuildContext context, Object? value, Widget? child) => Text(
                      uploadedMedia.value.isNotEmpty
                          ? 'done'.translate(context: context)
                          : 'skip'.translate(context: context),
                      style: TextStyle(
                          color: AppColors.whiteColors,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontSize: 14.0,),
                    ),
                  ),
                ),),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //   padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      color: Theme.of(context).colorScheme.primaryColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryColor,
                      borderRadius: const BorderRadiusDirectional.only(
                          topStart: Radius.circular(10), topEnd: Radius.circular(10),),),
                  child: _getHeading(heading: 'chooseMedia'.translate(context: context)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: uploadedMedia,
                        builder: (BuildContext context, List<Map<String, dynamic>> value, Widget? child) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            //if images is there then we will enable scroll
                            physics: value.isEmpty
                                ? const NeverScrollableScrollPhysics()
                                : const AlwaysScrollableScrollPhysics(),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: selectMedia,
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.symmetric(
                                        vertical: 15, horizontal: 5,),
                                    child: SetDottedBorderWithHint(
                                      width: value.isEmpty
                                          ? MediaQuery.sizeOf(context).width - 30
                                          : 100,
                                      height: 100,
                                      radius: 5,
                                      borderColor: Theme.of(context).colorScheme.accentColor,
                                      strPrefix: 'chooseMedia'.translate(context: context),
                                      str: '',
                                    ),
                                  ),
                                ),
                                if (value.isNotEmpty)
                                  Row(
                                    children: List.generate(
                                      value.length,
                                      (int index) => Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 5),
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .blackColor
                                                    .withOpacity(0.5),),),
                                        child: Stack(
                                          children: [
                                            if (value[index]['fileType'] == 'image')
                                              Center(
                                                  child:
                                                      Image.file(File(value[index]['file']!.path)),)
                                            else
                                              InkWell(
                                                child: Center(
                                                  child: Icon(
                                                    Icons.play_arrow,
                                                    color:
                                                        Theme.of(context).colorScheme.accentColor,
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.push(context, MaterialPageRoute(
                                                    builder: (BuildContext context) {
                                                      return PlayVideoScreen(
                                                          videoFile: value[index]['file'],);
                                                    },
                                                  ),);
                                                },
                                              ),
                                            Align(
                                              alignment: AlignmentDirectional.topEnd,
                                              child: InkWell(
                                                onTap: () async {
                                                  uploadedMedia.value.removeAt(index);

                                                  uploadedMedia.notifyListeners();
                                                },
                                                child: Container(
                                                  height: 20,
                                                  width: 20,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .blackColor
                                                      .withOpacity(0.4),
                                                  child: const Center(
                                                      child: Icon(
                                                    Icons.clear_rounded,
                                                    size: 15,
                                                  ),),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _getCloseAndTimeSlotNavigateButton()
        ],
      ),
    );
  }
}
