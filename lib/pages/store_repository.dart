import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../db/repository_dao.dart';
import '../classes/release.dart';
import '../classes/repository.dart';
import '../service/github_service.dart';
import '../service/repository_service.dart';
import '../util/toast_utils.dart';

class StoreRepository extends StatefulWidget {
  final Function refreshList;
  final Repository? repositoryToEdit;

  const StoreRepository({super.key, required this.refreshList, this.repositoryToEdit});

  @override
  State<StoreRepository> createState() => _StoreRepositoryState();
}

class _StoreRepositoryState extends State<StoreRepository> {
  late Repository _repo;
  Release? _release;
  final _repositories = RepositoryDao.instance;
  TextEditingController controllerRepoLink = TextEditingController();
  TextEditingController controllerRepoNote = TextEditingController();
  bool _validLink = true;
  bool _isUpdate = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.repositoryToEdit != null) {
      _repo = widget.repositoryToEdit!;
      controllerRepoLink.text = _repo.link ?? '';
      controllerRepoNote.text = _repo.note ?? '';
      _isUpdate = true;
    }
  }

  Future<void> getRepositoryDataAndSave() async {
    if (_isUpdate) {
      _repo.note = controllerRepoNote.text;

      await RepositoryService().update(_repo);

      widget.refreshList();
      ToastUtils.showSuccess();

      return;
    }

    List<String> formattedRepositoryData = controllerRepoLink.text.split('/');
    final responseRepo = await GitHubService().getRepositoryData(formattedRepositoryData);
    final responseRelease = await GitHubService().getRepositoryLatestReleaseData(formattedRepositoryData);

    if (responseRepo.statusCode == 200) {
      _repo = Repository.fromJSON(jsonDecode(responseRepo.body));
      _release = Release.fromJSON(jsonDecode(responseRelease.body));
      _repo.releaseLink = _release!.link;
      _repo.releaseVersion = _release!.version;
      _repo.releasePublishedDate = _release!.publishedDate;
      _repo.releaseBody = _release!.body;

      await _saveRepository();
      widget.refreshList();
      ToastUtils.showSuccess();
    } else {
      ToastUtils.showErrorMessage("Error Saving Repository Data");
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
      RepositoryDao.columnReleaseBody: _repo.releaseBody,
    };

    await _repositories.insert(row);
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
      appBar: AppBar(title: Text(_isUpdate ? 'Edit' : 'New')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              enabled: !_isUpdate,
              minLines: 1,
              maxLines: 3,
              maxLength: 500,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.name,
              controller: controllerRepoLink,
              readOnly: _isUpdate,
              decoration: InputDecoration(
                labelText: "Link",
                helperText: "* Required",
                counterText: "",
                errorText: (_validLink) ? null : "Link is empty",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              minLines: 1,
              maxLines: 3,
              maxLength: 250,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.name,
              controller: controllerRepoNote,
              decoration: InputDecoration(
                labelText: "Note",
                counterText: "",
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving
            ? null
            : () async {
                if (validateTextFields()) {
                  setState(() => _isSaving = true);
                  await getRepositoryDataAndSave();
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                } else {
                  setState(() {
                    _validLink;
                  });
                }
              },
        icon: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: Text(_isSaving ? 'Saving...' : 'Save'),
      ),
    );
  }
}
