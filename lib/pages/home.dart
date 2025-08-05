import 'package:flutter/material.dart';
import 'package:git_repo_watcher/classes/repository.dart';
import 'package:git_repo_watcher/pages/new_repository.dart';
import 'package:git_repo_watcher/pages/settings/settings_page.dart';
import 'package:git_repo_watcher/service/repository_service.dart';
import 'package:git_repo_watcher/util/app_details.dart';
import 'package:git_repo_watcher/widgets/repository_tile.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Repository> _repositoriesList = [];
  bool _loading = true;
  bool _refreshAllRepositories = false;

  @override
  void initState() {
    super.initState();

    getAllSavedRepositories();
  }

  Future<void> getAllSavedRepositories() async {
    _repositoriesList = await RepositoryService().queryAllAndConvertToList();

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppDetails.appNameHomePage),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              setState(() {
                _refreshAllRepositories = true;
              });
            },
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert_outlined),
            itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
              const PopupMenuItem<int>(value: 0, child: Text('Add')),
              const PopupMenuItem<int>(value: 1, child: Text('Settings')),
            ],
            onSelected: (int value) {
              switch (value) {
                case 0:
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => NewRepository(refreshList: getAllSavedRepositories)));
                case 1:
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SettingsPage(refreshList: getAllSavedRepositories)));
              }
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: _loading
            ? const Center(child: SizedBox.shrink())
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  ListView.separated(
                    separatorBuilder: (BuildContext context, int index) => const Divider(height: 0),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _repositoriesList.length,
                    itemBuilder: (context, index) {
                      return RepositoryTile(
                        key: UniqueKey(),
                        refreshList: getAllSavedRepositories,
                        refreshAllRepositories: _refreshAllRepositories,
                        repository: _repositoriesList[index],
                      );
                    },
                  ),
                  const SizedBox(height: 75),
                ],
              ),
      ),
    );
  }
}
