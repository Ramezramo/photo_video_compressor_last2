import 'dart:io';
import 'dart:math';
import 'dart:ui';
// import 'package:path/path.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_video_compressor_last/Pages/homePage/counterFromChatGpt.dart';
import 'package:photo_video_compressor_last/Pages/src/panel.dart';

import 'package:flutter/services.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../compressors/image_compress.dart';
import '../../compressors/video_compress.dart';

import '../homePage/donePage.dart';

import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

// import '../homePage/home_Page.dart';




class compressFolderPage extends StatefulWidget {

  final String workingDirectory;

  compressFolderPage({required this.workingDirectory});

  @override
  _compressFolderPageState createState() => _compressFolderPageState();
}

bool isSwitchedFolder = false;
TextEditingController pictureWidthFolder = TextEditingController(text: '1920');

TextEditingController pictureHeightFolder = TextEditingController(text: '1080');

String picselectedValueFolder = '480p';
String vidselectedValueFolder = '540p';

int filesSizeAfterCompressFromHomePageFolder = 0;
int filesSizeBeforeCompressFromHomePageFolder = 0;
const channel = MethodChannel('NativeChannel');

Future<void> showTost(text) async {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT, // Duration of the toast
    gravity: ToastGravity.BOTTOM, // Location where the toast should appear
    timeInSecForIosWeb: 1, // Duration for iOS
    backgroundColor: Colors.black, // Background color of the toast
    textColor: Colors.white, // Text color of the toast message
    fontSize: 14, // Font size of the toast message
  );
}



String filteringCurrentFileCompressed(video_Compressing_Percentage) {
  String video_Compressing_Percentage_Filtered;
  try {

    video_Compressing_Percentage_Filtered =
        video_Compressing_Percentage.toString().substring(2, 4);

    return video_Compressing_Percentage_Filtered;
  } catch (e) {
    video_Compressing_Percentage_Filtered = "0";
    return video_Compressing_Percentage_Filtered;
  }
}

class _compressFolderPageState extends State<compressFolderPage> {
  final double _initFabHeight = 120.0;


  /// this map will contain a files sorted by date from the native channel
  Map map_Contains_Files_Names_Sorted_By_Date = {};

  /// if true will view loading indicator
  bool load = true;

  /// video compressing progress
  double progress = 0.0;

  /// the path of the generated thumbnail will be stored in this var
  Uint8List? thumbnailVideoPath;
  var picAsAThumbnail;

  /// for files in folder count obtained from the native channel
  late int total_Files_Length_Obtained_From_NATIVE = 0;

  /// total compressed files
  int compressed = 0;

  /// if compressing finished view the true widget and view a widget
  /// to tell the user the compressing process finished
  bool compressionFinished = false;

  String fileUnderCompress = "no files yet";

  double? VideoProgress = 0.0;
  late Subscription subscription = Subscription(() { });

  late double? video_Compressing_Percentage = 0;

  late bool viewSettingsButtonsBeforePresssing = true;
  bool startedCompressingProsses = false;
  var isCompressing_From_Module = false;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool preparingFileToCompress = false;
  bool firsPageIdentifier = true;
  bool bufferingPics = false;
  int picsCompressed = 0;
  int vidsCompressed = 0;
  int photoOrPic = 0;

  int photoesPreparedLen = 0;
  int videosPreparedLen = 0;

  List<MapEntry<String, int>> imagesObtainedFromNative = [];
  List<MapEntry<String, int>> videosObtainedFromNative = [];

  bool isTransactionInProgress = true;
  void restarter() {
    isTransactionInProgress = true;
    filesSizeAfterCompressFromHomePageFolder = 0;
    filesSizeBeforeCompressFromHomePageFolder = 0;
    bufferingPics = false;

    videosObtainedFromNative = [];
    imagesObtainedFromNative = [];
    photoesPreparedLen = 0;
    videosPreparedLen = 0;

    photoOrPic = 0;
    vidsCompressed = 0;
    picsCompressed = 0;
    firsPageIdentifier = true;
    bool preparingFileToCompress = false;
    startedCompressingProsses = false;

    map_Contains_Files_Names_Sorted_By_Date = {};
    load = true;
    progress = 0.0;
    picAsAThumbnail;

    total_Files_Length_Obtained_From_NATIVE = 0;
    compressed = 0;

    compressionFinished = false;
    thumbnailVideoPath;

    fileUnderCompress = "no files yet";

    VideoProgress = 0.0;
    subscription;

    video_Compressing_Percentage;

    viewSettingsButtonsBeforePresssing = true;
    getfolderFilesData();
  }

  void progress_maker() async {
    progress = compressed / videosPreparedLen;
    setState(() {});
  }

