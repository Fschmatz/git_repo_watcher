import 'package:flutter/material.dart';
import 'package:git_repo_watcher/classes/repository.dart';
import 'package:git_repo_watcher/pages/new_repository.dart';
import 'package:git_repo_watcher/pages/settings.dart';
import 'package:git_repo_watcher/service/background_service.dart';
import 'package:git_repo_watcher/service/repository_service.dart';
import 'package:git_repo_watcher/util/app_constants.dart';
import 'package:git_repo_watcher/util/shared_pref_util.dart';
import 'package:git_repo_watcher/widgets/repository_tile.dart';
import 'package:permission_handler/permission_handler.dart';

import '../util/toast_utils.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  List<Repository> _repositoriesList = [];
  bool _loading = true;
  bool _refreshing = false;
  final Set<int> _repositoriesWithNewVersions = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _tabController = TabController(length: 2, vsync: this);

    _tabController.animation!.addListener(() {
      int value = _tabController.animation!.value.round();
      if (value != _currentTabIndex) {
        setState(() {
          _currentTabIndex = value;
        });
      }
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging && _tabController.index != _currentTabIndex) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });

    Permission.notification.request();

    getAllSavedRepositories();
  }

  @override
  void dispose() {
    _tabController.dispose();
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

    await SharedPrefUtil.reload();
    List<String> savedIds = await SharedPrefUtil.loadData<List<String>>(AppConstants.sharedPrefsUpdatedRepoIdsKey) ?? [];

    // Filter out IDs that no longer exist
    List<int> currentRepoIds = _repositoriesList.map((e) => e.id!).toList();
    List<String> validSavedIds = savedIds.where((id) => currentRepoIds.contains(int.parse(id))).toList();

    if (savedIds.length != validSavedIds.length) {
      await SharedPrefUtil.saveData(AppConstants.sharedPrefsUpdatedRepoIdsKey, validSavedIds);
    }

    if (mounted) {
      setState(() {
        _repositoriesWithNewVersions.clear();
        _repositoriesWithNewVersions.addAll(validSavedIds.map((e) => int.parse(e)));
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

    ToastUtils.show("Refreshing...");

    final result = await BackgroundService.runRefreshTask();

    if (mounted) {
      setState(() {
        _refreshing = false;
        _repositoriesWithNewVersions.addAll(result.updatedIds);
      });

      if (result.hitRateLimit) {
        ToastUtils.showErrorMessage("API Rate limit reached");
      }

      getAllSavedRepositories();
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _repositoriesWithNewVersions.clear();
    });
    await SharedPrefUtil.saveData(AppConstants.sharedPrefsUpdatedRepoIdsKey, <String>[]);
  }

  @override
  Widget build(BuildContext context) {
    final colorscheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appNameHomePage),
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
                    Text('Add repository'),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: const [
                    Icon(Icons.done_all_outlined),
                    SizedBox(width: 12),
                    Text('Clear updates'),
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
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _currentTabIndex == 0,
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          side: BorderSide.none,
                          selectedColor: colorscheme.primaryContainer,
                          backgroundColor: colorscheme.surfaceContainerHigh,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _currentTabIndex == 0 ? colorscheme.onPrimaryContainer : colorscheme.onSurfaceVariant,
                          ),
                          onSelected: (bool selected) {
                            _tabController.animateTo(0);
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text('Updates (${_repositoriesWithNewVersions.length})'),
                          selected: _currentTabIndex == 1,
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          side: BorderSide.none,
                          selectedColor: colorscheme.primaryContainer,
                          backgroundColor: colorscheme.surfaceContainerHigh,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _currentTabIndex == 1 ? colorscheme.onPrimaryContainer : colorscheme.onSurfaceVariant,
                          ),
                          onSelected: (bool selected) {
                            _tabController.animateTo(1);
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(_repositoriesList, "No repositories added."),
                        _buildList(
                          _repositoriesList.where((repo) => _repositoriesWithNewVersions.contains(repo.id)).toList(),
                          "No updates available.",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildList(List<Repository> list, String emptyMessage) {
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            emptyMessage,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 75),
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        Repository repo = list[index];

        return RepositoryTile(
          key: ValueKey(repo.id),
          refreshList: getAllSavedRepositories,
          repository: repo,
          hasNewVersion: _repositoriesWithNewVersions.contains(repo.id),
          onNewVersionDetected: () async {
            setState(() {
              _repositoriesWithNewVersions.add(repo.id!);
            });

            await SharedPrefUtil.reload();
            List<String> savedIds = await SharedPrefUtil.loadData<List<String>>(AppConstants.sharedPrefsUpdatedRepoIdsKey) ?? [];
            if (!savedIds.contains(repo.id!.toString())) {
              savedIds.add(repo.id!.toString());
              await SharedPrefUtil.saveData(AppConstants.sharedPrefsUpdatedRepoIdsKey, savedIds);
            }
          },
          onVersionViewed: () async {
            setState(() {
              _repositoriesWithNewVersions.remove(repo.id!);
            });

            await SharedPrefUtil.reload();
            List<String> savedIds = await SharedPrefUtil.loadData<List<String>>(AppConstants.sharedPrefsUpdatedRepoIdsKey) ?? [];

            if (savedIds.contains(repo.id!.toString())) {
              savedIds.remove(repo.id!.toString());
              await SharedPrefUtil.saveData(AppConstants.sharedPrefsUpdatedRepoIdsKey, savedIds);
            }
          },
        );
      },
    );
  }
}
