// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as path;
// import 'package:http/http.dart' as http;
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
//
//     // Execute the HTTP requests
//     _executeRequests();
//
//     // Load saved .txt files
//     _loadSavedTxtFiles();
//   }
//
//   // Method to execute the HTTP requests
//   Future<void> _executeRequests() async {
//     // Call the regStatusCheck and postMaintenanceLogin methods
//     await regStatusCheck();
//     await postMaintenanceLogin();
//   }
//
//   // First request: RegStatusCheck
//   Future<http.Response> regStatusCheck() async {
//     final String baseUrl = 'http://192.168.20.1';
//     final url = Uri.parse('$baseUrl/RegStatusCheck');
//     var regFormData = {'warranty': '1'};
//
//     print('Sending RegStatusCheck POST request to $url with data: $regFormData');
//
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//       body: regFormData,
//     );
//
//     if (response.statusCode == 200) {
//       print('RegStatusCheck successful. Response: ${response.body}');
//     } else {
//       print('RegStatusCheck failed. Status code: ${response.statusCode}');
//     }
//
//     return response;
//   }
//
//   // Second request: PostMaintenanceLogin
//   Future<http.Response> postMaintenanceLogin() async {
//     final String baseUrl = 'http://192.168.20.1';
//     final url = Uri.parse('$baseUrl/PostMaintenanceLogin');
//     var loginFormData = {'Password': '1997@abcd'};
//
//     print('Sending PostMaintenanceLogin POST request to $url with data: $loginFormData');
//
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//       body: loginFormData,
//     );
//
//     if (response.statusCode == 200) {
//       print('PostMaintenanceLogin successful. Response: ${response.body}');
//     } else {
//       print('PostMaintenanceLogin failed. Status code: ${response.statusCode}');
//     }
//
//     return response;
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
//           .where((entity) => entity is File && path.extension(entity.path) == '.txt') // Filter for .txt files
//           .map((entity) => File(entity.path))
//           .toList()
//         ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync())); // Sort by last modified time
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
// }
//
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
//
// import 'api-service.dart';
//
// class FileListScreen extends StatefulWidget {
//   @override
//   _FileListScreenState createState() => _FileListScreenState();
// }
//
// class _FileListScreenState extends State<FileListScreen> {
//   List<File> _savedTxtFiles = [];
//   final ApiService _apiService = ApiService(); // Ensure this is declared
//   bool _isLoggingEnabled = false; // Track logging status
//
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Execute the HTTP requests
//     _executeRequests();
//
//     // Load saved .txt files
//     _loadSavedTxtFiles();
//   }
//
//   // Method to execute the HTTP requests
//   Future<void> _executeRequests() async {
//     await _apiService.regStatusCheck();
//     await _apiService.postMaintenanceLogin();
//     await _apiService.checkLoggerConfig(); // Automatically checks and enables logging if needed
//   }
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
//           .where((entity) => entity is File && path.extension(entity.path) == '.txt')
//           .map((entity) => File(entity.path))
//           .toList()
//         ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
//
//       return savedTxtFiles;
//     } catch (e) {
//       print('Error getting saved .txt files: $e');
//       return [];
//     }
//   }
//
//   // Triggered by the "Download Log Files" button
//   // Updated handleEnableLog to update the enable_logging value
//   Future<void> _handleEnableLog() async {
//     await _apiService.enableLoggingConfig(); // This should work now
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Logging enabled successfully!")),
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: const Color(0xFF198754),
//         title: const Text('Logs-Test', style: TextStyle(color: Colors.white)),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete, color: Colors.white),
//             onPressed: _clearDownloadedFiles,
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: Size(MediaQuery.of(context).size.width, 50),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 ElevatedButton(
//                   onPressed: _handleEnableLog, // Enable log on button press
//                   child: const Text("Enable Log"),
//                 ),
//                 ElevatedButton(
//                   onPressed: _handleEnableLog, // Download log files
//                   child: const Text("Download Log Files"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: _savedTxtFiles.isEmpty
//           ? const Center(
//         child: CircularProgressIndicator(color: Color(0xFF0C7C3C)),
//       )
//           : ListView.builder(
//         itemCount: _savedTxtFiles.length,
//         itemBuilder: (context, index) {
//           final file = _savedTxtFiles[index];
//           return SizedBox(
//             height: 102,
//             child: Card(
//               elevation: 4,
//               child: ListTile(
//                 title: Text(
//                   path.basename(file.path),
//                   style: TextStyle(fontSize: 12.sp),
//                 ),
//                 trailing: SizedBox(
//                   height: 80.h,
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       await _sendFileToHolymicro(file.path, index);
//                     },
//                     style: ButtonStyle(
//                       backgroundColor: MaterialStateProperty.all<Color>(
//                         const Color(0xFF0C7C3C),
//                       ),
//                     ),
//                     child: const Text(
//                       'Send to Holymicro',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
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
//       for (var file in files) {
//         if (file is File && path.extension(file.path) == '.txt') {
//           await file.delete();
//           print('Deleted file: ${file.path}');
//         }
//       }
//
//       await _loadSavedTxtFiles();
//     } catch (e) {
//       print('Error clearing .txt files: $e');
//     }
//   }
//
//   // Method to send a file to Holymicro
//   Future<void> _sendFileToHolymicro(String filePath, int index) async {
//     try {
//       // Encode the file to Base64
//       final file = File(filePath);
//       final bytes = await file.readAsBytes();
//       final encodedContent = base64Encode(bytes);
//
//       // Send file to the server or perform an action
//       print('Sending file to Holymicro: $encodedContent');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("File sent to Holymicro")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error sending file: $e")),
//       );
//     }
//   }
//
// }
//
//
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
//
// import 'api-service.dart';
//
// class FileListScreen extends StatefulWidget {
//   @override
//   _FileListScreenState createState() => _FileListScreenState();
// }
//
// class _FileListScreenState extends State<FileListScreen> {
//   List<File> _savedTxtFiles = [];
//   final ApiService _apiService = ApiService(); // Ensure this is declared
//   bool _isLoggingEnabled = false; // Track logging status
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Execute the HTTP requests
//     _executeRequests();
//
//     // Load saved .txt files
//     _loadSavedTxtFiles();
//   }
//
//   // Method to execute the HTTP requests
//   Future<void> _executeRequests() async {
//     await _apiService.regStatusCheck();
//     await _apiService.postMaintenanceLogin();
//     await _apiService.checkLoggerConfig(); // Automatically checks and enables logging if needed
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
//           .where((entity) => entity is File && path.extension(entity.path) == '.txt')
//           .map((entity) => File(entity.path))
//           .toList()
//         ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
//
//       return savedTxtFiles;
//     } catch (e) {
//       print('Error getting saved .txt files: $e');
//       return [];
//     }
//   }
//
//   // Method to toggle logging status
//   Future<void> _toggleLogging() async {
//     if (_isLoggingEnabled) {
//       // If logging is enabled, disable it
//       await _apiService.disableLoggingConfig(); // Make sure you have this method in your ApiService
//       setState(() {
//         _isLoggingEnabled = false; // Update state
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Logging disabled!")),
//       );
//     } else {
//       // If logging is disabled, enable it
//       await _apiService.enableLoggingConfig();
//       setState(() {
//         _isLoggingEnabled = true; // Update state
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Logging enabled!")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: const Color(0xFF198754),
//         title: const Text('Logs-Test', style: TextStyle(color: Colors.white)),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete, color: Colors.white),
//             onPressed: _clearDownloadedFiles,
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: Size(MediaQuery.of(context).size.width, 50),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 ElevatedButton(
//                   onPressed: _toggleLogging, // Toggle log on button press
//                   child: Text(_isLoggingEnabled ? "Disable Log" : "Enable Log"),
//                 ),
//                 ElevatedButton(
//                   onPressed: _handleDownloadLogFiles, // Placeholder for download logic
//                   child: const Text("Download Log Files"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: _savedTxtFiles.isEmpty
//           ? const Center(
//         child: CircularProgressIndicator(color: Color(0xFF0C7C3C)),
//       )
//           : ListView.builder(
//         itemCount: _savedTxtFiles.length,
//         itemBuilder: (context, index) {
//           final file = _savedTxtFiles[index];
//           return SizedBox(
//             height: 102,
//             child: Card(
//               elevation: 4,
//               child: ListTile(
//                 title: Text(
//                   path.basename(file.path),
//                   style: TextStyle(fontSize: 12.sp),
//                 ),
//                 trailing: SizedBox(
//                   height: 80.h,
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       await _sendFileToHolymicro(file.path, index);
//                     },
//                     style: ButtonStyle(
//                       backgroundColor: MaterialStateProperty.all<Color>(
//                         const Color(0xFF0C7C3C),
//                       ),
//                     ),
//                     child: const Text(
//                       'Send to Holymicro',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
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
//       for (var file in files) {
//         if (file is File && path.extension(file.path) == '.txt') {
//           await file.delete();
//           print('Deleted file: ${file.path}');
//         }
//       }
//
//       await _loadSavedTxtFiles();
//     } catch (e) {
//       print('Error clearing .txt files: $e');
//     }
//   }
//
//   // Method to send a file to Holymicro
//   Future<void> _sendFileToHolymicro(String filePath, int index) async {
//     try {
//       // Encode the file to Base64
//       final file = File(filePath);
//       final bytes = await file.readAsBytes();
//       final encodedContent = base64Encode(bytes);
//
//       // Send file to the server or perform an action
//       print('Sending file to Holymicro: $encodedContent');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("File sent to Holymicro")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error sending file: $e")),
//       );
//     }
//   }
//
//   // Placeholder method for downloading log files
//   Future<void> _handleDownloadLogFiles() async {
//     // Implement your download logic here
//     print('Downloading log files...');
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Log files downloaded.")),
//     );
//   }
// } //OK

//26Oct2024 - 5:30PM
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'api-service.dart';

class FileListScreen extends StatefulWidget {
  @override
  _FileListScreenState createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  List<File> _savedTxtFiles = [];
  final ApiService _apiService = ApiService();
  final baseUrl = "http://192.168.20.1";

  bool isLoggingEnabled = false;
  bool isLoggerRunning = false;
  String message1 = "";
  String message2 = "";
  String message3 = "";
  String message4 = "";

  @override
  void initState() {
    super.initState();
    _apiService.regStatusCheck();
    _apiService.postMaintenanceLogin();
    getLoggerConfig();
    _loadSavedTxtFiles(); // Load saved files on initialization
  }

  Future<void> getLoggerConfig() async {
    final url = Uri.parse('$baseUrl/getLoggerConfig');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: _getCurrentTimeParams(),
    );

    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print('Parsed JSON: $jsonResponse');

      setState(() {
        isLoggingEnabled = jsonResponse['enable_logging'] == 1;
        isLoggerRunning = jsonResponse['logger_status'] == 1;
        message1 = jsonResponse['message1'] ?? '';
        message2 = jsonResponse['message2'] ?? '';
        message3 = jsonResponse['message3'] ?? '';
        message4 = jsonResponse['message4'] ?? '';
      });
    } else {
      print('Failed to load logger config. Status code: ${response.statusCode}');
    }
  }

  Map<String, String> _getCurrentTimeParams() {
    final DateTime now = DateTime.now();
    return {
      'year': now.year.toString(),
      'month': now.month.toString(),
      'date': now.day.toString(),
      'dayOfWeek': now.weekday.toString(),
      'hour': now.hour.toString(),
      'min': now.minute.toString(),
      'sec': now.second.toString(),
    };
  }

  void toggleLogging(bool enabled) {
    print('Toggling logging: ${enabled ? "Enable" : "Disable"} logging');
    setState(() {
      isLoggingEnabled = enabled;
    });
    if (enabled) {
      startLogging();
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      '', // placeholder for 0 index
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month];
  }

  Future<void> startLogging() async {
    print('Starting logging...');
    final DateTime now = DateTime.now();
    final Map<String, String> requestData = {
      'year': now.year.toString(),
      'month': (now.month).toString(),
      'date': (now.day).toString(),
      'dayOfWeek': (now.weekday).toString(),
      'hour': (now.hour).toString(),
      'min': (now.minute).toString(),
      'sec': (now.second).toString(),
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/PostStartLogger'), // Replace with your endpoint
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestData,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('Logging started: $jsonResponse');
        setState(() {
          isLoggingEnabled = true;
          isLoggerRunning = true;
        });
      } else {
        print('Failed to start logging: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }




  Future<void> postLogfile() async {
    print('Posting log file...');
    final url = Uri.parse('$baseUrl/downloadLogFile');

    // Prepare your POST data
    var logFileData = {
      'file_suffix': 'file_suffix',
      // Add other necessary parameters here if needed
    };

    print('Sending POST request to $url with data: $logFileData');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: logFileData,
    );

    print('Response Headers:');
    response.headers.forEach((key, value) {
      print('$key: $value');
    });

    if (response.statusCode == 200) {
      print('Post log file response successful. Response: ${response.body}');

      String? prefix;
      if (response.headers.containsKey('content-disposition')) {
        final contentDisposition = response.headers['content-disposition'];
        final regex = RegExp(r'filename="(.+?)"');
        final match = regex.firstMatch(contentDisposition!);
        if (match != null) {
          prefix = match.group(1)!.split('_').first;
        }
      }

      prefix = prefix ?? '';

      final now = DateTime.now();
      final formattedDate = '${now.day}${_getMonthName(now.month)}${now.year}';
      final formattedTime = '${now.hour}h${now.minute}m${now.second}s';

      final filename = '${prefix}_${formattedDate}_$formattedTime.txt';

      await _saveFileToInternal(filename, response.bodyBytes);
      await _loadSavedTxtFiles();
    } else {
      print('Post log file response failed. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> _saveFileToInternal(String fileName, List<int> bytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      String pathToFile = path.join(directory.path, fileName);
      final file = File(pathToFile);
      await file.writeAsBytes(Uint8List.fromList(bytes));
      print('File saved at $pathToFile');
    } catch (e) {
      print('Error saving file: $e');
    }
  }

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

      List<File> savedTxtFiles = files
          .where((entity) => entity is File && path.extension(entity.path) == '.txt')
          .map((entity) => File(entity.path))
          .toList()
        ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      return savedTxtFiles;
    } catch (e) {
      print('Error getting saved .txt files: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF198754),
        title: const Text('Logs-Test', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _clearDownloadedFiles,
          ),
        ],
        bottom: PreferredSize(

          preferredSize: Size(MediaQuery.of(context).size.width, 90.h),
          child: SizedBox(
            child: Container(
            height: 80.h,
              color: Colors.white,
              child: Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 50.h,

                      child: ElevatedButton(
                                    style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(
                                      const Color(0xFFF7572D),
                                  ),
                                ),
                        onPressed: () {
                          toggleLogging(!isLoggingEnabled);
                        },
                        child: Text(
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                            isLoggingEnabled ? 'Disable Logging' : 'Enable Logging'),
                      ),
                    ),
                    SizedBox(
                      height: 50.h,
                      child: ElevatedButton(

                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFFF7572D),
                          ),
                        ),
                        onPressed: () {
                          // Call the download log file function with the appropriate suffix
                          postLogfile(); // Replace with the actual file suffix you want to use
                        },
                        child:  Text('Download Log File',

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: _savedTxtFiles.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0C7C3C)),
            )
          : ListView.builder(
              itemCount: _savedTxtFiles.length,
              itemBuilder: (context, index) {
                final file = _savedTxtFiles[index];
                return SizedBox(
                  height: 102,
                  child: Card(
                    elevation: 2,
                    color: Colors.white, // Set the card color to white
                    child: Center(
                      child: ListTile(
                        title: Text(
                          path.basename(file.path),
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        trailing: SizedBox(
                          height: 80.h,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _sendFileToHolymicro(file.path, index);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFF0C7C3C),
                              ),
                            ),
                            child: const Text(
                              'Sent to Holymicro',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                );
              },
            ),
    );
  }

  Future<void> _clearDownloadedFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final List<FileSystemEntity> files = directory.listSync();

      for (var file in files) {
        if (file is File && path.extension(file.path) == '.txt') {
          await file.delete();
          print('Deleted file: ${file.path}');
        }
      }

      await _loadSavedTxtFiles();
    } catch (e) {
      print('Error clearing .txt files: $e');
    }
  }

  Future<void> _sendFileToHolymicro(String filePath, int index) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final encodedContent = base64Encode(bytes);

      if (kDebugMode) {
        print('Sending file to Holymicro: $encodedContent');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File sent to Holymicro")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending file: $e")),
      );
    }
  }
}
