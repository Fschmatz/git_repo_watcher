import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:git_repo_watcher/classes/repository.dart';
import 'package:jiffy/jiffy.dart';
import 'package:url_launcher/url_launcher.dart';

import '../classes/release.dart';
import '../service/github_service.dart';
import '../service/repository_service.dart';

class RepositoryTile extends StatefulWidget {
  final Repository repository;
  final Function refreshList;
  final bool hasNewVersion;

  const RepositoryTile({
    Key? key,
    required this.repository,
    required this.refreshList,
    this.hasNewVersion = false,
  }) : super(key: key);

  @override
  State<RepositoryTile> createState() => _RepositoryTileState();
}

class _RepositoryTileState extends State<RepositoryTile> {
  late Repository _repository;
  bool _loadingData = false;
  List<String> _formattedRepositoryData = [];

  @override
  void initState() {
    super.initState();
    _formattedRepositoryData = widget.repository.link!.split('/');
    _repository = widget.repository;
  }

  Future<void> getRepositoryData() async {
    setState(() {
      _loadingData = true;
    });

    try {
      final responseRepo = await GitHubService().getRepositoryData(_formattedRepositoryData);
      final responseLatestRelease = await GitHubService().getRepositoryLatestReleaseData(_formattedRepositoryData);

      if (responseRepo.statusCode == 200 && responseLatestRelease.statusCode == 200) {
        _repository = Repository.fromJSON(jsonDecode(responseRepo.body));
        Release release = Release.fromJSON(jsonDecode(responseLatestRelease.body));
        _repository.releaseLink = release.link;
        _repository.releaseVersion = release.version;
        _repository.releasePublishedDate = release.publishedDate;
        _repository.id = widget.repository.id;
        _repository.note = widget.repository.note;

        await _update();
        widget.refreshList();

        Fluttertoast.showToast(msg: "Updated ${_repository.name}");
      } else if (responseRepo.statusCode == 403) {
        Fluttertoast.showToast(msg: "API Limit Reached");
      } else {
        Fluttertoast.showToast(msg: "Error Loading");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }

    setState(() {
      _loadingData = false;
    });
  }

  Future<void> _update() async {
    await RepositoryService().update(_repository);
  }

  Future<void> _delete() async {
    await RepositoryService().delete(_repository);
  }

  _launchPage(String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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
                title: Text(_repository.name!, textAlign: TextAlign.center, style: infoStyle),
              ),
              (_repository.note!.isEmpty) ? const SizedBox.shrink() : ListTile(leading: Text(_repository.note!, style: infoStyle)),
              (_repository.releaseVersion == 'null' || _repository.releaseVersion!.isEmpty)
                  ? const SizedBox.shrink()
                  : ListTile(
                      leading: Text("Version:", style: infoStyle),
                      trailing: Text(
                          _repository.releaseVersion!.length > 18
                              ? '${_repository.releaseVersion!.substring(0, 18)}...'
                              : _repository.releaseVersion!,
                          maxLines: 1,
                          style: infoStyle),
                    ),
              (_repository.lastUpdate == 'null')
                  ? const SizedBox.shrink()
                  : ListTile(
                      leading: Text("Latest update:", style: infoStyle),
                      trailing: Text(getFormattedDate(_repository.lastUpdate!), style: infoStyle),
                    ),
              (_repository.releasePublishedDate == 'null')
                  ? const SizedBox.shrink()
                  : ListTile(
                      leading: Text("Latest release:", style: infoStyle),
                      trailing: Text(getFormattedDate(_repository.releasePublishedDate!), style: infoStyle),
                    ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.open_in_new_outlined),
                title: Text("Repository", style: infoStyle),
                onTap: () {
                  Navigator.of(context).pop();
                  _launchPage(widget.repository.link!);
                },
              ),
              /*    ListTile(
                leading: const Icon(Icons.open_in_new_outlined),
                title: const Text("Default branch commits"),
                onTap: () {
                  Navigator.of(context).pop();
                  _launchPage("${widget.repository.link!}/commits/${widget.repository.defaultBranch!}");
                },
              ),*/
              Visibility(
                visible: _repository.releasePublishedDate! != 'null',
                child: ListTile(
                  leading: const Icon(Icons.open_in_new_outlined),
                  title: const Text("Latest release"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _launchPage(widget.repository.releaseLink!);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.refresh_outlined),
                title: const Text("Refresh"),
                onTap: () {
                  Navigator.of(context).pop();
                  getRepositoryData();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_outlined),
                title: const Text("Delete"),
                onTap: () {
                  Navigator.of(context).pop();
                  showAlertDialogOkDelete(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  showAlertDialogOkDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Delete ?"),
          actions: [
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                _delete();
                widget.refreshList();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorscheme = Theme.of(context).colorScheme;
    String versionFormatted =
        _repository.releaseVersion!.length > 12 ? "${_repository.releaseVersion!.substring(0, 9)}..." : _repository.releaseVersion!;
    TextStyle titleStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: colorscheme.onPrimaryContainer,
    );
    TextStyle subtitleStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: colorscheme.onSecondaryContainer,
    );

    return InkWell(
      onTap: openBottomMenu,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ListTile(
                    title: Text(_repository.name!, style: titleStyle),
                    subtitle: Text(_repository.owner!, style: subtitleStyle),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        widget.hasNewVersion ? Icon(Icons.new_releases_outlined, color: colorscheme.onTertiaryContainer) : const SizedBox.shrink(),
                        const SizedBox(width: 10),
                        _loadingData
                            ? const Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2.0),
                                ),
                              )
                            : Visibility(
                                visible: _repository.releasePublishedDate != 'null',
                                child: Chip(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  label: Text(versionFormatted),
                                  side: const BorderSide(color: Colors.transparent),
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    color: colorscheme.onTertiaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  backgroundColor: colorscheme.tertiaryContainer,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
