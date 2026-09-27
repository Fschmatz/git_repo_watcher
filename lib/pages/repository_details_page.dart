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
import '../widgets/release_notes_card.dart';
import 'full_release_notes_page.dart';
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

  void _openFullReleaseNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullReleaseNotesPage(
          title: _repository.name ?? 'Release Notes',
          version: _repository.releaseVersion,
          releaseBody: _repository.releaseBody ?? '',
        ),
      ),
    );
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
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton.tonal(
              child: const Text("Delete"),
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

    final hasVersion = _repository.releaseVersion != null && _repository.releaseVersion != 'null' && _repository.releaseVersion!.isNotEmpty;
    final hasReleaseDate = _repository.releasePublishedDate != null && _repository.releasePublishedDate != 'null';
    final hasGitDate = _repository.lastUpdate != null && _repository.lastUpdate != 'null';
    final hasNote = _repository.note != null && _repository.note!.isNotEmpty;
    final hasReleaseBody = _repository.releaseBody != null && _repository.releaseBody!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(_repository.name ?? ''),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: "More options",
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  if (!_loadingData) _getRepositoryData();
                  break;
                case 'share':
                  if (_repository.link != null) {
                    Share.share(_repository.link!);
                  }
                  break;
                case 'edit':
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
                  break;
                case 'delete':
                  _showAlertDialogOkDelete(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh_outlined),
                    SizedBox(width: 12),
                    Text("Refresh"),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined),
                    SizedBox(width: 12),
                    Text("Share"),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 12),
                    Text("Edit"),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_outlined),
                    const SizedBox(width: 12),
                    Text(
                      "Delete",
                    ),
                  ],
                ),
              ),
            ],
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorscheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorscheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.sell_outlined,
                          size: 22,
                          color: colorscheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Version",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colorscheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              hasVersion ? _repository.releaseVersion! : "No release version",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorscheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (hasNote) ...[
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.sticky_note_2_outlined,
                          size: 20,
                          color: colorscheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _repository.note!,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorscheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (hasReleaseDate || hasGitDate) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (hasReleaseDate)
                    Expanded(
                      child: InfoChip(
                        label: "Latest Release",
                        value: UtilsDate.format(_repository.releasePublishedDate!),
                        icon: Icons.event_available_outlined,
                      ),
                    ),
                  if (hasReleaseDate && hasGitDate) const SizedBox(width: 12),
                  if (hasGitDate)
                    Expanded(
                      child: InfoChip(
                        label: "Latest Git Update",
                        value: UtilsDate.format(_repository.lastUpdate!),
                        icon: Icons.history_outlined,
                      ),
                    ),
                ],
              ),
            ],
            if (hasReleaseBody) ...[
              const SizedBox(height: 20),
              ReleaseNotesCard(
                releaseBody: _repository.releaseBody!,
                onLinkTap: (href) => _launchPage(href),
                onExpandTap: _openFullReleaseNotes,
              ),
            ],
            const SizedBox(height: 10),
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  if (_repository.releaseLink != null && _repository.releaseLink!.isNotEmpty) ...[
                    ListTile(
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: colorscheme.primaryContainer,
                        child: Icon(
                          Icons.new_releases_outlined,
                          size: 20,
                          color: colorscheme.onPrimaryContainer,
                        ),
                      ),
                      title: const Text(
                        "View on GitHub Releases",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: const Text(
                        "Open last release page",
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        _launchPage(_repository.releaseLink!);
                      },
                    ),
                    Divider(),
                  ],
                  if (_repository.link != null && _repository.link!.isNotEmpty)
                    ListTile(
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: colorscheme.secondaryContainer,
                        child: Icon(
                          Icons.code_rounded,
                          size: 20,
                          color: colorscheme.onSecondaryContainer,
                        ),
                      ),
                      title: const Text(
                        "Open Repository",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: const Text(
                        "Source code on GitHub",
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.open_in_new, size: 16),
                      onTap: () {
                        _launchPage(_repository.link!);
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
