import 'dart:io';
import 'dart:convert'; // For encoding JSON and Base64
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skyvoicealertlha/upload/upload_file_controller.dart';
import 'package:skyvoicealertlha/upload/upload_file_model.dart';

class LogUpload extends StatefulWidget {
  @override
  _LogUploadState createState() => _LogUploadState();
}

class _LogUploadState extends State<LogUpload> {
  final TxtFileController _controller = TxtFileController();
  List<TxtFileModel> txtFiles = [];
  bool isUploaded = false; // Track upload state

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoadFiles();
  }

  Future<void> _checkPermissionsAndLoadFiles() async {
    if (Platform.isAndroid) {
      final permissionGranted = await _controller.requestStoragePermission();
      if (permissionGranted) {
        print('Storage permission granted');
        await _loadFiles();
      } else {
        print('Storage permission denied');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Permission denied to access storage")),
        );
      }
    }
  }


  Future<void> _loadFiles() async {
    try {
      final files = await _controller.loadTxtFiles(); // Load files from the controller
      setState(() {
        txtFiles = files;
      });

      // Print file names to console
      if (files.isNotEmpty) {
        print("Files loaded: ${files.length}");
        for (var file in files) {
          print("File name: ${file.name}"); // Print file name to console
        }
      } else {
        print("No files found.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      print("Error loading files: $e"); // Print error to console
    }
  }



  String _formatFileName(String fileName) {
    List<String> parts = fileName.split('_');
    return jsonEncode({
      "file_name": fileName,
      "serial_number": parts[0],
      "date": parts[1],
      "time": parts[2].split('.').first // Remove .txt part
    });
  }

  Future<String> _getBase64Content(String filePath) async {
    final file = File(filePath);
    List<int> fileBytes = await file.readAsBytes(); // Get file bytes
    return base64Encode(fileBytes); // Convert to Base64
  }

  Future<void> _uploadFile(String filePath) async {
    final file = File(filePath);
    final fileName = file.path.split('/').last;

    final base64Content = await _getBase64Content(filePath); // Get Base64 encoded content

    final jsonFileData = jsonEncode({
      "files": [
        {
          "file_name": fileName,
          "serial_number": fileName.split('_')[0],
          "date": fileName.split('_')[1],
          "time": fileName.split('_')[2].split('.').first, // Remove .txt
          "base64_content": base64Content // Include base64 data
        }
      ],
      "Type": "save_files"
    });

    final uri = Uri.parse("http://your-server.com/upload.php"); // Replace with your server URL

    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    // Add JSON data to the request
    request.fields['data'] = jsonFileData;

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        setState(() {
          isUploaded = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File uploaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File upload failed!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Text Files List"),
      ),
      body: ListView.builder(
        itemCount: txtFiles.length,
        itemBuilder: (context, index) {
          final file = txtFiles[index];
          return SizedBox(
            height: 100, // Adjusted height for better alignment
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spacing between file name and button
                  children: [
                    Text(
                      file.name, // Display file name
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      overflow: TextOverflow.ellipsis, // Handle long file names gracefully
                    ),
                    SizedBox(
                      height: 55,
                      child: TextButton(
                        onPressed: () {
                          _uploadFile(file.path); // Handle upload action
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: isUploaded ? const Color(0xFFf7572d) : const Color(0xFF198754), // Button color
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(isUploaded ? 'Send again' : 'Send to server'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadFiles,
        backgroundColor: const Color(0xFF198754), // Green color
        child: Icon(Icons.refresh, color: Colors.white),
        tooltip: 'Refresh List',
      ),
    );
  }
}

class TextFileViewer extends StatelessWidget {
  final String fileContent;

  TextFileViewer({required this.fileContent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("File Content"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(fileContent),
      ),
    );
  }
}
