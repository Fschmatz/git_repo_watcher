import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../db/repository_dao.dart';
import '../classes/release.dart';
import '../classes/repository.dart';
import '../widgets/dialog_alert_error.dart';
import 'package:http/http.dart' as http;

class NewRepository extends StatefulWidget {
  Function refreshList;

  @override
  _NewRepositoryState createState() => _NewRepositoryState();

  NewRepository({Key? key,required this.refreshList}) : super(key: key);
}

class _NewRepositoryState extends State<NewRepository> {
  late Repository _repo;
  late Release _release;
  final _repositories = RepositoryDao.instance;
  TextEditingController customControllerRepoLink = TextEditingController();


  Future<void> getRepositoryDataAndSave() async {
    List<String> formattedRepositoryData =
        customControllerRepoLink.text.split('/');

    //REPO
    final responseRepo = await http.get(Uri.parse("https://api.github.com/repos/" +
        formattedRepositoryData[3] +
        "/" +
        formattedRepositoryData[4]));

    //RELEASE
    final responseRelease = await http.get(Uri.parse("https://api.github.com/repos/" +
        formattedRepositoryData[3] +
        "/" +
        formattedRepositoryData[4]+"/releases/latest"));


    if (responseRepo.statusCode == 200) {

      _repo = Repository.fromJSON(jsonDecode(responseRepo.body));
      _release = Release.fromJSON(jsonDecode(responseRelease.body));
      _repo.releaseLink = _release.link;
      _repo.releaseVersion = _release.version;
      _repo.releasePublishedDate = _release.publishedDate;

      _saveRepository();
      widget.refreshList();
    } else {
      Fluttertoast.showToast(
        msg: "Error Saving Repository Data",
      );
    }
  }

  void _saveRepository() async {
    Map<String, dynamic> row = {
      RepositoryDao.columnName: _repo.name,
      RepositoryDao.columnLink: customControllerRepoLink.text,
      RepositoryDao.columnIdGit: _repo.idGit,
      RepositoryDao.columnOwner: _repo.owner,
      RepositoryDao.columnDefaultBranch: _repo.defaultBranch,
      RepositoryDao.columnLastUpdate: _repo.lastUpdate,
      RepositoryDao.columnReleaseLink: _repo.releaseLink,
      RepositoryDao.columnReleaseVersion: _repo.releaseVersion,
      RepositoryDao.columnReleasePublishedDate: _repo.releasePublishedDate,
    };
    final id = await _repositories.insert(row);
  }

  String checkForErrors() {
    String errors = "";
    if (customControllerRepoLink.text.isEmpty) {
      errors += "Link is empty\n";
    }
    return errors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
            child: IconButton(
              tooltip: 'Save',
              icon: const Icon(
                Icons.save_outlined,
              ),
              onPressed: () async {
                String errors = checkForErrors();
                if (errors.isEmpty) {
                  getRepositoryDataAndSave();
                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return dialogAlertErrors(errors, context);
                    },
                  );
                }
              },
            ),
          )
        ],
        title: const Text('New Repository'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const SizedBox(
              height: 0.1,
            ),
            title: Text("Repository Link".toUpperCase(),
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.secondary)),
          ),
          ListTile(
            leading: const Icon(
              Icons.notes_outlined,
            ),
            title: TextField(
              autofocus: true,
              minLines: 1,
              maxLength: 150,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              controller: customControllerRepoLink,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: "",
                helperText: "* Required",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
