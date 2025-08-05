import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:git_repo_watcher/classes/repository.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
import 'package:url_launcher/url_launcher.dart';

import '../classes/release.dart';
import '../service/repository_service.dart';

class RepositoryTile extends StatefulWidget {
  final Repository repository;
  final Function refreshList;
  final bool refreshAllRepositories;

  const RepositoryTile({Key? key, required this.repository, required this.refreshList, required this.refreshAllRepositories}) : super(key: key);

  @override
  State<RepositoryTile> createState() => _RepositoryTileState();
}

class _RepositoryTileState extends State<RepositoryTile> {
  late Repository _repository;
  bool _loadingData = false;
  List<String> _formattedRepositoryData = [];
  bool _newVersion = false;
  String _previousReleasePublishedDate = '';

  @override
  void initState() {
    _formattedRepositoryData = widget.repository.link!.split('/');
    _repository = widget.repository;
    _previousReleasePublishedDate = widget.repository.releasePublishedDate!;

    if (widget.refreshAllRepositories) {
      getRepositoryData();
    }

    super.initState();
  }

  Future<void> getRepositoryData() async {
    setState(() {
      _loadingData = true;
    });

    //REPO
    final responseRepo = await http.get(Uri.parse("https://api.github.com/repos/${_formattedRepositoryData[3]}/${_formattedRepositoryData[4]}"));

    //RELEASE
    final responseRelease = await http.get(
      Uri.parse("https://api.github.com/repos/${_formattedRepositoryData[3]}/${_formattedRepositoryData[4]}/releases/latest"),
    );

    if (responseRepo.statusCode == 200) {
      _repository = Repository.fromJSON(jsonDecode(responseRepo.body));
      Release release = Release.fromJSON(jsonDecode(responseRelease.body));
      _repository.releaseLink = release.link;
      _repository.releaseVersion = release.version;
      _repository.releasePublishedDate = release.publishedDate;
      _repository.id = widget.repository.id;
      _repository.note = widget.repository.note;

      await _update();
      widget.repository.releaseLink = _repository.releaseLink;

      showNewReleaseIcon();
    } else if (responseRepo.statusCode == 403) {
      Fluttertoast.showToast(msg: "API Limit");
    } else if (responseRepo.statusCode == 404) {
      Fluttertoast.showToast(msg: "Error Loading");
    } else {
      Fluttertoast.showToast(msg: "Error Loading");
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

  void showNewReleaseIcon() {
    if (_previousReleasePublishedDate.isNotEmpty && _repository.releasePublishedDate != null && _repository.releasePublishedDate!.isNotEmpty) {
      if (_previousReleasePublishedDate != _repository.releasePublishedDate) {
        setState(() {
          _newVersion = !_newVersion;
        });
      }
    }
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
              /* (_repository.owner == 'null')
                  ? const SizedBox.shrink()
                  : ListTile(
                      leading: Text("Owner", style: infoStyle),
                      trailing: Text(_repository.owner!, style: infoStyle),
                    ),*/
              (_repository.lastUpdate == 'null')
                  ? const SizedBox.shrink()
                  : ListTile(
                      leading: Text("Latest update", style: infoStyle),
                      trailing: Text(getFormattedDate(_repository.lastUpdate!), style: infoStyle),
                    ),
              (_repository.releasePublishedDate == 'null')
                  ? const SizedBox.shrink()
                  : ListTile(
                      leading: Text("Latest release", style: infoStyle),
                      trailing: Text(getFormattedDate(_repository.releasePublishedDate!), style: infoStyle),
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
                title: const Text("View default branch commits"),
                onTap: () {
                  Navigator.of(context).pop();
                  _launchPage("${widget.repository.link!}/commits/${widget.repository.defaultBranch!}");
                },
              ),
              Visibility(
                visible: _repository.releasePublishedDate! != 'null',
                child: ListTile(
                  leading: const Icon(Icons.open_in_new_outlined),
                  title: const Text("View latest release"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _launchPage(widget.repository.releaseLink!);
                  },
                ),
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
        _repository.releaseVersion!.length > 14 ? "${_repository.releaseVersion!.substring(0, 11)}..." : _repository.releaseVersion!;
    TextStyle titleStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorscheme.onPrimaryContainer);
    TextStyle subtitleStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorscheme.onSecondaryContainer);

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
                        _newVersion ? Icon(Icons.new_releases_outlined, color: colorscheme.onTertiaryContainer) : const SizedBox.shrink(),
                        const SizedBox(width: 10),
                        _loadingData
                            ? const Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.0)),
                              )
                            : Visibility(
                                visible: _repository.releasePublishedDate != 'null',
                                child: Chip(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  label: Text(versionFormatted),
                                  side: const BorderSide(color: Colors.transparent),
                                  labelStyle: TextStyle(fontSize: 12, color: colorscheme.onTertiaryContainer, fontWeight: FontWeight.w600),
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
