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
    super.initState();
    formattedRepositoryData = widget.repository.link!.split('/');
    _repo = widget.repository;
    oldDate = widget.repository.releasePublishedDate!;
  }

  Future<void> getRepositoryData() async {
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

      print(_repo.toString());
      checkUpdate();
      _update();

      if (mounted) {
        setState(() {
          loadingData = false;
          _repo;
        });
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

  void checkUpdate() {
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
                      _launchPage(widget.repository.link!);
                    },
                  ),
                  const Divider(),
                  Visibility(
                    visible: _repo.releasePublishedDate!.isNotEmpty,
                    child: ListTile(
                      leading: const Icon(Icons.open_in_new_outlined),
                      title: const Text(
                        "View latest release",
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        _launchPage(widget.repository.releaseLink!);
                      },
                    ),
                  ),
                  Visibility(
                      visible: _repo.releasePublishedDate!.isNotEmpty,
                      child: const Divider()),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_outlined),
                    title: const Text(
                      "Delete",
                      style: TextStyle(fontSize: 16),
                    ),
                    onTap: () {
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
    Widget okButton = TextButton(
      child: Text(
        "Yes",
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        _delete();
        widget.refreshList();
      },
    );

    AlertDialog alert = AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      title: const Text(
        "Confirm", //
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
      content: const Text(
        "\nDelete ?",
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          onTap: openBottomMenu,
          onLongPress: getRepositoryData,
          child: Column(
            children: [
              ListTile(
                title: Text(
                  _repo.name!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700),
                ),
                subtitle: Text(_repo.owner!),
                trailing: Visibility(
                    visible: newVersion,
                    child: Icon(
                      Icons.new_releases_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    )),
              ),
              ListTile(
                  title: const Text("Latest update"),
                  trailing:
                      Text(Jiffy(_repo.lastUpdate!).format("dd/MM/yyyy"))),
              Visibility(
                visible: _repo.releasePublishedDate != 'null',
                child: ListTile(
                  title: const Text("Latest release "),
                  subtitle: Text(_repo.releaseVersion!),
                  trailing: _repo.releasePublishedDate == 'null'
                      ? const Text('No releases')
                      : Text(Jiffy(_repo.releasePublishedDate!)
                          .format("dd/MM/yyyy")),
                  //trailing: Text(repo.lastUpdate!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
