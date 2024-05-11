import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_video_compressor_last/Pages/compressfolder/compressfolderhome.dart';
import 'package:photo_video_compressor_last/Pages/homePage/home_Page.dart';

import 'package:video_compress/video_compress.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

// import '../Pages/homePage/home_Page.dart';

Future<String> moveFileInNative(
    filePath, mainFileName, movetofolderpath) async {
  const channel = MethodChannel('NativeChannel');
  // print("STOPCODE SLDKFJSLD_4 i will move the file by the native channel");
  String mainWorkingFolder = "/storage/emulated/0/Compressed_media_RM/";
  if (movetofolderpath == "camera") {
    movetofolderpath = "${mainWorkingFolder}/cameraCompressedFiles";
  } else {
    // Use the 'basename' function from the 'path' package to get the last folder name
    String lastFolder = basename(movetofolderpath);

    // Print the result
    print("Last folder name: $lastFolder");


    movetofolderpath = "${mainWorkingFolder}/${lastFolder}";
  }

  Map<String, dynamic> arguments = {
    "filepath": filePath, // Replace with your argument values
    "mainFileName": mainFileName,
    "folder-path": movetofolderpath
  };
  // print("sdlkfjsdlfk");
  // print(mainFileName);
  // Pass the arguments when invoking the method
  var data = await channel.invokeMethod("moveScoursVideo", arguments);
  print("CODE SLDKJFDSF");
  return data.toString();
}

Future<void> deleteFileInNative(filePath) async {
  const channel = MethodChannel('NativeChannel');
  Map<String, dynamic> arguments = {
    "filepath": filePath, // Replace with your argument values
  };

  // Pass the arguments when invoking the method
  Map data = await channel.invokeMethod("deleteSource", arguments);
}

//
// String changetheFileNameReturnThePath(mainFilePath,FilePathAfterCompress){
//   // Assuming 'filePath' contains the original path of the video file
//   String originalFilePath = mainFilePath;
//   String originalFileName = originalFilePath.split('/').last;
//
// // Assuming 'info.path' contains theriginal new path after compression
//   String compressedFilePath = FilePathAfterCompress;
//
// // Rename the compressed file to the original filename
//   File(compressedFilePath).renameSync(originalFileName);
//
// // Get the updated path after renaming
//   String updatedCompressedFilePath = compressedFilePath.replaceFirst(
//       RegExp(originalFileName), FilePathAfterCompress.split('/').last);
//   return updatedCompressedFilePath;
//
// }
Future<bool> compressVideo(String userVideoQuality, String filePath,
    bool deleteSource, cameraOrFolder , pathFileCameFrom) async {
  await VideoCompress.setLogLevel(0);
  // print("at 3294_234098");
  // print(filePath);
  VideoQuality? selectedQuality;
  if (userVideoQuality == "360p") {
    selectedQuality = VideoQuality.LowQuality;
  }
  if (userVideoQuality == "480p") {
    selectedQuality = VideoQuality.Res640x480Quality;
  } else if (userVideoQuality == "540p") {
    selectedQuality = VideoQuality.Res960x540Quality;
  } else if (userVideoQuality == "720p") {
    selectedQuality = VideoQuality.Res1280x720Quality;
  } else if (userVideoQuality == "1080p") {
    selectedQuality = VideoQuality.Res1920x1080Quality;
  } else {
    // Handle the case when userVideoQuality is neither "480" nor "720"
    selectedQuality = VideoQuality.Res960x540Quality;
  }

  try {
    final info = await VideoCompress.compressVideo(
      filePath,
      quality: selectedQuality,
      deleteOrigin: false,
      includeAudio: true,
    );

    print("holaGodDAmn");
    print(info!.path);
    print("gogogogo");

    ///to get the main file modified date
    File file = File(filePath);
    DateTime originalModificationTime = await file.lastModified();

    ///to get the main file modified date

    int fileSizeBeforeCompress = await file.length();
    if (cameraOrFolder == "camera") {
      filesSizeBeforeCompressFromHomePage += fileSizeBeforeCompress;
    } else if (cameraOrFolder == "folder") {
      filesSizeBeforeCompressFromHomePageFolder += fileSizeBeforeCompress;
    }
    // String filePathChanged = changetheFileNameReturnThePath(filePath,info.path);
    String originalFileName = filePath.split('/').last;

    String FileCompressedAndMovedPath =
        await moveFileInNative(info.path, originalFileName,pathFileCameFrom);
    File filePP = File(FileCompressedAndMovedPath);

    int fileSizeAfterCompress = await filePP.length();

    if (cameraOrFolder == "camera") {
      filesSizeAfterCompressFromHomePage += fileSizeAfterCompress;
    } else if (cameraOrFolder == "folder") {
      filesSizeAfterCompressFromHomePageFolder += fileSizeAfterCompress;
    }

    print("CODE LKSDJFLSKDJF");
    print("$fileSizeBeforeCompress before $fileSizeAfterCompress after");
    await filePP.setLastModified(originalModificationTime);
    // if (kDebugMode) {
    //   print(info.path);
    // } // This will print the path to the compressed video
    if (deleteSource) {
      deleteFileInNative(filePath);
    }
    return true;
  } catch (e) {
    print(e);
    // print("sdfhskjd");

    Fluttertoast.showToast(
      msg: "compressing canceled",
      toastLength: Toast.LENGTH_SHORT, // Duration of the toast
      gravity: ToastGravity.BOTTOM, // Location where the toast should appear
      timeInSecForIosWeb: 1, // Duration for iOS
      backgroundColor: Colors.black, // Background color of the toast
      textColor: Colors.white, // Text color of the toast message
      fontSize: 14, // Font size of the toast message
    );
    return false;
  }
}
