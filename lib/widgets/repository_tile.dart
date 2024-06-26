import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:git_repo_watcher/classes/repository.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
import 'package:url_launcher/url_launcher.dart';
import '../classes/release.dart';
import '../db/repository_dao.dart';

class RepositoryTile extends StatefulWidget {
  Repository repository;
  Function refreshList;
  bool refreshAllRepositories;

  RepositoryTile({Key? key, required this.repository, required this.refreshList, required this.refreshAllRepositories}) : super(key: key);

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

    if (widget.refreshAllRepositories) {
      getRepositoryData();
    }

    super.initState();
  }

  Future<void> getRepositoryData() async {
    setState(() {
      loadingData = true;
    });

    //REPO
    final responseRepo = await http.get(Uri.parse("https://api.github.com/repos/${formattedRepositoryData[3]}/${formattedRepositoryData[4]}"));

    //RELEASE
    final responseRelease =
        await http.get(Uri.parse("https://api.github.com/repos/${formattedRepositoryData[3]}/${formattedRepositoryData[4]}/releases/latest"));

    if (responseRepo.statusCode == 200) {
      _repo = Repository.fromJSON(jsonDecode(responseRepo.body));
      Release release = Release.fromJSON(jsonDecode(responseRelease.body));
      _repo.releaseLink = release.link;
      _repo.releaseVersion = release.version;
      _repo.releasePublishedDate = release.publishedDate;
      _repo.id = widget.repository.id;
      _repo.note = widget.repository.note;

      await _update();
      widget.repository.releaseLink = _repo.releaseLink;

      setState(() {
        loadingData = false;
        _repo;
      });
      showNewReleaseIcon();
    } else if (responseRepo.statusCode == 403) {
      setState(() {
        loadingData = false;
        _repo;
      });
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
    Map<String, dynamic> row = {};

    row[RepositoryDao.columnId] = _repo.id;
    if (_repo.name != null && _repo.name!.isNotEmpty) {
      row[RepositoryDao.columnName] = _repo.name;
    }
    if (_repo.link != null && _repo.link!.isNotEmpty) {
      row[RepositoryDao.columnLink] = _repo.link;
    }
    if (_repo.note != null && _repo.note!.isNotEmpty) {
      row[RepositoryDao.columnNote] = _repo.note;
    }
    if (_repo.idGit != null) {
      row[RepositoryDao.columnIdGit] = _repo.idGit;
    }
    if (_repo.owner != null && _repo.owner!.isNotEmpty) {
      row[RepositoryDao.columnOwner] = _repo.owner;
    }
    if (_repo.defaultBranch != null && _repo.defaultBranch!.isNotEmpty) {
      row[RepositoryDao.columnDefaultBranch] = _repo.defaultBranch;
    }
    if (_repo.lastUpdate != null && _repo.lastUpdate!.isNotEmpty) {
      row[RepositoryDao.columnLastUpdate] = _repo.lastUpdate;
    }
    if (_repo.releaseLink != null && _repo.releaseLink!.isNotEmpty) {
      row[RepositoryDao.columnReleaseLink] = _repo.releaseLink;
    }
    if (_repo.releaseVersion != null && _repo.releaseVersion!.isNotEmpty) {
      row[RepositoryDao.columnReleaseVersion] = _repo.releaseVersion;
    }
    if (_repo.releasePublishedDate != null && _repo.releasePublishedDate!.isNotEmpty) {
      row[RepositoryDao.columnReleasePublishedDate] = _repo.releasePublishedDate;
    }

    await repositories.update(row);
  }

  Future<void> _delete() async {
    final repositories = RepositoryDao.instance;
    await repositories.delete(_repo.id!);
  }

  void showNewReleaseIcon() {
    if (oldDate.isNotEmpty && _repo.releasePublishedDate != null && _repo.releasePublishedDate!.isNotEmpty) {
      if (oldDate != _repo.releasePublishedDate) {
        setState(() {
          newVersion = !newVersion;
        });
      }
    }
  }

  _launchPage(String url) {
    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  String getFormattedDate(String date) {
    return Jiffy.parse(date).format(pattern: 'dd/MM/yyyy');
  }

  void openBottomMenu() {
    TextStyle infoStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

    showModalBottomSheet(
        isScrollControlled: true,
        showDragHandle: true,
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  title: Text(_repo.name!, textAlign: TextAlign.center, style: infoStyle),
                ),
                (_repo.note!.isEmpty)
                    ? const SizedBox.shrink()
                    : ListTile(
                        leading: Text(_repo.note!, style: infoStyle),
                      ),
                (_repo.lastUpdate == 'null')
                    ? const SizedBox.shrink()
                    : ListTile(
                        leading: Text("Latest update", style: infoStyle),
                        trailing: Text(getFormattedDate(_repo.lastUpdate!), style: infoStyle),
                      ),
                (_repo.releasePublishedDate == 'null')
                    ? const SizedBox.shrink()
                    : ListTile(
                        leading: Text("Latest release", style: infoStyle),
                        trailing: Text(getFormattedDate(_repo.releasePublishedDate!), style: infoStyle),
                      ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.open_in_new_outlined),
                  title: Text("View repository", style: infoStyle),
                  onTap: () {
                    Navigator.of(context).pop();
                    _launchPage(widget.repository.link!);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.open_in_new_outlined),
                  title: const Text(
                    "View default branch commits",
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _launchPage("${widget.repository.link!}/commits/${widget.repository.defaultBranch!}");
                  },
                ),
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
    final colorscheme = Theme.of(context).colorScheme;

    String versionFormatted = _repo.releaseVersion!;
    if (_repo.releaseVersion!.length > 14) {
      versionFormatted = "${_repo.releaseVersion!.substring(0, 11)}...";
    }

    return InkWell(
      onTap: openBottomMenu,
      onLongPress: getRepositoryData,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
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
                    subtitle: Text(_repo.owner!, style: TextStyle(fontSize: 12, color: colorscheme.primary)),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        newVersion
                            ? Icon(
                                Icons.new_releases_outlined,
                                color: colorscheme.tertiary,
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
                                  label: Text(versionFormatted),
                                  side: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                  labelStyle: TextStyle(fontSize: 12, color: colorscheme.secondary, fontWeight: FontWeight.w500),
                                  backgroundColor: colorscheme.secondaryContainer,
                                ),
                              ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
