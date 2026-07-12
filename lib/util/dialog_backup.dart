import 'package:flutter/material.dart';

import 'package:jiffy/jiffy.dart';
import 'package:git_repo_watcher/util/shared_pref_util.dart';
import 'app_constants.dart';
import 'backup_utils.dart';

class DialogBackup extends StatefulWidget {
  final bool isCreateBackup;
  final Function refreshList;

  const DialogBackup({super.key, required this.refreshList, required this.isCreateBackup});

  @override
  State<DialogBackup> createState() => _DialogBackupState();
}

class _DialogBackupState extends State<DialogBackup> {
  Future<void> _createBackup() async {
    await BackupUtils().backupData();
    String currentDate = Jiffy.now().format(pattern: 'dd/MM/yyyy');
    await SharedPrefUtil.saveData(AppConstants.sharedPrefsLastBackupDateKey, currentDate);
  }

  Future<void> _restoreFromBackup() async {
    await BackupUtils().restoreBackupData();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Confirm",
      ),
      content: Text(
        widget.isCreateBackup ? "Create backup ?" : "Restore backup ?",
      ),
      actions: [
        TextButton(
          child: const Text(
            "Yes",
          ),
          onPressed: () async {
            if (widget.isCreateBackup) {
              Navigator.of(context).pop();
              _createBackup();
            } else {
              Navigator.of(context).pop();
              await _restoreFromBackup();
              widget.refreshList();
            }
          },
        )
      ],
    );
  }
}
