import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:git_repo_watcher/classes/repository.dart';
import 'package:git_repo_watcher/pages/new_repository.dart';
import 'package:git_repo_watcher/pages/settings/settings_page.dart';
import 'package:git_repo_watcher/service/github_service.dart';
import 'package:git_repo_watcher/service/repository_service.dart';
import 'package:git_repo_watcher/util/app_details.dart';
import 'package:git_repo_watcher/widgets/repository_tile.dart';

import '../classes/release.dart';

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

    getAllSavedRepositories();
  }

  Future<void> getAllSavedRepositories() async {
    _repositoriesList = await RepositoryService().queryAllAndConvertToList();

    setState(() {
      _loading = false;
    });
  }

  Future<void> refreshAllRepositories() async {
    if (_refreshing) return;

    setState(() {
      _refreshing = true;
    });

    bool hitRateLimit = false;

    for (int i = 0; i < _repositoriesList.length; i++) {
      if (hitRateLimit) break;

      Repository repo = _repositoriesList[i];
      List<String> formattedData = repo.link!.split('/');

      try {
        final responseRepo = await GitHubService().getRepositoryData(formattedData);

        if (responseRepo.statusCode == 403) {
          Fluttertoast.showToast(msg: "API Limit Reached");
          hitRateLimit = true;
          break;
        }

        if (responseRepo.statusCode != 200) {
          continue;
        }

        final responseLatestRelease = await GitHubService().getRepositoryLatestReleaseData(formattedData);

        if (responseLatestRelease.statusCode == 403) {
          Fluttertoast.showToast(msg: "API Limit Reached");
          hitRateLimit = true;
          break;
        }

        if (responseLatestRelease.statusCode == 200) {
          Repository updatedRepo = Repository.fromJSON(jsonDecode(responseRepo.body));
          Release release = Release.fromJSON(jsonDecode(responseLatestRelease.body));

          updatedRepo.releaseLink = release.link;
          updatedRepo.releaseVersion = release.version;
          updatedRepo.releasePublishedDate = release.publishedDate;
          updatedRepo.id = repo.id;
          updatedRepo.note = repo.note;

          if (repo.releasePublishedDate != null &&
              repo.releasePublishedDate!.isNotEmpty &&
              repo.releasePublishedDate != 'null' &&
              updatedRepo.releasePublishedDate != repo.releasePublishedDate) {
            _repositoriesWithNewVersions.add(repo.id!);
          }

          await RepositoryService().update(updatedRepo);

          _repositoriesList[i] = updatedRepo;
        }

        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        continue;
      }
    }

    await getAllSavedRepositories();

    setState(() {
      _refreshing = false;
    });

    if (!hitRateLimit) {
      Fluttertoast.showToast(msg: "Refresh Complete");
    }
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
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  )
                : const Icon(Icons.refresh_outlined),
            onPressed: _refreshing ? null : refreshAllRepositories,
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
                      builder: (BuildContext context) => SettingsPage(refreshList: getAllSavedRepositories),
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
                    separatorBuilder: (BuildContext context, int index) => const Divider(height: 0),
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
