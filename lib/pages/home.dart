import 'package:flutter/material.dart';
import 'package:git_repo_watcher/classes/repository.dart';
import 'package:git_repo_watcher/db/repository_dao.dart';
import 'package:git_repo_watcher/pages/new_repository.dart';
import 'package:git_repo_watcher/pages/settings/settings_page.dart';
import 'package:git_repo_watcher/widgets/repository_tile.dart';

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
    var resp = await repositories.queryAllRowsByName();
    setState(() {
      loading = false;
      repositoriesList = resp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: const Text('Git Repo Watcher'),
              pinned: false,
              floating: true,
              snap: true,
              actions: [
                IconButton(
                    icon: const Icon(
                      Icons.add_outlined,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => NewRepository(
                              refreshList: getAllSavedRepositories,
                            ),
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
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const SettingsPage(),
                          ));
                    }),
              ],
            ),
          ];
        },
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: loading
              ? const Center(child: SizedBox.shrink())
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                      ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(height: 0,),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: repositoriesList.length,
                        itemBuilder: (context, index) {
                          return RepositoryTile(
                            key: UniqueKey(),
                            refreshList: getAllSavedRepositories,
                            repository: Repository(
                              id: repositoriesList[index]['id'],
                              name: repositoriesList[index]['name'],
                              note: repositoriesList[index]['note'],
                              link: repositoriesList[index]['link'],
                              idGit:
                                  int.parse(repositoriesList[index]['idGit']),
                              owner: repositoriesList[index]['owner'],
                              lastUpdate: repositoriesList[index]['lastUpdate'],
                              defaultBranch: repositoriesList[index]
                                  ['defaultBranch'],
                              releaseLink: repositoriesList[index]
                                  ['releaseLink'],
                              releaseVersion: repositoriesList[index]
                                  ['releaseVersion'],
                              releasePublishedDate: repositoriesList[index]
                                  ['releasePublishedDate'],
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 50,
                      )
                    ]),
        ),
      ),
    );
  }
}
