import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Design system untuk halaman Accounts; tema modul lain tetap dikelola core.
class MosslyAuthTheme extends StatelessWidget {
  const MosslyAuthTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final scheme = base.colorScheme;
    final body = base.textTheme.apply(fontFamily: 'PlusJakartaSans');
    final text = body.copyWith(
      headlineSmall: body.headlineSmall?.copyWith(
        fontFamily: 'RedHatDisplay',
        fontSize: 24,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      titleLarge: body.titleLarge?.copyWith(
        fontFamily: 'RedHatDisplay',
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: body.bodyMedium?.copyWith(fontSize: 16, height: 1.6),
      bodySmall: body.bodySmall?.copyWith(fontSize: 14, height: 1.55),
      labelLarge: body.labelLarge?.copyWith(
        fontSize: 16,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: body.labelMedium?.copyWith(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: body.labelSmall?.copyWith(
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
    const radius = BorderRadius.all(Radius.circular(MosslySpace.radiusMd));
    return Theme(
      data: base.copyWith(
        textTheme: text,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surfaceContainerLowest,
          contentPadding: const EdgeInsets.all(MosslySpace.s4),
          labelStyle: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          hintStyle: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          prefixIconColor: scheme.onSurfaceVariant,
          suffixIconColor: scheme.onSurfaceVariant,
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: scheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: scheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: scheme.error, width: 2),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            disabledBackgroundColor: MosslyColors.sand200,
            disabledForegroundColor: MosslyColors.neutral600,
            minimumSize: const Size(0, 52),
            padding: const EdgeInsets.symmetric(
              horizontal: MosslySpace.s6,
              vertical: MosslySpace.s4,
            ),
            shape: const StadiumBorder(),
            textStyle: text.labelLarge,
            elevation: 0,
          ),
        ),
        appBarTheme: base.appBarTheme.copyWith(
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: text.titleLarge,
        ),
      ),
      child: child,
    );
  }
}