  void videoProgressMaker(done, total) async {
    var VideoProgress = done / total;
    print(VideoProgress);
    setState(() {});
  }

  List SortTheVideos(userVideos) {
    List videosSorted = [];
    userVideos.sort((a, b) => a.value.compareTo(b.value) as int);
    userVideos.forEach((entry) => videosSorted.add(entry.key));

    return videosSorted;
  }

  List SortThePics(userImages) {
    List picsSorted = [];
    userImages.sort((a, b) => a.value.compareTo(b.value) as int);
    userImages.forEach((entry) => picsSorted.add(entry.key));
    userImages.forEach((entry) => print('${entry.key}: ${entry.value}'));
    return picsSorted;
  }

  Future<void> getfolderFilesData() async {

    Map<String, dynamic> arguments = {
      "Folderpath": widget.workingDirectory, // Replace with your argument values
    };

    // Pass the arguments when invoking the method
    Map data = await channel.invokeMethod("giveMEThisFolderData", arguments);
    // Map data = await channel.invokeMethod("giveMEcameraData");

    List<MapEntry<dynamic, dynamic>> sortedEntries = data.entries.toList();
    print("code fghdfgh");
    print(sortedEntries);

    total_Files_Length_Obtained_From_NATIVE = sortedEntries.length;

    for (var entry in sortedEntries) {
      String fileextension = path.extension(entry.key).toLowerCase();
      int valueAsInt = int.tryParse(entry.value) ??
          0; // Convert to int, default to 0 if conversion fails

      if (fileextension == '.jpg' ||
          fileextension == '.jpeg' ||
          fileextension == '.png') {
        photoesPreparedLen++;
        imagesObtainedFromNative
            .add(MapEntry(entry.key.toString(), valueAsInt));
      } else if (fileextension == '.mp4' ||
          fileextension == '.mov' ||
          fileextension == '.avi') {
        videosPreparedLen++;
        videosObtainedFromNative
            .add(MapEntry(entry.key.toString(), valueAsInt));
      }
    }

    setState(() {});
  }

  Future<List<File>> getFilesInFolderSortedByDate() async {
    Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) {
      // Handle the case where external storage is not available
      return [];
    }

    Directory folder = Directory('/storage/emulated/0/DCIM/Camera');

    if (!folder.existsSync()) {
      // Handle the case where the folder does not exist
      return [];
    }

