import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../db/repository_dao.dart';
import '../classes/release.dart';
import '../classes/repository.dart';
import 'package:http/http.dart' as http;

class NewRepository extends StatefulWidget {
  Function refreshList;

  @override
  _NewRepositoryState createState() => _NewRepositoryState();

  NewRepository({Key? key, required this.refreshList}) : super(key: key);
}

class _NewRepositoryState extends State<NewRepository> {
  late Repository _repo;
  late Release _release;
  final _repositories = RepositoryDao.instance;
  TextEditingController controllerRepoLink = TextEditingController();
  TextEditingController controllerRepoNote = TextEditingController();
  bool _validLink = true;

  Future<void> getRepositoryDataAndSave() async {
    List<String> formattedRepositoryData = controllerRepoLink.text.split('/');

    //REPO
    final responseRepo = await http.get(Uri.parse("https://api.github.com/repos/${formattedRepositoryData[3]}/${formattedRepositoryData[4]}"));

    //RELEASE
    final responseRelease = await http
        .get(Uri.parse("https://api.github.com/repos/${formattedRepositoryData[3]}/${formattedRepositoryData[4]}/releases/latest"));

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

  Future<void> _saveRepository() async {
    Map<String, dynamic> row = {
      RepositoryDao.columnName: _repo.name,
      RepositoryDao.columnLink: controllerRepoLink.text,
      RepositoryDao.columnNote: controllerRepoNote.text,
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

  bool validateTextFields() {
    String errors = "";
    if (controllerRepoLink.text.isEmpty) {
      errors += "Link";
      _validLink = false;
    }
    return errors.isEmpty ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Repository'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              autofocus: true,
              minLines: 1,
              maxLines: 3,
              maxLength: 500,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.name,
              controller: controllerRepoLink,
              decoration: InputDecoration(
                  labelText: "Link",
                  helperText: "* Required",
                  counterText: "",
                  border: const OutlineInputBorder(),
                  errorText: (_validLink) ? null : "Link is empty"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              minLines: 1,
              maxLines: 3,
              maxLength: 500,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.name,
              controller: controllerRepoNote,
              decoration: const InputDecoration(
                labelText: "Note",
                counterText: "",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: FilledButton.tonalIcon(
                onPressed: () async {
                  if (validateTextFields()) {
                    getRepositoryDataAndSave().then((v) => Navigator.of(context).pop());
                  } else {
                    setState(() {
                      _validLink;
                    });
                  }
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text(
                  'Save',
                  ),
                )),
        ],
      ),
    );
  }
}
