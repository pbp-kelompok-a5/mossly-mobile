import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Tiga keadaan pemanggilan asinkron: memuat, gagal, dan kosong
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: MosslySpace.s8 * 3),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(MosslySpace.s6),
      children: [
        const SizedBox(height: MosslySpace.s8),
        Icon(Icons.cloud_off_outlined, size: 48, color: scheme.error),
        const SizedBox(height: MosslySpace.s4),
        Text(
          'Data belum bisa dimuat',
          textAlign: TextAlign.center,
          style: text.titleMedium,
        ),
        const SizedBox(height: MosslySpace.s2),
        Text(
          message,
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: MosslySpace.s6),
        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(MosslySpace.s6),
      children: [
        const SizedBox(height: MosslySpace.s8),
        Icon(icon, size: 48, color: scheme.primary),
        const SizedBox(height: MosslySpace.s4),
        Text(title, textAlign: TextAlign.center, style: text.titleMedium),
        const SizedBox(height: MosslySpace.s2),
        Text(
          message,
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
