import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:git_repo_watcher/classes/repository.dart';
import 'package:git_repo_watcher/util/utils_date.dart';
import 'package:url_launcher/url_launcher.dart';

import '../classes/release.dart';
import '../service/github_service.dart';
import '../service/github_service.dart';
import '../service/repository_service.dart';
import '../util/toast_utils.dart';
import '../pages/repository_details_page.dart';

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

  @override
  void initState() {
    super.initState();
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

  void openDetailsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RepositoryDetailsPage(
          repository: _repository,
          onRefresh: () {
            widget.refreshList();
          },
        ),
      ),
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
        onTap: openDetailsPage,
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
                  Visibility(
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
