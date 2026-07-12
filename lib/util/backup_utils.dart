import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:git_repo_watcher/util/toast_utils.dart';
import 'package:git_repo_watcher/util/utils_functions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

  Future<void> backupData() async {
    List<Map<String, dynamic>> list = await _loadAll();

    if (list.isNotEmpty) {
      await _saveListAsJsonAndShare(list);
    } else {
      ToastUtils.showErrorMessage("No data found!");
    }
  }

  Future<bool> _saveListAsJsonAndShare(List<Map<String, dynamic>> data) async {
    try {
      final directory = await getTemporaryDirectory();
      final newFileName = getBackupFilename();
      final file = File('${directory.path}/$newFileName');

      await file.writeAsString(json.encode(data));

      await Share.shareXFiles([XFile(file.path)], text: 'Backup $newFileName');
      return true;
    } catch (e) {
      ToastUtils.showErrorMessage('Error!');
      return false;
    }
  }

  Future<bool> restoreBackupData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final List<dynamic> jsonData = json.decode(jsonString);

        await _deleteAll();
        await _insertAll(jsonData);

        ToastUtils.show("Success!");
        return true;
      }
      return false;
    } catch (e) {
      ToastUtils.showErrorMessage('Error!');
      return false;
    }
  }
}