    List<File> filesInFolder = folder.listSync().whereType<File>().toList();
    filesInFolder.sort((a, b) {
      DateTime dateA = a.lastModifiedSync();
      DateTime dateB = b.lastModifiedSync();
      return dateA.compareTo(dateB);
    });
    // print(filesInFolder);
    return filesInFolder;
  }

  Future<Uint8List?> createVideoThumbnail(String videoPath) async {
    var thumbnail = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128, // Set the desired thumbnail width (adjust as needed)
      quality: 25, // Set the image quality (adjust as needed)
    );
    return thumbnail;
  }

  Future<void> comprssImage(path) async {
    await ImageCompressAndGetFile(
        pictureHeightFolder.text, pictureWidthFolder.text, picselectedValueFolder, path, isSwitchedFolder,"folder",widget.workingDirectory);
  }

  Future<bool> comprssorVideo(path) async {
    setState(() {});
    bool success = await compressVideo(vidselectedValueFolder,path, isSwitchedFolder,"folder",widget.workingDirectory);
    setState(() {
      VideoProgress = 0;
    });
    return success;
  }

  // Future<void> startPreparingFilesAndClassifyThem() async {
  //
  //
  //   for (final entry in map_Contains_Files_Names_Sorted_By_Date.entries) {
  //     final key = entry.key;
  //     if (key.endsWith(".jpg") ||
  //         key.endsWith(".jpeg") ||
  //         key.endsWith(".png") ||
  //         key.endsWith(".gif") ||
  //         key.endsWith(".webp")) {
  //
  //       photoesPreparedLen.add(key);
  //
  //     } else if (key.endsWith(".mp4") ||
  //         key.endsWith(".mov") ||
  //         key.endsWith(".mkv") ||
  //         key.endsWith(".avi")) {
  //
  //       videosPreparedLen.add(key);
  //
  //     }
  //   }
  // }

  int filteringFilesCompressedPercentage(rawPercentage) {
    /// The input always will be 0.95098798 in the def will clean all junk and the out will be 95%
    int cleanPercentage = 95;
    return cleanPercentage;
  }

  double generateRandomPercentage() {
    // Generate a random double between 80.0 and 99.0
    double randomDouble = Random().nextDouble() * (99.0 - 50.0) + 50.0;

    // Round the double to two decimal places
    double randomPercentage =
    double.parse((randomDouble / 100.0).toStringAsFixed(2));

    return randomPercentage;
  }

  Future<void> CompressThePreparedPics() async {
    // SortTheVideos(videosObtainedFromNative);
    // SortThePics(imagesObtainedFromNative);
    // print(SortThePics(imagesObtainedFromNative));
    for (final entry in SortThePics(imagesObtainedFromNative)) {
      // print("compressing photos $entry");

      await comprssImage(entry);
      compressed ++;
      picsCompressed ++;
    }
  }

  Future<void> CompressThePreparedVids() async {
    for (final entry in SortTheVideos(videosObtainedFromNative)) {
      print("compressing vids");
      if (!isTransactionInProgress){
        break;
      }

      thumbnailVideoPath = await createVideoThumbnail(entry);
      setState(() {
        fileUnderCompress = entry;
        photoOrPic = 1;
      });

      bool success = await comprssorVideo(entry);
      if (success){
        setState(() {
          vidsCompressed++;

          compressed ++;
          progress_maker();
        });}
    }
  }

  void startCompressingChain() async {
    setState(() {
      startedCompressingProsses = true;
      photoOrPic = 1;
    });
    await CompressThePreparedVids();

    setState(() {
      photoOrPic = 0;
    });

    if (isTransactionInProgress){
      await CompressThePreparedPics();
      // print(picsCompressed);
      // print("CODE LSKDJFSDF");
      showTost("compressing finished");
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => donePage(FilesSizeAfter: filesSizeAfterCompressFromHomePageFolder,FilesSizeBefore: filesSizeBeforeCompressFromHomePageFolder,TotalFilesCompressed: "$compressed",TotalPics:"$picsCompressed" ,TotalVideos: "$vidsCompressed",)),
      );}
    // subscription.unsubscribe();

    Navigator.of(context).pop();

    // PushDonePage();
    setState(() {
      restarter();
    });


  }

  @override
  void initState() {
    // TODO: implement initSta
    // subscription = VideoCompress.compressProgress$.subscribe(
    //         (VideoProgress) => setState(() => this.VideoProgress = VideoProgress));
    // restarter();
    // String workingDirectory = "/path/to/your/working/directory";

    getfolderFilesData();
    subscription = VideoCompress.compressProgress$.subscribe(
            (VideoProgress) => setState(() => this.VideoProgress = VideoProgress));

    print("CODE SDLFKJSKJ");

    // progress_maker();
    // totalFiles = sortedMap.length;
    super.initState();
  }

  @override
  void dispose() {
    // Dispose of resources to prevent memory leaks.
    subscription.unsubscribe(); // Close the stream controller.

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    video_Compressing_Percentage =
    VideoProgress == null ? VideoProgress : VideoProgress! / 100;

    return SafeArea(
      child: Scaffold(

        floatingActionButton: settingFloatingButton(),
        body: Column(children: [
          if (bufferingPics && startedCompressingProsses)
            Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                Padding(
                  padding: const EdgeInsets.all(150.0),
                  child: SizedBox(child: CircularProgressIndicator()),
                ),
                Center(
                    child: Text(
                      "preparing the pictures",
                      style: TextStyle(fontSize: 20),
                    )),
                Center(
                    child: Text(
                      "please wait ",
                      style: TextStyle(fontSize: 25),
                    )),
              ],
            )
          else if (firsPageIdentifier)
            firstPageWidget(
              FolderName: widget.workingDirectory,
                photoesPrepared: photoesPreparedLen.toString(),
                vidsPrepared: videosPreparedLen.toString(),
                pressEvent: () {
                  setState(() {
                    firsPageIdentifier = false;
                    startCompressingChain();
                  });
                },
                folderFiles: photoesPreparedLen + videosPreparedLen ,
                OnPressedForRefresh: () {
                  setState(() {
                    restarter();
                  });
                })
          else if (startedCompressingProsses && photoOrPic == 1)
              startedCompressingProssesWidget(onPressedCancel:() {
                print("cancel Pressed");
                showCancelDialog( context);

              },
                vidsPreparedlen: videosPreparedLen.toString(),
                picsPreparedlen: photoesPreparedLen.toString(),
                vidthumbnail: thumbnailVideoPath,
                vidsCompressed: vidsCompressed.toString(),
                picsCompressed: picsCompressed.toString(),
                fileName: fileUnderCompress,
                picthumbnail: picAsAThumbnail,
                folderFiles: total_Files_Length_Obtained_From_NATIVE,
                filesCompressed: compressed.toString(),
                totalFilesPercentage: progress,
                currentFilePercentageVid: video_Compressing_Percentage!,
                currentFilePercentagePic: generateRandomPercentage(),
                photoOrPic: photoOrPic,
              )
            else if (startedCompressingProsses && photoOrPic == 0)
                startedCompressingProssesWidget(onPressedCancel: () {
                  showCancelDialog(context);




                },
                  theEnimationEnded: () {
                    if (!startedCompressingProsses) {

                      // setState(() {
                      //   restarter();
                      // });
                    } else {

                      setState(() {
                        bufferingPics = true;
                      });
                    }
                  },
                  picsPreparedlen: photoesPreparedLen.toString(),
                  vidsPreparedlen: videosPreparedLen.toString(),
                  vidthumbnail: thumbnailVideoPath,
                  vidsCompressed: vidsCompressed.toString(),
                  picsCompressed: picsCompressed.toString(),
                  fileName: fileUnderCompress,
                  picthumbnail: picAsAThumbnail,
                  folderFiles: total_Files_Length_Obtained_From_NATIVE,
                  filesCompressed: compressed.toString(),
                  totalFilesPercentage: progress,
                  currentFilePercentageVid: video_Compressing_Percentage!,
                  currentFilePercentagePic: generateRandomPercentage(),
                  photoOrPic: photoOrPic,
                )
              else if (compressionFinished)
                  firstPageWidget(
    FolderName: widget.workingDirectory,

                      photoesPrepared: photoesPreparedLen.toString(),
                      vidsPrepared: photoesPreparedLen.toString(),
                      pressEvent: () {
                        setState(() {
                          firsPageIdentifier = false;
                          startCompressingChain();
                        });
                        // startPreparingFilesAndClassifyThem();
                      },
                      folderFiles: total_Files_Length_Obtained_From_NATIVE,
                      OnPressedForRefresh: () {
                        setState(() {
                          // startPreparingFilesAndClassifyThem();
                          restarter();
                        });
                      }),
        ]),
      ),
    );
  }


  AlertDialog confirmCancelDialoge (){

    return AlertDialog (
      title: const Text("Alert"),
      content: Container(
        child: Text("want to stop compressing ?",style:TextStyle(fontSize: 12,fontWeight: FontWeight.w300), ),

      ),

      actions: [
        Row(
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                isTransactionInProgress = false;
                VideoCompress.cancelCompression();

              },
              child: const Text("stop"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("continue"),
            ),
          ],
        ),
      ],
    );
  }

  void showCancelDialog(BuildContext context) {
    AlertDialog cancelDialog = confirmCancelDialoge();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return cancelDialog;
      },
    );
  }



}
//
// class controllerIfPhotoOrPic extends StatelessWidget {
//   final double totalFilesPercentage;
//
//   final double currentFilePercentage;
//   final String folderFiles;
//
//   final String filesCompressed;
//   final picthumbnail;
//
//   final String fileName;
//   final String fileBeingCompressedPercentage;
//   final String picsCompressed;
//   final String vidsCompressed;
//
//   final Uint8List? vidthumbnail;
//      bool isVideo;
//
//    controllerIfPhotoOrPic({super.key, required this.totalFilesPercentage, required this.currentFilePercentage, required this.folderFiles, required this.filesCompressed, this.picthumbnail, required this.fileName, required this.fileBeingCompressedPercentage, required this.picsCompressed, required this.vidsCompressed, this.vidthumbnail,  required this.isVideo});
//
//   @override
//   Widget build(BuildContext context) {
//     if (isVideo = false ){
//       return  startedCompressingPicProssesWidget(
//         vidsCompressed: vidsCompressed,
//         picsCompressed: picsCompressed,
//         fileBeingCompressedPercentage:
//         fileBeingCompressedPercentage,
//         fileName: fileName,
//         picthumbnail: picthumbnail,
//         folderFiles: folderFiles,
//         filesCompressed: filesCompressed,
//         totalFilesPercentage: totalFilesPercentage,
//         currentFilePercentage: currentFilePercentage,
//       );
//     }    else{
//       return   startedCompressingVidProssesWidget(
//         vidsCompressed: vidsCompressed,
//         picsCompressed: picsCompressed,
//         fileBeingCompressedPercentage:
//         fileBeingCompressedPercentage,
//         fileName: fileName,
//         folderFiles: folderFiles,
//         filesCompressed:filesCompressed,
//         totalFilesPercentage: totalFilesPercentage,
//         currentFilePercentage: currentFilePercentage!,
//         // currentFilePercentage: video_Compressing_Percentage_Filtered,
//         vidthumbnail: vidthumbnail,
//       );
//     }
//   }
// }

