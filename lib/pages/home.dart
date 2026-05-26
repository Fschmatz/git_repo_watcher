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
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  List<Repository> _repositoriesList = [];
  bool _loading = true;
  bool _refreshing = false;
  final Set<int> _repositoriesWithNewVersions = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Permission.notification.request();

    getAllSavedRepositories();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getAllSavedRepositories();
    }
  }

  Future<void> getAllSavedRepositories() async {
    _repositoriesList = await RepositoryService().queryAllAndConvertToList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    List<String> savedIds = prefs.getStringList('updated_repo_ids') ?? [];

    if (mounted) {
      setState(() {
        _repositoriesWithNewVersions.addAll(savedIds.map((e) => int.parse(e)));
        _loading = false;
      });
    }
  }

  Future<void> refreshAllRepositories() async {
    // Evita múltiplas chamadas simultâneas
    if (_refreshing) return;

    setState(() {
      _refreshing = true;
    });

    Fluttertoast.showToast(msg: "Refreshing...");

    final result = await BackgroundService.runRefreshTask();

    if (mounted) {
      setState(() {
        _refreshing = false;
        _repositoriesWithNewVersions.addAll(result.updatedIds);
      });

      if (result.hitRateLimit) {
        Fluttertoast.showToast(msg: "API Rate limit reached");
      }

      getAllSavedRepositories();
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _repositoriesWithNewVersions.clear();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('updated_repo_ids', []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppDetails.appNameHomePage),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
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
                    Icon(Icons.done_all_outlined),
                    SizedBox(width: 12),
                    Text('Mark all as seen'),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 2,
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
                  _markAllAsRead();
                case 2:
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
                        onNewVersionDetected: () async {
                          setState(() {
                            _repositoriesWithNewVersions.add(repo.id!);
                          });

                          final prefs = await SharedPreferences.getInstance();
                          await prefs.reload();
                          List<String> savedIds = prefs.getStringList('updated_repo_ids') ?? [];
                          if (!savedIds.contains(repo.id!.toString())) {
                            savedIds.add(repo.id!.toString());
                            await prefs.setStringList('updated_repo_ids', savedIds);
                          }
                        },
                        onVersionViewed: () async {
                          setState(() {
                            _repositoriesWithNewVersions.remove(repo.id!);
                          });

                          final prefs = await SharedPreferences.getInstance();
                          await prefs.reload();
                          List<String> savedIds = prefs.getStringList('updated_repo_ids') ?? [];

                          if (savedIds.contains(repo.id!.toString())) {
                            savedIds.remove(repo.id!.toString());
                            await prefs.setStringList('updated_repo_ids', savedIds);
                          }
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
