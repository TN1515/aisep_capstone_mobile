import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/theme/app_colors.dart';

class StartupCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? borderRadius;

  const StartupCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppColors.spaceLG),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 32),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: AppColors.text.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
