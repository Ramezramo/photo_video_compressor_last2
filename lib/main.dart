
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Pages/homePage/donePage.dart';
import 'Pages/homePage/home_Page.dart';
// import 'Pages/homePageWidgets/home_Page.dart';


void main() {
  runApp(const MyApp());
}

Future<bool> requestStoragePermission() async {
  final status = await Permission.storage.request();
  if (status.isGranted) {
    // Permission is granted; you can now access the directory
    return true;
  } else if (status.isPermanentlyDenied) {
    // The user has permanently denied the permission, you can open the app settings
    await openAppSettings();
    return false;

  } else {
    // Permission is denied
    return false;
  }
}


// Future<void> _create_A_main_Folder() async {
//   final channel = const MethodChannel('NativeChannel');
//   await requestStoragePermission();
//   // Map<String, dynamic> arguments = {
//   //   "arg1": "value1",  // Replace with your argument values
//   //   "arg2": "value2",
//   // };
//
//   // Pass the arguments when invoking the method
//   Map data = await channel.invokeMethod("createFolder");
//
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: donePage(),
      home: MainHomePage(),
      // home: PostCompression(),
    );
  }
}