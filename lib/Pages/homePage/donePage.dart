import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';


String formatFileSize(int fileSizeInBytes) {
  if (fileSizeInBytes < 1024) {
    return '$fileSizeInBytes Bytes';
  } else if (fileSizeInBytes < 1024 * 1024) {
    double fileSizeInKB = fileSizeInBytes / 1024;
    return '${fileSizeInKB.toStringAsFixed(2)} KB';
  } else if (fileSizeInBytes < 1024 * 1024 * 1024) {
    double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    return '${fileSizeInMB.toStringAsFixed(2)} MB';
  } else {
    double fileSizeInGB = fileSizeInBytes / (1024 * 1024 * 1024);
    return '${fileSizeInGB.toStringAsFixed(2)} GB';
  }
}

class donePage extends StatelessWidget {
  final String TotalFilesCompressed;
  final String TotalVideos;
  final String TotalPics;

  final int FilesSizeBefore;
  final int FilesSizeAfter;



  const donePage({super.key,required this.TotalFilesCompressed, required this.TotalVideos, required this.FilesSizeBefore, required this.TotalPics, required this.FilesSizeAfter});

  @override
  Widget build(BuildContext context) {
    int UserFreed = FilesSizeBefore  - FilesSizeAfter;
    return SafeArea(
        child: Scaffold(
          backgroundColor:Color(0xFF171520) ,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min, // Set mainAxisSize to MainAxisSize.min
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(onPressed: () {
                    Navigator.pop(context);
                  }, icon: Icon(color: Color(0xFFF4F2FA),Icons.close)),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Set mainAxisSize to MainAxisSize.min
                  children: [
                    Image.asset(
                      width: 100,
                      height: 100,

                      "images/checked.png",

                    ),
                    SizedBox(height: 30,),
                    Text(
                      "$TotalFilesCompressed files compressed",
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.w300, color: Color(0xFFF4F2FA)),
                    ),
                    Text(
                      "$TotalVideos video $TotalPics picture ",
                      style: TextStyle(fontWeight: FontWeight.w100, color: Color(0xFFF4F2FA)),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "files size before ${formatFileSize(FilesSizeBefore)}",
                      style: TextStyle(fontWeight: FontWeight.w400, color: Color(0xFFF4F2FA)),
                    ),
                    Text(
                      "files size after ${formatFileSize(FilesSizeAfter)}",
                      style: TextStyle(fontWeight: FontWeight.w400, color: Color(0xFFF4F2FA)),
                    ),
                    SizedBox(height: 15,),
                    Text(
                      "You Freed ${formatFileSize(UserFreed)} ",
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.w300, color: Color(0xFFF4F2FA)),
                    ),
                    Divider(color: Color(0xFF2C343F)),
                  ],
                ),
              ),

            ],
          ),
          OkButton(pressEvent: () {
            Navigator.pop(context);
          }, context: context),
        ],
      ),
    ));
  }
}

class OkButton extends StatelessWidget {
  const OkButton({
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
        text: 'ok',
        buttonTextStyle: TextStyle(color: Colors.black87),
        color: Color(0xFFFCD70F),
        pressEvent: pressEvent,
      ),
    );
  }
}