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

  Widget _buildVersionCard(BuildContext context, String version) {
    final colorscheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorscheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.sell_outlined, size: 28, color: colorscheme.onPrimaryContainer),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Version",
                  style: TextStyle(fontSize: 13, color: colorscheme.onPrimaryContainer.withValues(alpha: 0.8)),
                ),
                Text(
                  version,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorscheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value, IconData icon) {
    final colorscheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorscheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: colorscheme.onSecondaryContainer),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colorscheme.onSecondaryContainer.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorscheme.onSecondaryContainer),
          ),
        ],
      ),
    );
  }

  void openBottomMenu() {
    widget.onVersionViewed?.call();
    showModalBottomSheet(
      isScrollControlled: true,
      showDragHandle: true,
      context: context,
      builder: (BuildContext bc) {
        final colorscheme = Theme.of(context).colorScheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _repository.name!,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                /*
                if (_repository.owner != null && _repository.owner!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      _repository.owner!,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorscheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  */
                if (_repository.note != null && _repository.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      _repository.note!,
                      style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: colorscheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                if (_repository.releaseVersion != 'null' && _repository.releaseVersion!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildVersionCard(
                      context,
                      _repository.releaseVersion!.length > 25 ? '${_repository.releaseVersion!.substring(0, 25)}...' : _repository.releaseVersion!,
                    ),
                  ),
                Row(
                  children: [
                    if (_repository.releasePublishedDate != 'null')
                      Expanded(
                        child: _buildInfoChip(
                          context,
                          "Latest Release",
                          UtilsDate.format(_repository.releasePublishedDate!),
                          Icons.event_available_outlined,
                        ),
                      ),
                    if (_repository.releasePublishedDate != 'null' && _repository.lastUpdate != 'null') const SizedBox(width: 12),
                    if (_repository.lastUpdate != 'null')
                      Expanded(
                        child: _buildInfoChip(
                          context,
                          "Latest Git Update",
                          UtilsDate.format(_repository.lastUpdate!),
                          Icons.history_outlined,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: colorscheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.open_in_new_outlined, color: colorscheme.primary),
                        title: const Text("Open Repository"),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                        onTap: () {
                          Navigator.of(context).pop();
                          _launchPage(widget.repository.link!);
                        },
                      ),
                      if (_repository.releasePublishedDate != 'null') ...[
                        ListTile(
                          leading: Icon(Icons.new_releases_outlined, color: colorscheme.primary),
                          title: const Text("Open Latest Release"),
                          onTap: () {
                            Navigator.of(context).pop();
                            _launchPage(widget.repository.releaseLink!);
                          },
                        ),
                      ],
                      ListTile(
                        leading: Icon(Icons.refresh_outlined, color: colorscheme.primary),
                        title: const Text("Refresh Data"),
                        onTap: () {
                          Navigator.of(context).pop();
                          getRepositoryData();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.delete_outline_outlined, color: colorscheme.primary),
                        title: Text("Delete"),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
                        onTap: () {
                          Navigator.of(context).pop();
                          showAlertDialogOkDelete(context);
                        },
                      ),
                    ],
                  ),
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
