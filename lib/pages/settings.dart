import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';

import '../util/app_constants.dart';
import '../util/dialog_backup.dart';
import '../util/dialog_select_theme.dart';
import '../util/shared_pref_util.dart';
import 'app_info.dart';
import 'changelog.dart';

class Settings extends StatefulWidget {
  final Function refreshList;

  const Settings({super.key, required this.refreshList});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String? _lastBackupDate;

  @override
  void initState() {
    super.initState();

    _loadLastBackupDate();
  }

  Future<void> _loadLastBackupDate() async {
    final date = await SharedPrefUtil.loadData<String>(AppConstants.sharedPrefsLastBackupDateKey);
   
    if (mounted) {
      setState(() {
        _lastBackupDate = date;
      });
    }
  }

  String getThemeStringFormatted() {
    String theme = EasyDynamicTheme.of(context).themeMode.toString().replaceAll('ThemeMode.', '');
    if (theme == 'system') {
      theme = 'system default';
    }
    return theme.replaceFirst(theme[0], theme[0].toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: <Widget>[
          Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    "General",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () => showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const DialogSelectTheme();
                          },
                        ),
                        leading: const Icon(Icons.brightness_6_outlined),
                        title: const Text("App theme"),
                        subtitle: Text(getThemeStringFormatted()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    "Backup",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return DialogBackup(
                                isCreateBackup: true,
                                refreshList: () => {},
                              );
                            },
                          );
                          _loadLastBackupDate();
                        },
                        leading: const Icon(Icons.save_outlined),
                        title: const Text("Backup now"),
                        subtitle: _lastBackupDate != null ? Text("Last backup: $_lastBackupDate") : null,
                      ),
                      Divider(),
                      ListTile(
                        onTap: () => showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DialogBackup(
                              isCreateBackup: false,
                              refreshList: widget.refreshList,
                            );
                          },
                        ),
                        leading: const Icon(Icons.settings_backup_restore_outlined),
                        title: const Text("Restore from backup"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    "About",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text("App info"),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const AppInfo()));
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: const Icon(Icons.article_outlined),
                        title: const Text("Changelog"),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const Changelog()));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
