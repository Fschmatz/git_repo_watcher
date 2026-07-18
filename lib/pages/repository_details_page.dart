import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../classes/release.dart';
import '../classes/repository.dart';
import '../service/github_service.dart';
import '../service/repository_service.dart';
import '../util/toast_utils.dart';
import '../util/utils_date.dart';
import '../widgets/info_chip.dart';
import '../widgets/primary_info_card.dart';
import '../widgets/release_notes_card.dart';
import 'store_repository.dart';

class RepositoryDetailsPage extends StatefulWidget {
  final Repository repository;
  final VoidCallback onRefresh;

  const RepositoryDetailsPage({
    super.key,
    required this.repository,
    required this.onRefresh,
  });

  @override
  State<RepositoryDetailsPage> createState() => _RepositoryDetailsPageState();
}

class _RepositoryDetailsPageState extends State<RepositoryDetailsPage> {
  late Repository _repository;
  bool _loadingData = false;
  late List<String> _formattedRepositoryData;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository;
    _formattedRepositoryData = widget.repository.link!.split('/');
  }

  Future<void> _getRepositoryData() async {
    if (!mounted) return;
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
        _repository.releaseBody = release.body;
        _repository.id = widget.repository.id;
        _repository.note = widget.repository.note;

        await RepositoryService().update(_repository);

        if (mounted) {
          widget.onRefresh();
        }
        ToastUtils.show("Updated ${_repository.name}");
      } else if (responseRepo.statusCode == 403) {
        ToastUtils.showErrorMessage("API Limit Reached");
      } else {
        ToastUtils.showErrorMessage("Error Loading");
      }
    } catch (e) {
      ToastUtils.showErrorMessage("Error: ${e.toString()}");
    }

    if (mounted) {
      setState(() {
        _loadingData = false;
      });
    }
  }

  void _launchPage(String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _showAlertDialogOkDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Delete ?"),
          actions: [
            TextButton(
              child: const Text("Yes"),
              onPressed: () async {
                Navigator.of(context).pop();
                await RepositoryService().delete(_repository);
                widget.onRefresh();
                if (mounted) Navigator.of(context).pop();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_repository.name ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoreRepository(
                    repositoryToEdit: _repository,
                    refreshList: () {
                      widget.onRefresh();
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_outlined),
            onPressed: () {
              _showAlertDialogOkDelete(context);
            },
          ),
        ],
        bottom: _loadingData
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4.0),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_repository.note != null && _repository.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: PrimaryInfoCard(
                  label: "Note",
                  value: _repository.note!,
                  icon: Icons.notes_outlined,
                ),
              ),
            const SizedBox(height: 12),
            if (_repository.releaseVersion != 'null' && _repository.releaseVersion != null && _repository.releaseVersion!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PrimaryInfoCard(
                  label: "Version",
                  value: _repository.releaseVersion!.length > 25 ? '${_repository.releaseVersion!.substring(0, 25)}...' : _repository.releaseVersion!,
                  icon: Icons.sell_outlined,
                ),
              ),
            Row(
              children: [
                if (_repository.releasePublishedDate != 'null' && _repository.releasePublishedDate != null)
                  Expanded(
                    child: InfoChip(
                      label: "Latest Release",
                      value: UtilsDate.format(_repository.releasePublishedDate!),
                      icon: Icons.event_available_outlined,
                    ),
                  ),
                if (_repository.releasePublishedDate != 'null' && _repository.lastUpdate != 'null') const SizedBox(width: 12),
                if (_repository.lastUpdate != 'null' && _repository.lastUpdate != null)
                  Expanded(
                    child: InfoChip(
                      label: "Latest Git Update",
                      value: UtilsDate.format(_repository.lastUpdate!),
                      icon: Icons.history_outlined,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_repository.releaseBody != null && _repository.releaseBody!.isNotEmpty)
              ReleaseNotesCard(
                releaseBody: _repository.releaseBody!,
                onLinkTap: (href) => _launchPage(href),
              ),
            Card(
              margin: EdgeInsets.zero,
              color: colorscheme.surfaceContainerHighest,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  if (_repository.releasePublishedDate != 'null') ...[
                    ListTile(
                      leading: Icon(Icons.new_releases_outlined, color: colorscheme.primary),
                      title: const Text("View Latest Release"),
                      onTap: () {
                        _launchPage(_repository.releaseLink!);
                      },
                    ),
                    const Divider(),
                  ],
                  ListTile(
                    leading: Icon(Icons.open_in_new_outlined, color: colorscheme.primary),
                    title: const Text("Open Repository"),
                    onTap: () {
                      _launchPage(_repository.link!);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.refresh_outlined, color: colorscheme.primary),
                    title: const Text("Refresh"),
                    onTap: () {
                      _getRepositoryData();
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.share_outlined, color: colorscheme.primary),
                    title: const Text("Share"),
                    onTap: () {
                      Share.share(_repository.link!);
                    },
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
