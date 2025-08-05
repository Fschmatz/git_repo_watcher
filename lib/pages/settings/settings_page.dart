import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:git_repo_watcher/pages/print_repo_list.dart';

import '../../util/app_details.dart';
import '../../util/dialog_backup.dart';
import '../../util/dialog_select_theme.dart';
import 'app_info_page.dart';
import 'changelog_page.dart';

class SettingsPage extends StatefulWidget {
  final Function refreshList;

  const SettingsPage({Key? key, required this.refreshList}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String getThemeStringFormatted() {
    String theme = EasyDynamicTheme.of(context).themeMode.toString().replaceAll('ThemeMode.', '');
    if (theme == 'system') {
      theme = 'system default';
    }
    return theme.replaceFirst(theme[0], theme[0].toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    Color? themeColorApp = Theme.of(context).colorScheme.primary;
    TextStyle textStyleSectionTitle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: themeColorApp);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.fromLTRB(16, 20, 16, 25),
            color: themeColorApp,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            child: ListTile(
              title: Text(
                "${AppDetails.appName} ${AppDetails.appVersion}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17.5, color: Colors.black87),
              ),
            ),
          ),
          ListTile(
            title: Text(
              "General",
              style: textStyleSectionTitle,
            ),
          ),
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
          ListTile(
            title: Text("Backup", style: textStyleSectionTitle),
          ),
          ListTile(
            onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return DialogBackup(
                    isCreateBackup: true,
                    refreshList: () => {},
                  );
                }),
            leading: const Icon(Icons.save_outlined),
            title: const Text(
              "Backup now",
            ),
          ),
          ListTile(
            onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return DialogBackup(
                    isCreateBackup: false,
                    refreshList: widget.refreshList,
                  );
                }),
            leading: const Icon(Icons.settings_backup_restore_outlined),
            title: const Text(
              "Restore from backup",
            ),
          ),
          ListTile(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const PrintRepoList())),
            leading: const Icon(Icons.print_outlined),
            title: const Text("Print repository list"),
          ),
          ListTile(
            title: Text(
              "About",
              style: textStyleSectionTitle,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("App info"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const AppInfoPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text("Changelog"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const ChangelogPage()));
            },
          ),
          ListTile(
            title: Text(
              "Alert",
              style: textStyleSectionTitle,
            ),
          ),
          const ListTile(
            leading: Icon(Icons.report_problem_outlined),
            title: Text("GitHub only allows 60 API calls per hour for each IP, so the app will only update the items with user action."),
          ),
          const SizedBox(height: 75),
        ],
      ),
    );
  }
}
