import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'api-service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logger Config',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoggerConfigPage(),
    );
  }
}

class LoggerConfigPage extends StatefulWidget {
  @override
  _LoggerConfigPageState createState() => _LoggerConfigPageState();
}

class _LoggerConfigPageState extends State<LoggerConfigPage> {
  final ApiService _apiService = ApiService();

  final baseUrl="http://192.168.20.1";

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
  }

  Future<void> getLoggerConfig() async {
    final url = Uri.parse('$baseUrl/getLoggerConfig');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: _getCurrentTimeParams(),
    );

    // Printing the raw response body
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Printing the parsed JSON
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
      // Handle error
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
    setState(() {
      isLoggingEnabled = enabled;
    });
    if (enabled) {
      startLogging();
    } else {
      stopLogging();
    }
  }

  Future<void> startLogging() async {
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
          isLoggerRunning = true; // Update the logger running status
        });
      } else {
        print('Failed to start logging: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> stopLogging() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/PostStopLogger'), // Replace with your endpoint
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        print('Logging stopped');
        setState(() {
          isLoggingEnabled = false;
          isLoggerRunning = false; // Update the logger running status
        });
      } else {
        print('Failed to stop logging: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<http.Response> postLogfile() async {
    final url = Uri.parse('$baseUrl/downloadLogFile');

    // Prepare your POST data
    var logFileData = {
      'file_suffix': 'file_suffix',
      // Add other necessary parameters here if needed
    };

    print('Sending POST request to $url with data: $logFileData');

    // Perform the POST request
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: logFileData,
    );

    // Print all headers and their values
    print('Response Headers:');
    response.headers.forEach((key, value) {
      print('$key: $value');
    });

    // Check if the response is successful
    if (response.statusCode == 200) {
      print('Post log file response successful. Response: ${response.body}');

      // Extract filename from Content-Disposition header
      String? prefix;
      if (response.headers.containsKey('content-disposition')) {
        final contentDisposition = response.headers['content-disposition'];
        final regex = RegExp(r'filename="(.+?)"');
        final match = regex.firstMatch(contentDisposition!);
        if (match != null) {
          prefix = match.group(1)!.split('_').first; // Get the prefix before the underscore
        }
      }

      // If no prefix is found, fallback to a default prefix
      prefix = prefix ?? '';

      // Get the current date and time for the filename
      final now = DateTime.now();
      final formattedDate = '${now.day}${_getMonthName(now.month)}${now.year}';
      final formattedTime = '${now.hour}h${now.minute}m${now.second}s';

      // Construct the filename
      final filename = '${prefix}_${formattedDate}_$formattedTime.txt';

      // Save the file to Downloads with the formatted filename
      await _saveFileToDownloads(response.bodyBytes, filename);
    } else {
      print('Post log file response failed. Status code: ${response.statusCode}');
      print('Response body: ${response.body}'); // Log the body for debugging
    }

    return response; // Return the response object
  }

// Helper function to get month name from month number
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

// Method to save file to Downloads
  Future<void> _saveFileToDownloads(List<int> bytes, String fileName) async {
    try {
      // Get the Downloads directory (works for both Android and iOS)
      final directory = await getExternalStorageDirectory();

      // Make sure the directory exists
      if (directory != null) {
        // Build the full file path
        String pathToFile = path.join(directory.path, fileName);

        // Create the file and write the bytes
        final file = File(pathToFile);
        await file.writeAsBytes(Uint8List.fromList(bytes));
        print('File saved at $pathToFile');
      } else {
        print('Error: Downloads directory is null');
      }
    } catch (e) {
      print('Error saving file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('System Logs'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Logging Status: ${isLoggingEnabled ? "Enabled" : "Disabled"}'),
              ElevatedButton(
                onPressed: () {
                  toggleLogging(!isLoggingEnabled);
                },
                child: Text(isLoggingEnabled ? 'Disable Logging' : 'Enable Logging'),
              ),

              ElevatedButton(
                onPressed: () {
                  // Call the download log file function with the appropriate suffix
                  postLogfile(); // Replace with the actual file suffix you want to use
                },
                child: Text('Download Log File'),
              ),

              SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  // Implement delete logs functionality
                  print("Deleting logs...");
                },
                child: Text('Delete Logs'),
              ),
              SizedBox(height: 10),

            ],
          ),
        ),
      ),
    );
  }
}
