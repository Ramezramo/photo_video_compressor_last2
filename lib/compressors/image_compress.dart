import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_video_compressor_last/Pages/homePage/home_Page.dart';

import '../Pages/compressfolder/compressfolderhome.dart';
// import '../Pages/homePage/home_Page.dart';
// import '../../../vedioAndPhotosEdited/lib/Utils/Show_Notification.dart';


Future<void> deleteFileInNative(filePath) async {
  const channel = MethodChannel('NativeChannel');
  Map<String, dynamic> arguments = {
    "filepath": filePath,  // Replace with your argument values
  };

  // Pass the arguments when invoking the method
  Map data = await channel.invokeMethod("deleteSource", arguments);


}
Future<void> moveFileInNative(filePath,movetofolderpath) async {

  const channel = MethodChannel('NativeChannel');


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

    "folderpath":movetofolderpath
  };
  var data = await channel.invokeMethod("moveScours",arguments);
  print("CODE SLDKJFDSF");
  print(data);
}

Future<File?> ImageCompressAndGetFile(minHeight,minWidth,quality,file, bool deleteSource,cameraOrFolder,pathFileCameFrom) async {
  // print("$deleteSource at 987-98789");
  // quality will be 144p 360p 480p 720p

  int minHeightInted = int.parse(minHeight);
  int minWidthInted = int.parse(minWidth);

  try {
    // print("in 230948_234");
    int perquality;
    if (quality == "1080p"){
      perquality = 98;

    }if (quality == "720p"){
      perquality = 80;

    } else if (quality == "540p"){
      perquality = 65;
    }else if (quality == "480p"){
      perquality = 40;
    } else if (quality == "360p"){
      perquality = 20;
    } else  if (quality == "144p"){
      perquality = 5;
    }else {
      perquality = 100;
    }
    print("code dsfghsdf");
print(perquality);
    print(minHeight);
    print(minWidth);
    print(quality);
    Uint8List? result = await FlutterImageCompress.compressWithFile(
      file,
      minHeight: minHeightInted,
      minWidth: minWidthInted,
      quality: perquality,
      format: CompressFormat.jpeg,
    );

    if (result != null) {
      // Get the external storage directory
      Directory? appDocDir = await getExternalStorageDirectory();

      if (appDocDir != null) {
        // Create the directory if it doesn't exist
        String savePath = '${appDocDir.path}/compressedPhostos';
        Directory(savePath).createSync(recursive: true);
        // Read the original modification time
        File fileReadDate = File(file);
        DateTime originalModificationTime = await fileReadDate.lastModified();
        ///get the size Before the compressing
        int fileSizeBeforeCompress = await fileReadDate.length();
        if (cameraOrFolder== "camera"){
          filesSizeBeforeCompressFromHomePage += fileSizeBeforeCompress;}
        else if (cameraOrFolder== "folder")
        {
          filesSizeBeforeCompressFromHomePageFolder += fileSizeBeforeCompress;}
        ///get the size Before the compressing


        print("CODE KJHKJHJK");
        print(originalModificationTime);
        // Create a new File with the desired file path
        // var datetime = DateTime.now();
        String fileName = path.basename(file);
        String thePathOfFileCompressedInsideTheAppAndroidFiles = '$savePath/comp_${fileName}';
        File compressedFile = File(thePathOfFileCompressedInsideTheAppAndroidFiles);

        // Write the compressed image data to the file
        await compressedFile.writeAsBytes(result);
        await compressedFile.setLastModified(originalModificationTime);
        ///get the size after the compressing
        int fileSizeAfterCompress = await compressedFile.length();
        if (cameraOrFolder== "camera"){
          filesSizeAfterCompressFromHomePage += fileSizeAfterCompress;}
        else if (cameraOrFolder== "folder")
        {
          filesSizeAfterCompressFromHomePageFolder += fileSizeAfterCompress;}
        ///get the size Before the compressing
        // Check if the file was successfully saved
        if (await compressedFile.exists()) {
          moveFileInNative(compressedFile.path,pathFileCameFrom);
          if (deleteSource){
            // print("deleting 345_2352345");
            // print("id 578_67867");
            // print(file);
            deleteFileInNative(file);
          }

          // view message here after compressing
        } else {
          print('Failed to save the compressed image.');
        }
      } else {
        print('External storage directory is null. Unable to save the compressed image.');
      }
    } else {
      print('Compression failed. Result is null.');
    }


  }
   catch (e) {
    // if (kDebugMode) {
    //   // print("hola");
    //   // print(e.toString());
    // }
    // if (kDebugMode) {
    //
    // }
    Fluttertoast.showToast(msg: 'Compression failed');
}
  return null;}

