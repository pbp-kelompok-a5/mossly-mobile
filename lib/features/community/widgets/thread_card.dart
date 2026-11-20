import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../models/community_thread.dart';

String communityCategoryLabel(String category) => switch (category) {
  'tips' => 'Tips',
  'achievement' => 'Pencapaian',
  'general' => 'Obrolan',
  _ => category,
};

String communityDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final local = date.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day} ${months[local.month - 1]} ${local.year} · $hour:$minute';
}

class ThreadAuthorHeader extends StatelessWidget {
  const ThreadAuthorHeader({super.key, required this.thread});
  final CommunityThread thread;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final icon = switch (thread.author.avatar) {
      'leaf' => Icons.eco_outlined,
      'tree' => Icons.park_outlined,
      _ => Icons.spa_outlined,
    };
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: Icon(icon),
        ),
        const SizedBox(width: MosslySpace.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                thread.author.displayName,
                style: text.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '@${thread.author.username}',
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ThreadLabels extends StatelessWidget {
  const ThreadLabels({super.key, required this.thread});
  final CommunityThread thread;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: MosslySpace.s2,
      runSpacing: MosslySpace.s2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Chip(
          label: Text(communityCategoryLabel(thread.category)),
          backgroundColor: scheme.primaryContainer,
          labelStyle: TextStyle(color: scheme.onPrimaryContainer),
          side: BorderSide.none,
        ),
        if (thread.isAutoPost)
          const Chip(
            avatar: Icon(Icons.auto_awesome_outlined, size: 18),
            label: Text('Pencapaian otomatis'),
          ),
      ],
    );
  }
}

/// Status dibaca dari backend; aksi like/reply menyusul setelah CP1.
class ThreadStats extends StatelessWidget {
  const ThreadStats({super.key, required this.thread});
  final CommunityThread thread;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: MosslySpace.s6,
      runSpacing: MosslySpace.s2,
      children: [
        Semantics(
          label: thread.isLiked ? 'Kamu sudah mengapresiasi cerita ini' : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                thread.isLiked ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: thread.isLiked
                    ? scheme.tertiary
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: MosslySpace.s2),
              Text('${thread.likeCount} apresiasi'),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 20,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: MosslySpace.s2),
            Text('${thread.replyCount} balasan'),
          ],
        ),
      ],
    );
  }
}

class ThreadCard extends StatelessWidget {
  const ThreadCard({super.key, required this.thread, required this.onTap});
  final CommunityThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MosslySpace.radiusLg),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(MosslySpace.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ThreadAuthorHeader(thread: thread),
              const SizedBox(height: MosslySpace.s2),
              ThreadLabels(thread: thread),
              const SizedBox(height: MosslySpace.s2),
              Text(
                thread.title,
                style: text.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: MosslySpace.s2),
              Text(thread.body, maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: MosslySpace.s3),
              Text(
                communityDate(thread.createdAt),
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: MosslySpace.s4),
              ThreadStats(thread: thread),
            ],
          ),
        ),
      ),
    );
  }
}
