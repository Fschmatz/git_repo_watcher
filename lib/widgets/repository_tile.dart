import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:git_repo_watcher/classes/repository.dart';
import 'package:git_repo_watcher/util/utils_date.dart';
import 'package:url_launcher/url_launcher.dart';

import '../classes/release.dart';
import '../service/github_service.dart';
import '../service/repository_service.dart';

class RepositoryTile extends StatefulWidget {
  final Repository repository;
  final Function refreshList;
  final bool hasNewVersion;
  final VoidCallback? onNewVersionDetected;
  final VoidCallback? onVersionViewed;

  const RepositoryTile({
    super.key,
    required this.repository,
    required this.refreshList,
    this.hasNewVersion = false,
    this.onNewVersionDetected,
    this.onVersionViewed,
  });

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

  @override
  void didUpdateWidget(covariant RepositoryTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.repository != widget.repository) {
      setState(() {
        _repository = widget.repository;
      });
    }
  }

  Future<void> getRepositoryData() async {
    setState(() {
      _loadingData = true;
    });

    try {
      final responseRepo = await GitHubService().getRepositoryData(_formattedRepositoryData);
      final responseLatestRelease = await GitHubService().getRepositoryLatestReleaseData(_formattedRepositoryData);

      if (responseRepo.statusCode == 200 && responseLatestRelease.statusCode == 200) {
        String? oldDate = widget.repository.releasePublishedDate;

        _repository = Repository.fromJSON(jsonDecode(responseRepo.body));
        Release release = Release.fromJSON(jsonDecode(responseLatestRelease.body));
        _repository.releaseLink = release.link;
        _repository.releaseVersion = release.version;
        _repository.releasePublishedDate = release.publishedDate;
        _repository.id = widget.repository.id;
        _repository.note = widget.repository.note;

        if (oldDate != null && oldDate.isNotEmpty && oldDate != 'null' && _repository.releasePublishedDate != oldDate) {
          widget.onNewVersionDetected?.call();
        }

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

  void _launchPage(String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void openBottomMenu() {
    TextStyle styleTrailing = const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

    widget.onVersionViewed?.call();
    showModalBottomSheet(
      isScrollControlled: true,
      showDragHandle: true,
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Wrap(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _repository.name!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Column(
                    children: [
                      if (_repository.note!.isNotEmpty)
                        ListTile(
                          title: Text(_repository.note!),
                        ),
                      if (_repository.releaseVersion != 'null' && _repository.releaseVersion!.isNotEmpty)
                        ListTile(
                          title: const Text("Version"),
                          trailing: Text(
                            _repository.releaseVersion!.length > 18
                                ? '${_repository.releaseVersion!.substring(0, 18)}...'
                                : _repository.releaseVersion!,
                            style: styleTrailing,
                          ),
                        ),
                      if (_repository.lastUpdate != 'null')
                        ListTile(
                          title: const Text("Latest update"),
                          trailing: Text(
                            UtilsDate.format(_repository.lastUpdate!),
                            style: styleTrailing,
                          ),
                        ),
                      if (_repository.releasePublishedDate != 'null')
                        ListTile(
                          title: const Text("Latest release"),
                          trailing: Text(
                            UtilsDate.format(_repository.releasePublishedDate!),
                            style: styleTrailing,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24, width: double.infinity),
                Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.open_in_new_outlined),
                      title: const Text("Repository"),
                      onTap: () {
                        Navigator.of(context).pop();
                        _launchPage(widget.repository.link!);
                      },
                    ),
                    if (_repository.releasePublishedDate != 'null') ...[
                      ListTile(
                        leading: const Icon(Icons.new_releases_outlined),
                        title: const Text("Latest release"),
                        onTap: () {
                          Navigator.of(context).pop();
                          _launchPage(widget.repository.releaseLink!);
                        },
                      ),
                    ],
                    ListTile(
                      leading: const Icon(Icons.refresh_outlined),
                      title: const Text("Refresh"),
                      onTap: () {
                        Navigator.of(context).pop();
                        getRepositoryData();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.delete_outline_outlined),
                      title: Text("Delete"),
                      onTap: () {
                        Navigator.of(context).pop();
                        showAlertDialogOkDelete(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showAlertDialogOkDelete(BuildContext context) {
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
        _repository.releaseVersion!.length > 10 ? "${_repository.releaseVersion!.substring(0, 8)}..." : _repository.releaseVersion!;
    TextStyle subtitleStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: colorscheme.onSecondaryContainer,
    );

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: openBottomMenu,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _repository.name!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorscheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _repository.owner!,
                      style: subtitleStyle,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.hasNewVersion) Icon(Icons.new_releases_rounded, color: colorscheme.primary, size: 28),
                  if (widget.hasNewVersion) const SizedBox(width: 8),
                  _loadingData
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                          child: const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        )
                      : Visibility(
                          visible: _repository.releasePublishedDate != 'null',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorscheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              versionFormatted,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorscheme.onSecondaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
