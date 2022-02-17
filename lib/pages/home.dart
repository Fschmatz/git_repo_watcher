import 'package:flutter/material.dart';
import 'package:git_repo_watcher/classes/repository.dart';
import 'package:git_repo_watcher/db/repository_dao.dart';
import 'package:git_repo_watcher/pages/new_repository.dart';
import 'package:git_repo_watcher/pages/settings/settings_page.dart';
import 'package:git_repo_watcher/widgets/repository_card.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> repositoriesList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getAllSavedRepositories();
  }

  Future<void> getAllSavedRepositories() async {
    final repositories = RepositoryDao.instance;
    var resp = await repositories.queryAllRowsDesc();

    setState(() {
      loading = false;
      repositoriesList = resp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Git Repo Watcher'),
        actions: [
          IconButton(
              icon: const Icon(
                Icons.add_outlined,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const NewRepository(),
                      fullscreenDialog: true,
                    ));
              }),
          const SizedBox(
            width: 8,
          ),
          IconButton(
              icon: const Icon(
                Icons.settings_outlined,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const SettingsPage(),
                      fullscreenDialog: true,
                    ));
              }),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: loading
            ? const Center(child: SizedBox.shrink())
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: repositoriesList.length,
                      itemBuilder: (context, index) {
                        return RepositoryCard(
                            key: UniqueKey(),
                            repository: Repository(
                              id: repositoriesList[index]['id'],
                              link: repositoriesList[index]['link'],
                              name: repositoriesList[index]['link'],
                            ));
                      },
                    ),
                    const SizedBox(
                      height: 50,
                    )
                  ]),
      ),
    );
  }
}
