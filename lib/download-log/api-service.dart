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
// }

//&&&&&&&&&&&Working print console&&&&&&&&&&&&&&&
// import 'dart:io';
// import 'dart:convert'; // For decoding the JSON response
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart'; // For handling date/time formatting
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
//   // Third request: GetLoggerConfig with form data
//   Future<void> checkLoggerConfig() async {
//     final url = Uri.parse('$baseUrl/getLoggerConfig');
//
//     // Get current date and time components
//     DateTime now = DateTime.now();
//     String year = DateFormat('yyyy').format(now);
//     String month = DateFormat('MM').format(now);
//     String date = DateFormat('dd').format(now);
//     String dayOfWeek = DateFormat('EEEE').format(now); // Full name of day
//     String hour = DateFormat('HH').format(now); // 24-hour format
//     String min = DateFormat('mm').format(now);
//     String sec = DateFormat('ss').format(now);
//
//     var formData = {
//       'year': year,
//       'month': month,
//       'date': date,
//       'dayOfWeek': dayOfWeek,
//       'hour': hour,
//       'min': min,
//       'sec': sec
//     };
//
//     print('Sending checkLoggerConfig POST request to $url with data: $formData');
//
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//       body: formData,
//     );
//
//     if (response.statusCode == 200) {
//       print('checkLoggerConfig successful. Response: ${response.body}');
//
//       // Parse the JSON response
//       Map<String, dynamic> jsonResponse = jsonDecode(response.body);
//
//       int enableLogging = jsonResponse['enable_logging'];
//       int loggerStatus = jsonResponse['logger_status'];
//       String message1 = jsonResponse['message1'];
//       String message2 = jsonResponse['message2'];
//       String message3 = jsonResponse['message3'];
//       String message4 = jsonResponse['message4'];
//
//       print('Logger Config:');
//       print('Enable Logging: $enableLogging');
//       print('Logger Status: $loggerStatus');
//       print('Message 1: $message1');
//       print('Message 2: $message2');
//       print('Message 3: $message3');
//       print('Message 4: $message4');
//
//       // If enable_logging is 0, you can enable logging by making another request or taking action here
//       if (enableLogging == 0) {
//         print('Enable logging is currently disabled. Enabling logging...');
//         await enableLoggingConfig(); // Call method to enable logging
//       }
//     } else {
//       print('checkLoggerConfig failed. Status code: ${response.statusCode}');
//     }
//   }
//
//   // Method to enable logging
//   Future<void> enableLoggingConfig() async {
//     final url = Uri.parse('$baseUrl/setLoggerConfig');
//     var enableLoggingFormData = {'enable_logging': '1'}; // Enabling logging by setting this to 1
//
//     print('Sending enableLoggingConfig POST request to $url with data: $enableLoggingFormData');
//
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//       body: enableLoggingFormData,
//     );
//
//     if (response.statusCode == 200) {
//       print('Logging enabled successfully.');
//     } else {
//       print('Failed to enable logging. Status code: ${response.statusCode}');
//     }
//   }
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
//    //   final formattedDate = '${now.day}${_getMonthName(now.month)}${now.year}';
//       final formattedTime = '${now.hour}h${now.minute}m${now.second}s';
//
//       // Construct the filename
//      // final filename = '${prefix}_${formattedDate}_$formattedTime.txt';
//
//       // Save the file to Downloads with the formatted filename
//       // await _saveFileToDownloads(
//       //   response.bodyBytes,
//       //   filename,
//       // );
//     } else {
//       print('Post log file response failed. Status code: ${response.statusCode}');
//     }
//
//     return response; // Return the response object
//   }
// }


// Enable_logging 0 to 1
import 'dart:io';
import 'dart:convert'; // For decoding the JSON response
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For handling date/time formatting

class ApiService {
  final String baseUrl = 'http://192.168.20.1';

  // First request: RegStatusCheck
  Future<http.Response> regStatusCheck() async {
    final url = Uri.parse('$baseUrl/RegStatusCheck');
    var regStatusFormData = {'warranty': '1'};

    try {
      print('Sending RegStatusCheck POST request to $url with data: $regStatusFormData');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: regStatusFormData,
      );

      if (response.statusCode == 200) {
        print('Registration status check successful: ${response.body}');
      } else {
        print('Failed to check registration status. Status code: ${response.statusCode}');
      }

      return response; // Return the response object
    } catch (e) {
      print('Error occurred: $e');
      // You might want to return a response with an error status if needed
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Second request: PostMaintenanceLogin
  Future<http.Response> postMaintenanceLogin() async {
    final url = Uri.parse('$baseUrl/PostMaintenanceLogin');
    var loginFormData = {'Password': '1997@abcd'};

    print('Sending PostMaintenanceLogin POST request to $url with data: $loginFormData');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: loginFormData,
    );

    if (response.statusCode == 200) {
      print('PostMaintenanceLogin successful. Response: ${response.body}');
    } else {
      print('PostMaintenanceLogin failed. Status code: ${response.statusCode}');
    }

    return response;
  }


}