class StartCompressingButton extends StatelessWidget {
  const StartCompressingButton({
    super.key,
    required this.context,
    required this.pressEvent,
  });
  final Function() pressEvent;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: AnimatedButton(
        text: 'Start Compressing',
        color: Colors.deepPurple,
        pressEvent: pressEvent,
      ),
    );
  }
}

class ThumbnailViewWidget extends StatefulWidget {
  final String imagePath;

  ThumbnailViewWidget({required this.imagePath});

  @override
  State<ThumbnailViewWidget> createState() => _ThumbnailViewWidgetState();
}

class _ThumbnailViewWidgetState extends State<ThumbnailViewWidget> {
  final double thumbnailSize = 100.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<Uint8List>(
        future: _generateThumbnail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.5,
              child: Image.memory(
                snapshot.data!,
                width: thumbnailSize,
                height: thumbnailSize,
                fit: BoxFit.cover,
              ),
            );
          } else {
            return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.5,
                child: Center(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }

  Future<Uint8List> _generateThumbnail() async {
    final File imageFile = File(widget.imagePath);
    final Uint8List bytes = await imageFile.readAsBytes();

    // Resize the image using the image package
    final img.Image originalImage = img.decodeImage(bytes)!;
    final img.Image thumbnail =
    img.copyResize(originalImage, width: 100, height: 100);

    // Convert the resized image back to bytes
    return Uint8List.fromList(img.encodeJpg(thumbnail));
  }
}
//
// class startedCompressingVidProssesWidget extends StatelessWidget {
//   final double totalFilesPercentage;
//
//   final double currentFilePercentage;
//   final String folderFiles;
//
//   final String filesCompressed;
//   final picthumbnail;
//   final Uint8List? vidthumbnail;
//   final String fileName;
//   final String fileBeingCompressedPercentage;
//   final String picsCompressed;
//   final String vidsCompressed;
//   const startedCompressingVidProssesWidget({
//     super.key,
//     required this.folderFiles,
//     required this.filesCompressed,
//     required this.totalFilesPercentage,
//     required this.currentFilePercentage,
//     this.picthumbnail,
//     this.vidthumbnail,
//     required this.fileName,
//     required this.fileBeingCompressedPercentage,
//     required this.picsCompressed,
//     required this.vidsCompressed,
//   });
//   @override
//   Widget build(BuildContext context) {
//     // print("Code skdjfhskdfjh");
//     // print(pictureThumbNail);
//     return videoPicWidget(vidthumbnail: vidthumbnail, totalFilesPercentage: totalFilesPercentage, filesCompressed: filesCompressed, folderFiles: folderFiles, picsCompressed: picsCompressed, vidsCompressed: vidsCompressed, currentFilePercentage: currentFilePercentage, fileBeingCompressedPercentage: fileBeingCompressedPercentage, fileName: fileName);
//   }
// }

