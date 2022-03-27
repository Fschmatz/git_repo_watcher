import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:git_repo_watcher/classes/repository.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
import 'package:url_launcher/url_launcher.dart';
import '../classes/release.dart';
import '../db/repository_dao.dart';
import '../util/utils_functions.dart';

class RepositoryTile extends StatefulWidget {
  Repository repository;
  Function refreshList;

  RepositoryTile(
      {Key? key, required this.repository,
        required this.refreshList})
      : super(key: key);

  @override
  _RepositoryTileState createState() => _RepositoryTileState();
}

class _RepositoryTileState extends State<RepositoryTile> {
  late Repository _repo;
  String repoApi = 'https://api.github.com/repos/';
  bool loadingData = false;
  List<String> formattedRepositoryData = [];
  bool newVersion = false;
  String savedLink = '';
  String oldDate = '';
  final TextStyle _styleLatestText = const TextStyle(fontSize: 14);

  @override
  void initState() {
    formattedRepositoryData = widget.repository.link!.split('/');
    _repo = widget.repository;
    oldDate = widget.repository.releasePublishedDate!;
    super.initState();
  }

  Future<void> getRepositoryData() async {
    setState(() {
      loadingData = true;
    });

    //REPO
    final responseRepo = await http.get(Uri.parse(
        "https://api.github.com/repos/" +
            formattedRepositoryData[3] +
            "/" +
            formattedRepositoryData[4]));

    //RELEASE
    final responseRelease = await http.get(Uri.parse(
        "https://api.github.com/repos/" +
            formattedRepositoryData[3] +
            "/" +
            formattedRepositoryData[4] +
            "/releases/latest"));

    if (responseRepo.statusCode == 200) {
      _repo = Repository.fromJSON(jsonDecode(responseRepo.body));
      Release _release = Release.fromJSON(jsonDecode(responseRelease.body));
      _repo.releaseLink = _release.link;
      _repo.releaseVersion = _release.version;
      _repo.releasePublishedDate = _release.publishedDate;
      _repo.id = widget.repository.id;

      _update();

      if (mounted) {
        setState(() {
          loadingData = false;
          _repo;
        });
        showNewReleaseIcon();
      }
    } else if (responseRepo.statusCode == 403) {
      Fluttertoast.showToast(
        msg: "API Limit",
      );
    } else if (responseRepo.statusCode == 404) {
      _repo.name = "Link Error";
      setState(() {
        loadingData = false;
        _repo;
      });
      Fluttertoast.showToast(
        msg: "Error Loading",
      );
    } else {
      Fluttertoast.showToast(
        msg: "Error Loading",
      );
    }
  }

  void _update() async {
    final repositories = RepositoryDao.instance;
    Map<String, dynamic> row = {
      RepositoryDao.columnId: _repo.id,
      RepositoryDao.columnName: _repo.name,
      RepositoryDao.columnLink: _repo.link,
      RepositoryDao.columnIdGit: _repo.idGit,
      RepositoryDao.columnOwner: _repo.owner,
      RepositoryDao.columnDefaultBranch: _repo.defaultBranch,
      RepositoryDao.columnLastUpdate: _repo.lastUpdate,
      RepositoryDao.columnReleaseLink: _repo.releaseLink,
      RepositoryDao.columnReleaseVersion: _repo.releaseVersion,
      RepositoryDao.columnReleasePublishedDate: _repo.releasePublishedDate,
    };
    final update = await repositories.update(row);
  }

  Future<void> _delete() async {
    final repositories = RepositoryDao.instance;
    final deleted = await repositories.delete(_repo.id!);
  }

  void showNewReleaseIcon() {
    if (oldDate != _repo.releasePublishedDate) {
      setState(() {
        newVersion = !newVersion;
      });
    }
  }

  _launchPage(String url) {
    launch(url);
  }

  void openBottomMenu() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
        ),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.open_in_new_outlined),
                    title: const Text(
                      "View repository",
                      style: TextStyle(fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _launchPage(widget.repository.link!);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.open_in_new_outlined),
                    title: const Text(
                      "View default branch commits",
                      style: TextStyle(fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _launchPage(widget.repository.link! +
                          "/commits/" +
                          widget.repository.defaultBranch!);
                    },
                  ),
                  const Divider(),
                  Visibility(
                    visible: _repo.releasePublishedDate! != 'null',
                    child: ListTile(
                      leading: const Icon(Icons.open_in_new_outlined),
                      title: const Text(
                        "View latest release",
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _launchPage(widget.repository.releaseLink!);
                      },
                    ),
                  ),
                  Visibility(
                      visible: _repo.releasePublishedDate! != 'null',
                      child: const Divider()),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_outlined),
                    title: const Text(
                      "Delete",
                      style: TextStyle(fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      showAlertDialogOkDelete(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  showAlertDialogOkDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Confirm",
          ),
          content: const Text(
            "Delete ?",
          ),
          actions: [
            TextButton(
              child: const Text(
                "Yes",
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _delete();
                widget.refreshList();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness _tagTextBrightness = Theme.of(context).brightness;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        onTap: openBottomMenu,
        onLongPress: getRepositoryData,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ListTile(
                    title: Text(
                      _repo.name!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w400),
                    ),
                    subtitle: Text(_repo.owner!),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        newVersion
                            ? const Icon(
                                Icons.new_releases_outlined,
                                color: Colors.green,
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(
                          width: 10,
                        ),
                        loadingData
                            ? const Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                ),
                              )
                            : Visibility(
                                visible: _repo.releasePublishedDate != 'null',
                                child: Chip(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  label: Text(_repo.releaseVersion!),
                                  labelStyle: TextStyle(
                                      fontSize: 12,
                                      color:
                                          _tagTextBrightness == Brightness.dark
                                              ? lightenColor(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onSecondary,
                                                  40)
                                              : darkenColor(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onSecondary,
                                                  50),
                                      fontWeight: FontWeight.w600),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .onSecondary
                                      .withOpacity(0.4),
                                ),
                              ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            _repo.releasePublishedDate != 'null'
                ? Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ListTile(
                          subtitle: Text(
                            Jiffy(_repo.lastUpdate!).format("dd/MM/yyyy"),
                            style: _styleLatestText,
                          ),
                          title: Text(
                            "Latest update",
                            style: _styleLatestText,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: ListTile(
                          subtitle: _repo.releasePublishedDate == 'null'
                              ? Text(
                                  'No releases',
                                  style: _styleLatestText,
                                  textAlign: TextAlign.end,
                                )
                              : Text(
                                  Jiffy(_repo.releasePublishedDate!)
                                      .format("dd/MM/yyyy"),
                                  style: _styleLatestText,
                                  textAlign: TextAlign.end,
                                ),
                          title: Text(
                            "Latest release ",
                            style: _styleLatestText,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListTile(
                    title: Text(
                      "Latest update",
                      style: _styleLatestText,
                    ),
                    trailing: Text(
                      Jiffy(_repo.lastUpdate!).format("dd/MM/yyyy"),
                      style: _styleLatestText,
                      textAlign: TextAlign.end,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
