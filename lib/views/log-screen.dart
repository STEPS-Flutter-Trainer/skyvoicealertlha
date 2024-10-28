// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as path;
//
// import '../download-log/api-controller.dart';
// class LogScreen extends StatefulWidget {
//   const LogScreen({super.key});
//
//   @override
//   State<LogScreen> createState() => _LogScreenState();
// }
//
// class _LogScreenState extends State<LogScreen> {
//   List<File> _savedTxtFiles = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSavedTxtFiles();
//   }
//
//   // Method to load saved .txt files
//   Future<void> _loadSavedTxtFiles() async {
//     final files = await _getSavedTxtFiles();
//     setState(() {
//       _savedTxtFiles = files;
//     });
//   }
//
//   // Method to get saved .txt files from app's directory
//   Future<List<File>> _getSavedTxtFiles() async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final List<FileSystemEntity> files = directory.listSync();
//       List<File> savedTxtFiles = files
//           .where((entity) =>
//       entity is File && path.extension(entity.path) == '.txt') // Filter for .txt files
//           .map((entity) => File(entity.path))
//           .toList();
//       return savedTxtFiles;
//     } catch (e) {
//       print('Error getting saved .txt files: $e');
//       return [];
//     }
//   }
//   final ApiController _apiController = ApiController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         backgroundColor: Color(0xFF198754),
//         title: Text('Logs', style: TextStyle(color: Colors.white)),
//         actions: [
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: TextButton(
//                 onPressed: () {
//                   // Action for the download button
//                   print('Download clicked');
//                   _apiController.handleRequests(context);
//                 },
//                 style: TextButton.styleFrom(
//                   backgroundColor: Color(0xFFF4EA12), // Background color of the button
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.0), // Rounded corners
//                   ),
//                 ),
//                 child: Text(
//                   'Download',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontFamily: "Roboto",
//                     fontSize: 12.sp,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: _savedTxtFiles.isEmpty
//           ? Center(child: CircularProgressIndicator()) // Show loading indicator while files are being loaded
//           : ListView.builder(
//         itemCount: _savedTxtFiles.length,
//         itemBuilder: (context, index) {
//           final file = _savedTxtFiles[index];
//           return SizedBox(
//             height: 102,
//             child: Card(
//               elevation: 4,
//               child: Center(
//                 child: ListTile(
//                   title: Text(
//                     path.basename(file.path),
//                     style: TextStyle(
//                       fontFamily: "Roboto",
//                       color: Colors.black,
//                       fontSize: 12.sp,
//                     ),
//                   ), // Display the file name
//                   trailing: SizedBox(
//                     height: 180.h,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         // Call the upload method for non-uploaded files
//                         print('Sent to Holymicro: ${file.path}');
//                       },
//                       style: ButtonStyle(
//                         backgroundColor: MaterialStateProperty.all<Color>(
//                           const Color(0xFF0C7C3C),
//                         ),
//                       ),
//                       child: Text(
//                         'Sent to Holymicro',
//                         style: TextStyle(
//                           fontFamily: "Roboto",
//                           color: Colors.white,
//                           fontSize: 12.sp,
//                         ),
//                       ),
//                     ),
//                   ),
//                   onTap: () async {
//                     // Handle the tap to open the file
//                   },
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../download-log/api-controller.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  List<File> _savedTxtFiles = [];

  @override
  void initState() {
    super.initState();
    _loadSavedTxtFiles();
  }

  // Method to load saved .txt files
  Future<void> _loadSavedTxtFiles() async {
    final files = await _getSavedTxtFiles();
    setState(() {
      _savedTxtFiles = files;
    });
  }

  Future<List<File>> _getSavedTxtFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final List<FileSystemEntity> files = directory.listSync();

      // Filter for .txt files and sort them by last modified time in descending order
      List<File> savedTxtFiles = files
          .where((entity) =>
              entity is File &&
              path.extension(entity.path) == '.txt') // Filter for .txt files
          .map((entity) => File(entity.path))
          .toList()
        ..sort((a, b) => b
            .lastModifiedSync()
            .compareTo(a.lastModifiedSync())); // Sort by last modified time

      return savedTxtFiles;
    } catch (e) {
      print('Error getting saved .txt files: $e');
      return [];
    }
  }

  void _handleDownload() async {
    // Action for the download button
    print('Download clicked');

    // Perform the download operation
  //  await _apiController.handleRequests(context);

    // Refresh the list of saved .txt files
    await _loadSavedTxtFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF198754),
        title: Text('Logs', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              _clearDownloadedFiles(); // Call the clear method when button is pressed
            },
          ),
        ],
      ),
      body: _savedTxtFiles.isEmpty
          ? const Center(
              child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: Color(0xFF0C7C3C),
                  )))

          // Show loading indicator while files are being loaded
          : ListView.builder(
              itemCount: _savedTxtFiles.length,
              itemBuilder: (context, index) {
                final file = _savedTxtFiles[index];
                return SizedBox(
                  height: 102,
                  child: Card(
                    elevation: 4,
                    child: Center(
                      child: ListTile(
                        title: Text(
                          path.basename(file.path),
                          style: TextStyle(
                            fontFamily: "Roboto",
                            color: Colors.black,
                            fontSize: 12.sp,
                          ),
                        ), // Display the file name
                        trailing: SizedBox(
                          height: 80.h,
                          child: ElevatedButton(
                            onPressed: () {
                              // Call the upload method for non-uploaded files
                              print('Sent to Holymicro: ${file.path}');
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFF0C7C3C),
                              ),
                            ),
                            child: Text(
                              'Sent to Holymicro',
                              style: TextStyle(
                                fontFamily: "Roboto",
                                color: Colors.white,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                        onTap: () async {
                          // Handle the tap to open the file
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Container(
        width: 180.w,
        height: 80.h,
        // Set your desired width
        decoration: BoxDecoration(
          color: const Color(0xFFF7572D),
          borderRadius:
              BorderRadius.circular(30), // Adjust the radius for curved corners
        ),
        child: TextButton(
          onPressed: () {
            _handleDownload();

            if (kDebugMode) {
              print('Download Log Files clicked!');
            }
            // You can call your download logic here
          },
          child: Text(
            "Download Log Files",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Method to clear all downloaded .txt files
  Future<void> _clearDownloadedFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final List<FileSystemEntity> files = directory.listSync();

      // Iterate through the files and delete .txt files
      for (var file in files) {
        if (file is File && path.extension(file.path) == '.txt') {
          await file.delete();
          print('Deleted file: ${file.path}');
        }
      }

      // Refresh the list after clearing
      await _loadSavedTxtFiles();
    } catch (e) {
      print('Error clearing .txt files: $e');
    }
  }
}
