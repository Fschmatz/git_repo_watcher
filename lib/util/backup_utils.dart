import 'dart:convert';
import 'dart:io';

import 'package:git_repo_watcher/util/toast_utils.dart';
import 'package:permission_handler/permission_handler.dart';

import '../service/repository_service.dart';

class BackupUtils {
  final RepositoryService repositoryService = RepositoryService();

  /* PER APP SPECIFIC FUNCTIONS */

  Future<List<Map<String, dynamic>>> _loadAll() async {
    return repositoryService.queryAll();
  }

  Future<void> _deleteAll() async {
    await repositoryService.deleteAll();
  }

  Future<void> _insertAll(List<dynamic> jsonData) async {
    await repositoryService.insertFromRestoreBackup(jsonData);
  }

  /* END PER APP SPECIFIC FUNCTIONS */

  Future<void> _loadStoragePermission() async {
    var status = await Permission.manageExternalStorage.status;

    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }

  // Always using Android Download folder
  Future<String> _loadDirectory() async {
    bool dirDownloadExists = true;
    String directory = "/storage/emulated/0/Download/";

    dirDownloadExists = await Directory(directory).exists();
    if (dirDownloadExists) {
      directory = "/storage/emulated/0/Download/";
    } else {
      directory = "/storage/emulated/0/Downloads/";
    }

    return directory;
  }

  Future<void> backupData(String fileName) async {
    await _loadStoragePermission();

    List<Map<String, dynamic>> list = await _loadAll();

    if (list.isNotEmpty) {
      await _saveListAsJson(list, fileName);

      ToastUtils.show("Backup completed!");
    } else {
      ToastUtils.showErrorMessage("No data found!");
    }
  }

  Future<void> _saveListAsJson(List<Map<String, dynamic>> data, String fileName) async {
    try {
      String directory = await _loadDirectory();

      final file = File('$directory/$fileName.json');

      await file.writeAsString(json.encode(data));
    } catch (e) {
      ToastUtils.showError();
    }
  }

  Future<void> restoreBackupData(String fileName) async {
    await _loadStoragePermission();

    try {
      String directory = await _loadDirectory();

      final file = File('$directory/$fileName.json');
      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = json.decode(jsonString);

      await _deleteAll();
      await _insertAll(jsonData);

      ToastUtils.show(
        "Success!",
      );
    } catch (e) {
      ToastUtils.showError();
    }
  }
}
