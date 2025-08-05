import 'package:flutter/material.dart';

import '../../util/app_details.dart';

class ChangelogPage extends StatelessWidget {
  const ChangelogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color? themeColorApp = Theme.of(context).colorScheme.primary;
    TextStyle textStyleSectionTitle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: themeColorApp);

    return Scaffold(
      appBar: AppBar(title: const Text("Changelog")),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              "Current Version",
              style: textStyleSectionTitle,
            ),
          ),
          ListTile(title: Text(AppDetails.changelogCurrent)),
          ListTile(
            title: Text(
              "Previous Versions",
              style: textStyleSectionTitle,
            ),
          ),
          ListTile(title: Text(AppDetails.changelogsOld)),
        ],
      ),
    );
  }
}
