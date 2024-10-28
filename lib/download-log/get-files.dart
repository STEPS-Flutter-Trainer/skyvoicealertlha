// //
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:path/path.dart' as path;
// //
// // class FileListScreen extends StatefulWidget {
// //   @override
// //   _FileListScreenState createState() => _FileListScreenState();
// // }
// //
// // class _FileListScreenState extends State<FileListScreen> {
// //   List<File> _savedFiles = [];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadSavedFiles();
// //   }
// //
// //   // Method to load saved files
// //   Future<void> _loadSavedFiles() async {
// //     final files = await _getSavedFiles();
// //     setState(() {
// //       _savedFiles = files;
// //     });
// //   }
// //
// //   // Method to get saved files from app's directory
// //   Future<List<File>> _getSavedFiles() async {
// //     try {
// //       final directory = await getApplicationDocumentsDirectory();
// //       final List<FileSystemEntity> files = directory.listSync();
// //       List<File> savedFiles = files
// //           .where((entity) => entity is File)
// //           .map((entity) => File(entity.path))
// //           .toList();
// //       return savedFiles;
// //     } catch (e) {
// //       print('Error getting saved files: $e');
// //       return [];
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Saved Files'),
// //       ),
// //       body: _savedFiles.isEmpty
// //           ? Center(child: CircularProgressIndicator()) // Show loading indicator while files are being loaded
// //           : ListView.builder(
// //         itemCount: _savedFiles.length,
// //         itemBuilder: (context, index) {
// //           final file = _savedFiles[index];
// //           return ListTile(
// //             title: Text(path.basename(file.path)), // Display the file name
// //             subtitle: Text(file.path), // Optionally, show the file path as a subtitle
// //             leading: Icon(Icons.insert_drive_file),
// //             onTap: () {
// //               // Handle file tap here (open file or perform an action)
// //               print('Tapped on: ${file.path}');
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as path;
//
// import 'api-controller.dart';
//
// class FileListScreen extends StatefulWidget {
//   @override
//   _FileListScreenState createState() => _FileListScreenState();
// }
//
// class _FileListScreenState extends State<FileListScreen> {
//   List<File> _savedTxtFiles = [];
//   final ApiController _apiController = ApiController();
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
//   Future<List<File>> _getSavedTxtFiles() async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final List<FileSystemEntity> files = directory.listSync();
//
//       // Filter for .txt files and sort them by last modified time in descending order
//       List<File> savedTxtFiles = files
//           .where((entity) =>
//               entity is File &&
//               path.extension(entity.path) == '.txt') // Filter for .txt files
//           .map((entity) => File(entity.path))
//           .toList()
//         ..sort((a, b) => b
//             .lastModifiedSync()
//             .compareTo(a.lastModifiedSync())); // Sort by last modified time
//
//       return savedTxtFiles;
//     } catch (e) {
//       print('Error getting saved .txt files: $e');
//       return [];
//     }
//   }
//
//   void _handleDownload() async {
//     // Action for the download button
//     print('Download clicked');
//
//     // Perform the download operation
//     await _apiController.handleRequests(context);
//
//     // Refresh the list of saved .txt files
//     await _loadSavedTxtFiles();
//   }
//   String? encodedContent; // Variable to store the encoded content
//   int? encodedFileIndex; // Track which file is encoded
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         backgroundColor: Color(0xFF198754),
//         title: Text('Logs-Test', style: TextStyle(color: Colors.white)),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.delete, color: Colors.white),
//             onPressed: () {
//               _clearDownloadedFiles(); // Call the clear method when button is pressed
//             },
//           ),
//         ],
//         bottom: PreferredSize(
//             preferredSize: Size(MediaQuery.of(context).size.width, 50),
//
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   ElevatedButton(
//                     style: const ButtonStyle(
//
//                     ),
//                     onPressed: () {}, child: const Text("Enable Log"), ),
//                   ElevatedButton(onPressed: () {}, child: const Text("Download Log Files")),
//                 ],
//               ),
//             )),
//       ),
//       body: _savedTxtFiles.isEmpty
//           ? const Center(
//               child: SizedBox(
//                   width: 40,
//                   height: 40,
//                   child: CircularProgressIndicator(
//                     color: Color(0xFF0C7C3C),
//                   )))
//
//           // Show loading indicator while files are being loaded
//           : ListView.builder(
//               itemCount: _savedTxtFiles.length,
//               itemBuilder: (context, index) {
//                 final file = _savedTxtFiles[index];
//                 return SizedBox(
//                   height: 102,
//                   child: Card(
//                     elevation: 4,
//                     child: Center(
//                       child: ListTile(
//                         title: Text(
//                           path.basename(file.path),
//                           style: TextStyle(
//                             fontFamily: "Roboto",
//                             color: Colors.black,
//                             fontSize: 12.sp,
//                           ),
//                         ), // Display the file name
//                         trailing: SizedBox(
//                           height: 80.h,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               _encodeFile(file.path, index);
//                               // Call the upload method for non-uploaded files
//                               print('Sent to Holymicro: ${file.path}');
//                             },
//                             style: ButtonStyle(
//                               backgroundColor: MaterialStateProperty.all<Color>(
//                                 const Color(0xFF0C7C3C),
//                               ),
//                             ),
//                             child: Text(
//                               'Sent to Holymicro',
//                               style: TextStyle(
//                                 fontFamily: "Roboto",
//                                 color: Colors.white,
//                                 fontSize: 12.sp,
//                               ),
//                             ),
//                           ),
//                         ),
//                         onTap: () async {
//                           // Handle the tap to open the file
//                         },
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//       // floatingActionButton: Container(
//       //   width: 180.w,
//       //   height: 80.h,
//       //   // Set your desired width
//       //   decoration: BoxDecoration(
//       //     color: const Color(0xFFF7572D),
//       //     borderRadius:
//       //         BorderRadius.circular(30), // Adjust the radius for curved corners
//       //   ),
//       //   child: TextButton(
//       //     onPressed: () {
//       //       _handleDownload();
//       //
//       //       if (kDebugMode) {
//       //         print('Download Log Files clicked!');
//       //       }
//       //       // You can call your download logic here
//       //     },
//       //     child: Text(
//       //       "Download Log Files",
//       //       style: TextStyle(
//       //         color: Colors.white,
//       //         fontSize: 14.sp,
//       //       ),
//       //     ),
//       //   ),
//       // ),
//       // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       //
//       //
//     );
//   }
//
//   // Method to clear all downloaded .txt files
//   Future<void> _clearDownloadedFiles() async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final List<FileSystemEntity> files = directory.listSync();
//
//       // Iterate through the files and delete .txt files
//       for (var file in files) {
//         if (file is File && path.extension(file.path) == '.txt') {
//           await file.delete();
//           print('Deleted file: ${file.path}');
//         }
//       }
//
//       // Refresh the list after clearing
//       await _loadSavedTxtFiles();
//     } catch (e) {
//       print('Error clearing .txt files: $e');
//     }
//   }
//
//   void _encodeFile(String filePath, int index) async {
//     try {
//       final file = File(filePath);
//
//       // Use file.readAsBytes() to read the file as bytes
//       final bytes = await file.readAsBytes();
//
//       // Encode the bytes to Base64
//       setState(() {
//         encodedContent = base64Encode(bytes);
//         encodedFileIndex = index; // Mark this file as encoded
//         print(encodedContent);
//       });
//
//
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error reading file: $e")),
//       );
//     }
//   }
//
//
//
// }


//demo 1
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as path;
//
// import 'api-controller.dart';
// import 'package:http/http.dart' as http;
//
// class FileListScreen extends StatefulWidget {
//   @override
//   _FileListScreenState createState() => _FileListScreenState();
// }
//
// class _FileListScreenState extends State<FileListScreen> {
//   List<File> _savedTxtFiles = [];
//   final ApiController _apiController = ApiController();
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
//   Future<List<File>> _getSavedTxtFiles() async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final List<FileSystemEntity> files = directory.listSync();
//
//       // Filter for .txt files and sort them by last modified time in descending order
//       List<File> savedTxtFiles = files
//           .where((entity) =>
//       entity is File &&
//           path.extension(entity.path) == '.txt') // Filter for .txt files
//           .map((entity) => File(entity.path))
//           .toList()
//         ..sort((a, b) => b
//             .lastModifiedSync()
//             .compareTo(a.lastModifiedSync())); // Sort by last modified time
//
//       return savedTxtFiles;
//     } catch (e) {
//       print('Error getting saved .txt files: $e');
//       return [];
//     }
//   }
//
//   void _handleDownload() async {
//     // Action for the download button
//     print('Download clicked');
//
//     // Perform the download operation
//     await _apiController.handleRequests(context);
//
//     // Refresh the list of saved .txt files
//     await _loadSavedTxtFiles();
//   }
//
//   String? encodedContent; // Variable to store the encoded content
//   int? encodedFileIndex; // Track which file is encoded
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         backgroundColor: Color(0xFF198754),
//         title: Text('Logs-Test', style: TextStyle(color: Colors.white)),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.delete, color: Colors.white),
//             onPressed: () {
//               _clearDownloadedFiles(); // Call the clear method when button is pressed
//             },
//           ),
//         ],
//         bottom: PreferredSize(
//             preferredSize: Size(MediaQuery.of(context).size.width, 50),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   ElevatedButton(
//                     style: const ButtonStyle(),
//                     onPressed: () {
//                       // Implement your enable log functionality here
//                     },
//                     child: const Text("Enable Log"),
//                   ),
//                   ElevatedButton(
//                     onPressed: _handleDownload, // Calls download method when pressed
//                     child: const Text("Download Log Files"),
//                   ),
//                 ],
//               ),
//             )),
//       ),
//       body: _savedTxtFiles.isEmpty
//           ? const Center(
//           child: SizedBox(
//               width: 40,
//               height: 40,
//               child: CircularProgressIndicator(
//                 color: Color(0xFF0C7C3C),
//               )))
//
//       // Show loading indicator while files are being loaded
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
//                     height: 80.h,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         _encodeFile(file.path, index);
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
//
//   // Method to clear all downloaded .txt files
//   Future<void> _clearDownloadedFiles() async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final List<FileSystemEntity> files = directory.listSync();
//
//       // Iterate through the files and delete .txt files
//       for (var file in files) {
//         if (file is File && path.extension(file.path) == '.txt') {
//           await file.delete();
//           print('Deleted file: ${file.path}');
//         }
//       }
//
//       // Refresh the list after clearing
//       await _loadSavedTxtFiles();
//     } catch (e) {
//       print('Error clearing .txt files: $e');
//     }
//   }
//
//   void _encodeFile(String filePath, int index) async {
//     try {
//       final file = File(filePath);
//
//       // Use file.readAsBytes() to read the file as bytes
//       final bytes = await file.readAsBytes();
//
//       // Encode the bytes to Base64
//       setState(() {
//         encodedContent = base64Encode(bytes);
//         encodedFileIndex = index; // Mark this file as encoded
//         print(encodedContent);
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error reading file: $e")),
//       );
//     }
//   }
//
//   Future<void> _postLoggerConfig() async {
//     final url = Uri.parse('http://192.168.20.1/getLoggerConfig');
//     var logConfigData = {
//       'year': '2024',
//       'month': '10',
//       'date': '23',
//       'dayOfWeek': '3',
//       'hour': '17',
//       'min': '11',
//       'sec': '48',
//     };
//
//     print('Sending POST request to $url with data: $logConfigData');
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//         body: logConfigData,
//       );
//
//       if (response.statusCode == 200) {
//         print('Logger config response successful. Response: ${response.body}');
//         // Handle the JSON response here if needed
//       } else {
//         print('Logger config response failed. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error posting logger config: $e');
//     }
//   }
// }
