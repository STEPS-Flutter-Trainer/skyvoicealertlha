import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:skyvoicealertlha/upload/upload_file_model.dart';

class TxtFileController {
  // Request storage permissions

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid && Platform.version.contains('Android 11') || Platform.version.contains('API 30')) {
      return await Permission.manageExternalStorage.request().isGranted;
    } else {
      return await Permission.storage.request().isGranted;
    }
  }

  // Load .txt files from a specific directory (e.g., Downloads folder)
  Future<List<TxtFileModel>> loadTxtFiles() async {
    const directoryPath = '/storage/emulated/0/Download'; // Confirm this is correct
    Directory directory = Directory(directoryPath);

    if (!directory.existsSync()) {
      throw Exception('Directory does not exist');
    }

    List<FileSystemEntity> files = directory.listSync();
    print("Files in directory: ${files.length}");

    // Log all files found for debugging purposes
    for (var file in files) {
      print('Found: ${file.path}');
    }

    List<TxtFileModel> txtFiles = [];

    for (var file in files) {
      if (file is File && file.path.endsWith('.txt')) {
        txtFiles.add(TxtFileModel(
          name: file.path.split('/').last,
          path: file.path,
        ));
      }
    }

    return txtFiles;
  }

}
