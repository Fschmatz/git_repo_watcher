import 'dart:convert';

import 'package:git_repo_watcher/classes/release.dart';
import 'package:git_repo_watcher/classes/repository.dart';
import 'package:git_repo_watcher/service/github_service.dart';
import 'package:git_repo_watcher/service/notification_service.dart';
import 'package:git_repo_watcher/service/repository_service.dart';

class BackgroundService {
  static const String taskName = 'manual_refresh_task';

  static Future<({List<int> updatedIds, bool hitRateLimit})> runRefreshTask() async {
    await NotificationService().init();
    final List<Repository> repositoriesList = await RepositoryService().queryAllAndConvertToList();

    if (repositoriesList.isEmpty) return (updatedIds: <int>[], hitRateLimit: false);

    List<int> updatedIds = [];
    bool hitRateLimit = false;

    await NotificationService().showProgressNotification(1, 'Refreshing repositories', 'Starting refresh...', 0, repositoriesList.length);

    for (int i = 0; i < repositoriesList.length; i++) {
      if (hitRateLimit) break;

      Repository repo = repositoriesList[i];
      List<String> formattedData = repo.link!.split('/');

      try {
        final responseRepo = await GitHubService().getRepositoryData(formattedData);
        if (responseRepo.statusCode == 403) {
          hitRateLimit = true;
          break;
        }
        if (responseRepo.statusCode != 200) continue;

        final responseLatestRelease = await GitHubService().getRepositoryLatestReleaseData(formattedData);
        if (responseLatestRelease.statusCode == 403) {
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
            updatedIds.add(repo.id!);
          }
          await RepositoryService().update(updatedRepo);
        }
      } catch (e) {
        // Continue to the next repository if a network or parsing error occurs
        continue;
      }

      await NotificationService()
          .showProgressNotification(1, 'Refreshing repositories', 'Checked ${i + 1} of ${repositoriesList.length}', i + 1, repositoriesList.length);
      await Future.delayed(const Duration(milliseconds: 100));
    }

    await NotificationService().flutterLocalNotificationsPlugin.cancel(id: 1);

    if (updatedIds.isNotEmpty) {
      await NotificationService().showCompletedNotification(2, 'Refresh Complete', '${updatedIds.length} new releases');
    } else {
      await NotificationService().showCompletedNotification(2, 'Refresh Complete', 'No releases');
    }

    return (updatedIds: updatedIds, hitRateLimit: hitRateLimit);
  }
}
