import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class FullReleaseNotesPage extends StatelessWidget {
  final String title;
  final String releaseBody;
  final String? version;

  const FullReleaseNotesPage({
    super.key,
    required this.title,
    required this.releaseBody,
    this.version,
  });

  void _launchUrl(String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colorscheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Release Notes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (version != null && version!.isNotEmpty && version != 'null')
              Text(
                version!,
                style: TextStyle(
                  fontSize: 12,
                  color: colorscheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 75),
        child: MarkdownBody(
          data: releaseBody,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(color: colorscheme.onSurfaceVariant, fontSize: 15, height: 1.5),
            h1: TextStyle(color: colorscheme.onSurface, fontWeight: FontWeight.bold, fontSize: 24),
            h2: TextStyle(color: colorscheme.onSurface, fontWeight: FontWeight.bold, fontSize: 20),
            h3: TextStyle(color: colorscheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
            listBullet: TextStyle(color: colorscheme.primary),
            code: TextStyle(
              backgroundColor: colorscheme.surfaceContainerHighest,
              color: colorscheme.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
            codeblockDecoration: BoxDecoration(
              color: colorscheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onTapLink: (text, href, title) {
            if (href != null) _launchUrl(href);
          },
        ),
      ),
    );
  }
}
