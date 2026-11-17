import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class AuthError extends StatelessWidget {
  const AuthError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(MosslySpace.s4),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(MosslySpace.radiusMd),
        ),
        child: Text(message, style: TextStyle(color: scheme.onErrorContainer)),
      ),
    );
  }
}
