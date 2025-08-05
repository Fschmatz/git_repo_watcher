import 'package:git_repo_watcher/classes/repository.dart';

import '../db/repository_dao.dart';

class RepositoryService {
  final RepositoryDao repositoryDao = RepositoryDao.instance;

  Future<List<Repository>> queryAllAndConvertToList() async {
    var resp = await repositoryDao.queryAllRowsByName();

    return resp.isNotEmpty ? resp.map((map) => Repository.fromMap(map)).toList() : [];
  }

  Future<void> update(Repository repository) async {
    Map<String, dynamic> row = {};

    row[RepositoryDao.columnId] = repository.id;

    if (repository.name != null && repository.name!.isNotEmpty) {
      row[RepositoryDao.columnName] = repository.name;
    }

    if (repository.link != null && repository.link!.isNotEmpty) {
      row[RepositoryDao.columnLink] = repository.link;
    }

    if (repository.note != null && repository.note!.isNotEmpty) {
      row[RepositoryDao.columnNote] = repository.note;
    }

    if (repository.idGit != null) {
      row[RepositoryDao.columnIdGit] = repository.idGit;
    }

    if (repository.owner != null && repository.owner!.isNotEmpty) {
      row[RepositoryDao.columnOwner] = repository.owner;
    }

    if (repository.defaultBranch != null && repository.defaultBranch!.isNotEmpty) {
      row[RepositoryDao.columnDefaultBranch] = repository.defaultBranch;
    }

    if (repository.lastUpdate != null && repository.lastUpdate!.isNotEmpty) {
      row[RepositoryDao.columnLastUpdate] = repository.lastUpdate;
    }

    if (repository.releaseLink != null && repository.releaseLink!.isNotEmpty) {
      row[RepositoryDao.columnReleaseLink] = repository.releaseLink;
    }

    if (repository.releaseVersion != null && repository.releaseVersion!.isNotEmpty) {
      row[RepositoryDao.columnReleaseVersion] = repository.releaseVersion;
    }

    if (repository.releasePublishedDate != null && repository.releasePublishedDate!.isNotEmpty) {
      row[RepositoryDao.columnReleasePublishedDate] = repository.releasePublishedDate;
    }

    await repositoryDao.update(row);
  }

  Future<void> delete(Repository repository) async {
    await repositoryDao.delete(repository.id!);
  }

  Future<void> deleteAll() async {
    await repositoryDao.deleteAll();
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    return await repositoryDao.queryAllRowsByName();
  }

  Future<void> insertFromRestoreBackup(List<dynamic> jsonData) async {
    List<Map<String, dynamic>> listToInsert = jsonData.map((item) {
      return Repository.fromMap(item).toMap();
    }).toList();

    await repositoryDao.insertBatchForBackup(listToInsert);
  }
}
