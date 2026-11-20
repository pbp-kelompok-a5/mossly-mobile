import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Tetap berada di scroll view agar refresh tersedia saat kosong/gagal.
class CommunityFeedback extends StatelessWidget {
  const CommunityFeedback({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.forum_outlined,
    this.onRetry,
  });
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MosslySpace.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: scheme.primary),
            const SizedBox(height: MosslySpace.s4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MosslySpace.s2),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: MosslySpace.s4),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