class videoPicWidget extends StatelessWidget {
  const videoPicWidget({
    super.key,
    required this.vidthumbnail,
    required this.totalFilesPercentage,
    required this.filesCompressed,
    required this.folderFiles,
    required this.picsCompressed,
    required this.vidsCompressed,
    required this.currentFilePercentageForLinear,
    required this.fileBeingCompressedPercentageText,
    required this.fileName,
    required this.vidsPreparedlen, required this.onPressedCancel,
  });

  final Uint8List? vidthumbnail;
  final double totalFilesPercentage;
  final String filesCompressed;
  final int folderFiles;
  final String picsCompressed;
  final String vidsCompressed;
  final double currentFilePercentageForLinear;
  final String fileBeingCompressedPercentageText;
  final String fileName;
  final String vidsPreparedlen;
  final Function()? onPressedCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        videoThumbnail(thumbnailVideoPath: vidthumbnail, context: context),
        linearPercentIndicatorWithPadding(
            context: context,
            video_Compressing_Percentage_Filtered: totalFilesPercentage),
        rowOfTextOfCompressedFilesNum(
          compressed: filesCompressed,
          total_Files_Length: folderFiles,
          compressorIsStatus: "vid",
          vidsPreparedlen: vidsPreparedlen,
        ),
        // CompressedPicAndVidTextViewer(
        //     picsCompressed: picsCompressed, vidsCompressed: vidsCompressed),
        linearPercentIndicatorWithPadding(
            context: context,
            video_Compressing_Percentage_Filtered:
            currentFilePercentageForLinear),
        BeingCompressedPercentageTextViewer(
            fileBeingCompressedPercentage:
            "$fileBeingCompressedPercentageText%"),
        FileNameTextViewer(fileName: fileName),
        IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: onPressedCancel,

          //     () {
          //   setState(() {
          //     isCompressing_From_Module = false;
          //     VideoCompress.cancelCompression();
          //     // VideoProgress = 0;
          //   });
          // },
        ),
      ],
    );
  }
}

class FileNameTextViewer extends StatelessWidget {
  const FileNameTextViewer({
    super.key,
    required this.fileName,
  });

  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Text(fileName),
    );
  }
}

class BeingCompressedPercentageTextViewer extends StatelessWidget {
  const BeingCompressedPercentageTextViewer({
    super.key,
    required this.fileBeingCompressedPercentage,
  });

