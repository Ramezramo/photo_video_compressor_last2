import 'dart:math';

import 'package:flutter/material.dart';

/// Author: Damodar Lohani
/// profile: https://github.com/lohanidamodar

class SettingsPage_3 extends StatelessWidget {
  static const routeName = '/SettingsPage_3';
  final TextStyle headerStyle = TextStyle(
    color: Colors.grey.shade800,
    fontWeight: FontWeight.bold,
    fontSize: 20.0,
  );

  SettingsPage_3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        title: Text('settings'),
        actions: const [
          // IconButton(onPressed: (){
          //   Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => SettingsPage_3()));
          // }, icon: Icon(Icons.settings))
        ],
      ),
      /// ----------------------------------------------------------
      /// Build  scrollable  content with help of SingleChildScrollView widget
      /// ----------------------------------------------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10.0),

            /// ----------------------------------------------------------
            /// Card widget header
            /// ----------------------------------------------------------
            // Card(
            //   elevation: 0.5,
            //   margin: const EdgeInsets.symmetric(
            //     vertical: 4.0,
            //     horizontal: 0,
            //   ),
            //   child: Column(
            //     children: <Widget>[
            //       Container(
            //         child: Row(
            //           children: <Widget>[
            //             Padding(
            //               padding: const EdgeInsets.all(12.0),
            //               child: CircleAvatar(
            //                 radius: 40,
            //
            //                 /// ----------------------------------------------------------
            //                 /// image widget header
            //                 /// ----------------------------------------------------------
            //                 backgroundImage: NetworkImage(
            //                     Constants.images[Random().nextInt(20)]),
            //               ),
            //             ),
            //             Text("Damodar Lohani"),
            //           ],
            //         ),
            //       ),
            //       _buildDivider(),
            //
            //       /// ----------------------------------------------------------
            //       /// Change Private Account SwitchListTile widget
            //       /// ----------------------------------------------------------
            //       SwitchListTile(
            //         activeColor: Colors.amber,
            //         value: true,
            //         title: Text("Private Account"),
            //         onChanged: (val) {},
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 20.0),
            // Text(
            //   "PUSH NOTIFICATIONS",
            //   style: headerStyle,
            // ),

            Card(
              margin: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 0,
              ),
              child: Column(
                children: <Widget>[
                  /// ----------------------------------------------------------
                  /// Change Received notification SwitchListTile widget
                  /// ----------------------------------------------------------
                  SwitchListTile(
                    activeColor: Colors.amber,
                    value: true,
                    title: const Text("Received notification"),
                    onChanged: (val) {},
                  ),
                  _buildDivider(),

                  /// ----------------------------------------------------------
                  /// Change Received newsletter SwitchListTile widget
                  /// ----------------------------------------------------------
                  const SwitchListTile(
                    activeColor: Colors.amber,
                    value: false,
                    title: Text("Received newsletter"),
                    onChanged: null,
                  ),
                  _buildDivider(),

                  /// ----------------------------------------------------------
                  /// Change Received Offer Notification SwitchListTile widget
                  /// ----------------------------------------------------------
                  SwitchListTile(
                    activeColor: Colors.amber,
                    value: true,
                    title: const Text("Received Offer Notification"),
                    onChanged: (val) {},
                  ),
                  _buildDivider(),

                  /// ----------------------------------------------------------
                  /// Change Received  App Updates SwitchListTile widget
                  /// ----------------------------------------------------------
                  const SwitchListTile(
                    activeColor: Colors.amber,
                    value: true,
                    title: Text("Received App Updates"),
                    onChanged: null,
                  ),
                ],
              ),
            ),

            /// ----------------------------------------------------------
            /// Card widget for logout action
            /// ----------------------------------------------------------
            Card(
              margin: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 0,
              ),
              child: ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text("Logout"),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 60.0),
          ],
        ),
      ),
    );
  }

  /// ----------------------------------------------------------
  /// _buildDivider helper method for build divider widget
  /// ----------------------------------------------------------
  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade300,
    );
  }
}
