import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Square album artwork with a graceful neon fallback.
class Cover extends StatelessWidget {
  const Cover({
    super.key,
    required this.asset,
    this.size,
    this.radius = 16,
    this.heroTag,
    this.accent,
    this.child,
  });

  final String asset;
  final double? size;
  final double radius;
  final String? heroTag;
  final int? accent;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      asset,
      fit: BoxFit.cover,
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => _Fallback(accent: accent),
    );

    if (child != null) {
      image = Stack(fit: StackFit.expand, children: [image, child!]);
    }

    image = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: size, height: size, child: image),
    );

    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }
    return image;
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({this.accent});

  final int? accent;

  @override
  Widget build(BuildContext context) {
    final base = accent != null ? Color(accent!) : AppColors.violet;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base.withValues(alpha: 0.9), AppColors.surfaceAlt],
        ),
      ),
      child: const Center(
        child: Icon(Icons.graphic_eq, color: Colors.white54, size: 26),
      ),
    );
  }
}