  final String fileBeingCompressedPercentage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("$fileBeingCompressedPercentage"),
        ],
      ),
    );
  }
}

class CompressedPicAndVidTextViewer extends StatelessWidget {
  const CompressedPicAndVidTextViewer({
    super.key,
    required this.picsCompressed,
    required this.vidsCompressed,
  });

  final String picsCompressed;
  final String vidsCompressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Container(
          child: Center(
            child:
            Text("$picsCompressed photos compressed $vidsCompressed videos  "),
          )),
    );
  }
}

class startedCompressingProssesWidget extends StatelessWidget {
  final int photoOrPic;

  /// if this photoOrPic var equal to 1 this means is a vid if 0 this is a pic

  final double totalFilesPercentage;

  // final double currentFilePercentage;
  final int folderFiles;

  final String filesCompressed;
  final picthumbnail;

  final String fileName;
  // final String fileBeingCompressedPercentage;
  final String picsCompressed;
  final String vidsCompressed;
  final Uint8List? vidthumbnail;
  final double currentFilePercentageVid;

  final double currentFilePercentagePic;
  final String vidsPreparedlen;
  final String picsPreparedlen;
  final VoidCallback? theEnimationEnded;
  final Function()? onPressedCancel;
  const startedCompressingProssesWidget({
    super.key,
    required this.fileName,
    required this.folderFiles,
    required this.filesCompressed,
    required this.totalFilesPercentage,
    // required this.currentFilePercentage,
    this.picthumbnail,
    // required this.fileBeingCompressedPercentage,
    required this.picsCompressed,
    required this.vidsCompressed,
    required this.photoOrPic,
    required this.vidthumbnail,
    required this.currentFilePercentageVid,
    required this.currentFilePercentagePic,
    required this.vidsPreparedlen,
    required this.picsPreparedlen,
    this.theEnimationEnded,required this.onPressedCancel,
  });
  @override
  Widget build(BuildContext context) {
    if (photoOrPic == 0) {
      // print("CODE LKJDSFLK");
      return picViewerWidget(
        pictureTotal: int.parse(picsPreparedlen),
          theEnimationEnded: theEnimationEnded,
          totalFilesPercentage: totalFilesPercentage,
          filesCompressed: filesCompressed,
          folderFiles: folderFiles,
          picsCompressed: picsCompressed,
          vidsCompressed: vidsCompressed,
          currentFilePercentage: currentFilePercentagePic,
          fileName: fileName);
    } else if (photoOrPic == 1) {
      return videoPicWidget(
          onPressedCancel: onPressedCancel,
          vidsPreparedlen: vidsPreparedlen,
          vidthumbnail: vidthumbnail,
          totalFilesPercentage: totalFilesPercentage,
          filesCompressed: filesCompressed,
          folderFiles: folderFiles,
          picsCompressed: picsCompressed,
          vidsCompressed: vidsCompressed,
          currentFilePercentageForLinear: currentFilePercentageVid,
          fileBeingCompressedPercentageText:
          filteringCurrentFileCompressed(currentFilePercentageVid),
          fileName: fileName);
    } else {
      return Container(
        child: Center(child: Text("there is an error CODE 10983")),
      );
    }
  }
}

class picViewerWidget extends StatelessWidget {
  const picViewerWidget({
    super.key,
    required this.totalFilesPercentage,
    required this.filesCompressed,
    required this.folderFiles,
    required this.picsCompressed,
    required this.vidsCompressed,
    required this.currentFilePercentage,
    required this.fileName,
    this.theEnimationEnded, required this.pictureTotal,
  });

  final double totalFilesPercentage;
  final String filesCompressed;
  final int folderFiles;
  final String picsCompressed;
  final String vidsCompressed;
  final double currentFilePercentage;
  final String fileName;
  final VoidCallback? theEnimationEnded;
  final int pictureTotal;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2.5,
          child: Image.asset(
            "images/compressImage.png", // Replace with the actual path to your asset
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2.5,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Text(
                "compressing the pictures ",
                style: TextStyle(fontSize: 17),
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
        // linearPercentIndicatorWithPadding(
        //     context: context,
        //     video_Compressing_Percentage_Filtered: totalFilesPercentage),

        rowOfTextOfCompressedFilesNum(

          theEnimationEnded: theEnimationEnded,
          compressed: filesCompressed,
          total_Files_Length: pictureTotal,
          compressorIsStatus: "pic",
        ),
        // CompressedPicAndVidTextViewer(
        //     picsCompressed: picsCompressed, vidsCompressed: vidsCompressed),
        // linearPercentIndicatorWithPadding(
        //     context: context,
        //     video_Compressing_Percentage_Filtered: currentFilePercentage),
        // BeingCompressedPercentageTextViewer(
        //     fileBeingCompressedPercentage: "pics"),
        // FileNameTextViewer(fileName: fileName),
      ],
    );
  }
}

