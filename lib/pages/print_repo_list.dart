import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:git_repo_watcher/db/repository_dao.dart';

class PrintRepoList extends StatefulWidget {
  PrintRepoList({Key? key}) : super(key: key);

  @override
  _PrintRepoListState createState() => _PrintRepoListState();
}

class _PrintRepoListState extends State<PrintRepoList> {
  final db = RepositoryDao.instance;
  bool loading = true;
  String formattedList = '';

  @override
  void initState() {
    getPlaylists();
    super.initState();
  }

  void getPlaylists() async {
    List<Map<String, dynamic>> list = await db.queryAllRowsByName();

    for (int i = 0; i < list.length; i++) {
      formattedList += "\n• " + list[i]['name'];
      formattedList += "\n" + list[i]['link'] + "\n";
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print'),
        actions: [
          TextButton(
            child: const Text(
              "Copy",
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: formattedList));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        children: [
          (loading)
              ? const SizedBox.shrink()
              : SelectableText(
                  formattedList,
                  style: const TextStyle(fontSize: 16),
                ),
          const SizedBox(height: 30,)
        ],
      ),
    );
  }
}
