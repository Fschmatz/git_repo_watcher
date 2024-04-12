import 'package:git_repo_watcher/classes/repository.dart';
import '../db/repository_dao.dart';

class RepositoryService{

  final dbRepository = RepositoryDao.instance;

  Future<List<Repository>> queryAllAndConvertToList() async {
    var resp = await dbRepository.queryAllRowsByName();

    return resp.isNotEmpty ? resp.map((map) =>  Repository.fromMap(map)).toList() : [];
  }

}