class firstPageWidget extends StatelessWidget {
  final String photoesPrepared;

  final String vidsPrepared;
  final String FolderName;

  const firstPageWidget(
      {super.key,
        required this.OnPressedForRefresh,
        required this.folderFiles,
        required this.photoesPrepared,
        required this.vidsPrepared,
        required this.pressEvent, required this.FolderName});
  final void Function()? OnPressedForRefresh;
  final int folderFiles;
  final Function() pressEvent;

  @override
  Widget build(BuildContext context) {
    String lastFolderName =path.basename(FolderName);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(lastFolderName,style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w500,fontSize: 23)),
            IconButton(onPressed: () {
              Navigator.pop(context);
            }, icon: Icon(color: Colors.black87,Icons.close)),
          ],
        ),
        WaitingThumbNail(context: context),
        linearPercentIndicatorWithPadding(
            context: context, video_Compressing_Percentage_Filtered: 0.0),
        rowOfTextOfCompressedFilesNum(
          picsPreparedlen: photoesPrepared,
          vidsPreparedlen: vidsPrepared,
          OnPressed: OnPressedForRefresh,
          compressed: "",
          total_Files_Length: folderFiles,
          compressorIsStatus: '0',
        ),
        linearPercentIndicatorWithPadding(
            context: context, video_Compressing_Percentage_Filtered: 0.0),
        deleteTheMainFile(),
        StartCompressingButton(context: context, pressEvent: pressEvent)
      ],
    );
  }
}

class deleteTheMainFile extends StatefulWidget {
  const deleteTheMainFile({super.key});

  @override
  State<deleteTheMainFile> createState() => _deleteTheMainFileState();
}

class _deleteTheMainFileState extends State<deleteTheMainFile> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Delete the main file",
          style: TextStyle(fontSize: 15, color: Colors.black),
        ),
        Switch(
          value: isSwitchedFolder,
          onChanged: (value) {
            setState(() {
              isSwitchedFolder =
                  value; // Update the state variable when the switch is toggled.
            });
          },
        ),
      ],
    );
  }
}

class reloadButton extends StatelessWidget {
  const reloadButton({super.key, this.OnPressed});
  final void Function()? OnPressed;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: OnPressed,
      icon: const Icon(Icons.refresh),
    );
  }
}

class rowOfTextOfCompressedFilesNum extends StatelessWidget {
  final String? vidsPreparedlen;

  final String? picsPreparedlen;

  const rowOfTextOfCompressedFilesNum(
      {super.key,
        this.OnPressed,
        required this.compressorIsStatus,
        required this.compressed,
        required this.total_Files_Length,
        this.vidsPreparedlen,
        this.picsPreparedlen,
        this.theEnimationEnded});
  final void Function()? OnPressed;
  final String compressorIsStatus;
  final String compressed;
  final int total_Files_Length;
  final VoidCallback? theEnimationEnded;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (compressorIsStatus == "vid")
          Text(
            '$compressed videos compressed from $vidsPreparedlen',
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w400),
          )
        else if (compressorIsStatus == "pic")
          Row(
            children: [
              AnimatedCounterPage(
                  countTo: total_Files_Length,
                  fontSize: 15,
                  theEnimationEnded: theEnimationEnded),
              Text(
                ' pictures compressed from ${total_Files_Length.toString()}',
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w400),
              ),
            ],
          )
        else if (compressorIsStatus == "0")
            Row(
              children: [
                SizedBox(
                  width: 270,
                  child: Text(
                    'folder files: ${total_Files_Length.toString()} videos: $vidsPreparedlen pic: $picsPreparedlen',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                reloadButton(OnPressed: OnPressed)
              ],
            )
          else if (compressorIsStatus == "00")
              Row(
                children: [
                  Text(
                    '$compressed files compressed from ${total_Files_Length.toString()}',
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w400),
                  ),
                  reloadButton(OnPressed: OnPressed)
                ],
              ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
    ;
  }
}

// Row rowOfTextOfCompressedFilesNum() {
//   return
// }

class linearPercentIndicatorWithPadding extends StatelessWidget {
  const linearPercentIndicatorWithPadding({
    super.key,
    required this.context,
    required this.video_Compressing_Percentage_Filtered,
  });

  final BuildContext context;
  final double video_Compressing_Percentage_Filtered;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, right: 7, left: 7, bottom: 7),
      child: linearPercentIndicator(
          context: context,
          video_Compressing_Percentage_Filtered:
          video_Compressing_Percentage_Filtered),
    );
  }
}

class pictureThumbNail extends StatelessWidget {
  const pictureThumbNail({
    super.key,
    required this.context,
    required this.thumbnail,
  });

