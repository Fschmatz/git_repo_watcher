import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:git_repo_watcher/classes/repository.dart';
import 'package:git_repo_watcher/pages/new_repository.dart';
import 'package:git_repo_watcher/pages/settings.dart';
import 'package:git_repo_watcher/service/background_service.dart';
import 'package:git_repo_watcher/service/repository_service.dart';
import 'package:git_repo_watcher/util/app_details.dart';
import 'package:git_repo_watcher/widgets/repository_tile.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Repository> _repositoriesList = [];
  bool _loading = true;
  bool _refreshing = false;
  final Set<int> _repositoriesWithNewVersions = {};

  @override
  void initState() {
    super.initState();

    Permission.notification.request();

    getAllSavedRepositories();
  }

  Future<void> getAllSavedRepositories() async {
    _repositoriesList = await RepositoryService().queryAllAndConvertToList();

    setState(() {
      _loading = false;
    });
  }

  Future<void> refreshAllRepositories() async {
    // Evita múltiplas chamadas simultâneas
    if (_refreshing) return;

    setState(() {
      _refreshing = true;
    });

    // Registra a tarefa única que rodará no background
    await Workmanager().registerOneOffTask(
      BackgroundService.taskName,
      BackgroundService.taskName,
    );

    if (mounted) {
      setState(() {
        _refreshing = false;
      });
    }

    Fluttertoast.showToast(msg: "Refresh started.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppDetails.appNameHomePage),
        actions: [
          IconButton(
            icon: _refreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(),
                  )
                : const Icon(Icons.refresh_outlined),
            onPressed: _refreshing ? null : refreshAllRepositories,
          ),
          PopupMenuButton<int>(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            icon: const Icon(Icons.more_vert_outlined),
            itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
              PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: const [
                    Icon(Icons.add_outlined),
                    SizedBox(width: 12),
                    Text('Add'),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: const [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
            onSelected: (int value) {
              switch (value) {
                case 0:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => NewRepository(refreshList: getAllSavedRepositories),
                    ),
                  );
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => Settings(refreshList: getAllSavedRepositories),
                    ),
                  );
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _repositoriesList.length,
                    itemBuilder: (context, index) {
                      Repository repo = _repositoriesList[index];

                      return RepositoryTile(
                        key: ValueKey(repo.id),
                        refreshList: getAllSavedRepositories,
                        repository: repo,
                        hasNewVersion: _repositoriesWithNewVersions.contains(repo.id),
                        onNewVersionDetected: () {
                          setState(() {
                            _repositoriesWithNewVersions.add(repo.id!);
                          });
                        },
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
