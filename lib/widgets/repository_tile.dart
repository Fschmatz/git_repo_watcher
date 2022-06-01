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
      {Key? key, required this.repository, required this.refreshList})
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
      Release release = Release.fromJSON(jsonDecode(responseRelease.body));
      _repo.releaseLink = release.link;
      _repo.releaseVersion = release.version;
      _repo.releasePublishedDate = release.publishedDate;
      _repo.id = widget.repository.id;
      _repo.note = widget.repository.note;

      await _update();

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

  Future<void> _update() async {
    final repositories = RepositoryDao.instance;
    Map<String, dynamic> row = {
      RepositoryDao.columnId: _repo.id,
      RepositoryDao.columnName: _repo.name,
      RepositoryDao.columnLink: _repo.link,
      RepositoryDao.columnNote: _repo.note,
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
    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  void openBottomMenu() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
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
    final Brightness tagTextBrightness = Theme.of(context).brightness;

    final TextStyle styleTrailingDataText = TextStyle(
      color: Theme.of(context).hintColor,
        fontSize: 12,
      fontWeight: FontWeight.w400
    );

    TextStyle styleTitleText = TextStyle(
        color: Theme.of(context).hintColor,
        fontSize: 14,
        fontWeight: FontWeight.w400
    );

    EdgeInsets paddingText = const EdgeInsets.symmetric(horizontal: 16,vertical: 2);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: InkWell(
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
                    ),
                    subtitle: Text(_repo.owner!,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary
                        )
                    ),
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
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  label: Text(_repo.releaseVersion!),
                                  labelStyle: TextStyle(
                                      fontSize: 12,
                                      color: tagTextBrightness == Brightness.dark
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
                                      fontWeight: FontWeight.w500),
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
            (_repo.note!.isEmpty)
                ? const SizedBox.shrink()
                : Padding(
                  padding: paddingText,
                  child: Row(
                    children: [
                      Text(
                          _repo.note!,
                          style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                    ],
                  ),
                ),
            _repo.releasePublishedDate != 'null'
                ? Column(
                    children: [
                      Padding(
                        padding: paddingText,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Latest update",
                              style: styleTitleText,
                            ),
                            Text(
                              Jiffy(_repo.lastUpdate!).format("dd/MM/yyyy"),
                              style: styleTrailingDataText,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: paddingText,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Latest release ",
                              style: styleTitleText,
                            ),
                            _repo.releasePublishedDate == 'null'
                                ? Text(
                                    'No releases',
                                    style: styleTrailingDataText,
                                  )
                                : Text(
                                    Jiffy(_repo.releasePublishedDate!)
                                        .format("dd/MM/yyyy"),
                                    style: styleTrailingDataText,
                                  ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Padding(
                  padding: paddingText,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Latest update",
                          style: styleTitleText,
                        ),
                        Text(
                          Jiffy(_repo.lastUpdate!).format("dd/MM/yyyy"),
                          style: styleTrailingDataText,
                        ),
                      ],
                    ),
                ),
          ],
        ),
      ),
    );
  }
}