  final BuildContext context;
  final thumbnail;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2.5,
      child: Image.file(
        File(thumbnail),
        fit: BoxFit.contain,
      ),
    );
  }
}

class videoThumbnail extends StatelessWidget {
  const videoThumbnail({
    super.key,
    required this.thumbnailVideoPath,
    required this.context,
  });

  final Uint8List? thumbnailVideoPath;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    if (thumbnailVideoPath == null) {
      return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2.5,
          child: Center(child: CircularProgressIndicator()));
    } else {
      return Image.memory(
        thumbnailVideoPath!,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2.5,
        fit: BoxFit.contain,
      );
    }
  }
}

class TheButtonOfStop extends StatelessWidget {
  const TheButtonOfStop({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.stop_circle_rounded),
      iconSize: 45,
      color: Colors.red,
      onPressed: () {},
    );
  }
}

class TheIconOFDone extends StatelessWidget {
  const TheIconOFDone({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.check,
      color: Colors.green,
    );
  }
}

class textOfFileBeingCompressedName extends StatelessWidget {
  const textOfFileBeingCompressedName({
    super.key,
    required this.fileUnderCompress,
  });

  final String? fileUnderCompress;

  @override
  Widget build(BuildContext context) {
    return Text("file name ($fileUnderCompress)",
        style: const TextStyle(color: Colors.black87));
  }
}

class WaitingThumbNail extends StatelessWidget {
  const WaitingThumbNail({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2.5,
      child: Image.asset(
        "images/just-waitin-waitin.gif",
        fit: BoxFit.contain,
      ),
    );
  }
}

class linearPercentIndicator extends StatelessWidget {
  const linearPercentIndicator({
    super.key,
    required this.context,
    required this.video_Compressing_Percentage_Filtered,
  });

  final BuildContext context;
  final double video_Compressing_Percentage_Filtered;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      minHeight: 13,
      color: const Color(0XFF97CF45),
      value: video_Compressing_Percentage_Filtered,
      semanticsLabel: 'Linear progress indicator',
    );
  }
}

class settingFloatingButton extends StatelessWidget {
  const settingFloatingButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return StatefulAlertDialog();
          },
        );
      },
      backgroundColor: Colors.white,
      child: Icon(
        Icons.settings,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}




class SettingsWidget extends StatefulWidget {
  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  List<String> picDropdownValues = ['1080p','720p', '540p','480p', '360p', '144p'];
  List<String> VideoDropdownValues = ['1080p','720p', '540p','480p', '360p'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text input for user input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("video quality", style: TextStyle(fontSize: 20)),
              DropdownButton<String>(
                value: vidselectedValueFolder,
                onChanged: (value) {
                  setState(() {
                    vidselectedValueFolder = value!;
                  });
                },
                items: VideoDropdownValues.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("picture quality", style: TextStyle(fontSize: 20)),
              DropdownButton<String>(
                value: picselectedValueFolder,
                onChanged: (value) {
                  setState(() {
                    picselectedValueFolder = value!;
                  });
                },
                items: picDropdownValues.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 5, // Set the elevation as per your preference
              margin: EdgeInsets.all(10), // Set margins as per your preference
              child: Padding(
                padding:
                EdgeInsets.all(10), // Set padding as per your preference
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Picture Width", style: TextStyle(fontSize: 14)),
                    SizedBox(
                      width: 40,
                      child: TextField(
                        controller: pictureWidthFolder,
                        // onChanged: (value) {
                        //   setState(() {
                        //     pictureWidth = value;
                        //   });
                        // },
                        decoration: InputDecoration(
                          labelText: 'width',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.only(bottom: 200.0),
            child: Card(
              elevation: 5, // Set the elevation as per your preference
              margin: EdgeInsets.all(10), // Set margins as per your preference
              child: Padding(
                padding:
                EdgeInsets.all(10), // Set padding as per your preference
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Picture Height", style: TextStyle(fontSize: 14)),
                    SizedBox(
                      width: 40,
                      child: TextField(
                        controller: pictureHeightFolder,
                        // onChanged: (value) {
                        //   setState(() {
                        //     pictureHeight = value;
                        //   });
                        // },
                        decoration: InputDecoration(
                          labelText: 'height',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Dropdown for selecting a value
        ],
      ),

    );
  }
}

class StatefulAlertDialog extends StatefulWidget {
  const StatefulAlertDialog({super.key});

  @override
  _StatefulAlertDialogState createState() => _StatefulAlertDialogState();
}

class _StatefulAlertDialogState extends State<StatefulAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("settings"),
      content: SettingsWidget(),
      // Column(
      //   mainAxisSize: MainAxisSize.min,
      //   children: [
      //
      //   ],
      // ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Done"),
        ),
      ],
    );
  }
}
