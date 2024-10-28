//
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';
//
// class ApiService {
//   final String baseUrl = 'http://192.168.20.1';
//
//   // First request: RegStatusCheck
//   Future<http.Response> regStatusCheck() async {
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
//
//
//
//   Future<http.Response> postLogfile(String file_suffix) async {
//
//     final url = Uri.parse('$baseUrl/downloadLogFile');
//
//     // Prepare your POST data
//     var logFileData = {
//       'file_suffix': file_suffix,
//       // Add other necessary parameters here if needed
//     };
//
//     print('Sending POST request to $url with data: $logFileData');
//
//     // Perform the POST request
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//       body: logFileData,
//     );
//
//     // Print all headers and their values
//     print('Response Headers:');
//     response.headers.forEach((key, value) {
//       print('$key: $value');
//     });
//
//     // Check if the response is successful
//     if (response.statusCode == 200) {
//       print('Post log file response successful. Response: ${response.body}');
//
//       // Extract filename from Content-Disposition header
//       String? prefix;
//       if (response.headers.containsKey('content-disposition')) {
//         final contentDisposition = response.headers['content-disposition'];
//         final regex = RegExp(r'filename="(.+?)"');
//         final match = regex.firstMatch(contentDisposition!);
//         if (match != null) {
//           prefix = match.group(1)!.split('_').first; // Get the prefix before the underscore
//         }
//       }
//
//       // If no prefix is found, fallback to a default prefix
//       prefix = prefix ?? '';
//
//       // Get the current date and time for the filename
//       final now = DateTime.now();
//       final formattedDate = '${now.day}${_getMonthName(now.month)}${now.year}';
//       final formattedTime = '${now.hour}h${now.minute}m${now.second}s';
//
//       // Construct the filename
//       final filename = '${prefix}_${formattedDate}_$formattedTime.txt';
//
//       // Save the file to Downloads with the formatted filename
//       await _saveFileToDownloads(
//         response.bodyBytes,
//         filename,
//       );
//     } else {
//       print('Post log file response failed. Status code: ${response.statusCode}');
//     }
//
//     return response; // Return the response object
//   }
//
// // Helper function to get month name from month number
//   String _getMonthName(int month) {
//     const monthNames = [
//       '', // placeholder for 0 index
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];
//     return monthNames[month];
//   }
//
//
//
//   Future<void> _saveFileToDownloads(List<int> bytes, String fileName) async {
//     try {
//       String pathToFile;
//
//       // Get the app's directory (works for both Android and iOS)
//       final directory = await getApplicationDocumentsDirectory();
//
//       // Build the full file path inside the app's storage
//       pathToFile = path.join(directory.path, fileName);
//
//       // Create the file and write the bytes
//       final file = File(pathToFile);
//       await file.writeAsBytes(Uint8List.fromList(bytes));
//       print('File saved at $pathToFile');
//     } catch (e) {
//       print('Error saving file: $e');
//     }
//   }
//
// }
