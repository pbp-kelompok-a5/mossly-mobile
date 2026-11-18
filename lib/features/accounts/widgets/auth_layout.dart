import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Tata letak bersama untuk form masuk dan kartu sesi Accounts.
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(MosslySpace.s6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Image(
                image: AssetImage('assets/branding/mossly-mark.png'),
                width: 76,
                height: 80,
                semanticLabel: 'Logo Mossly, huruf M kayu berlumut',
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(height: MosslySpace.s6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(MosslySpace.s6),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(MosslySpace.radiusXl),
                  border: Border.all(color: scheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.onSurface.withValues(alpha: 0.08),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                    BoxShadow(
                      color: scheme.onSurface.withValues(alpha: 0.04),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
