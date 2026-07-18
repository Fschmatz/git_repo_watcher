import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class ReleaseNotesCard extends StatelessWidget {
  final String releaseBody;
  final Function(String) onLinkTap;

  const ReleaseNotesCard({
    super.key,
    required this.releaseBody,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorscheme = Theme.of(context).colorScheme;

    return Card(
      color: colorscheme.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 24, 16),
            decoration: BoxDecoration(
              color: colorscheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.article_outlined,
                  color: colorscheme.onPrimaryContainer.withValues(alpha: 0.8),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  "Release Notes",
                  style: TextStyle(fontSize: 14, color: colorscheme.onPrimaryContainer.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
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
                if (href != null) onLinkTap(href);
              },
            ),
          ),
        ],
      ),
    );
  }
}
