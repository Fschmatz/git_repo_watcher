import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class ReleaseNotesCard extends StatelessWidget {
  final String releaseBody;
  final Function(String) onLinkTap;
  final VoidCallback? onExpandTap;

  const ReleaseNotesCard({
    super.key,
    required this.releaseBody,
    required this.onLinkTap,
    this.onExpandTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorscheme = Theme.of(context).colorScheme;
    final int maxChars = 600;
    final bool isTruncated = releaseBody.length > maxChars;
    final String displayContent = isTruncated ? '${releaseBody.substring(0, maxChars)}...' : releaseBody;

    return Card(
      color: colorscheme.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.article_outlined,
                  color: colorscheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  "Release Notes",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorscheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(
                  data: displayContent,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(color: colorscheme.onSurfaceVariant, fontSize: 14, height: 1.5),
                    h1: TextStyle(color: colorscheme.onSurface, fontWeight: FontWeight.bold, fontSize: 20),
                    h2: TextStyle(color: colorscheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
                    h3: TextStyle(color: colorscheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                    listBullet: TextStyle(color: colorscheme.primary),
                    code: TextStyle(
                      backgroundColor: colorscheme.surfaceContainerHighest,
                      color: colorscheme.onSurfaceVariant,
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: colorscheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onTapLink: (text, href, title) {
                    if (href != null) onLinkTap(href);
                  },
                ),
                if (isTruncated && onExpandTap != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onExpandTap,
                      label: const Text(
                        "View full notes",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
