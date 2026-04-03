import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aisep_capstone_mobile/core/theme/app_colors.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBgColor;

  const OnboardingPageWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppColors.spaceXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildGeometricIcon(),
          const SizedBox(height: AppColors.space3XL),
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
          const SizedBox(height: AppColors.spaceLG),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.text.withOpacity(0.8),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeometricIcon() {
    return ElasticIn(
      duration: const Duration(milliseconds: 1000),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Geometric Shape
          Transform.rotate(
            angle: 0.2, // 12 degrees
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: iconBgColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: iconBgColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
            ),
          ),
          // Inner Shape
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: iconBgColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 64,
              color: Colors.white,
            ),
          ),
          // Small Floating Shapes
          Positioned(
            top: 0,
            right: 0,
            child: _buildFloatingDot(12, AppColors.accent),
          ),
          Positioned(
            bottom: 10,
            left: -10,
            child: _buildFloatingDot(16, AppColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingDot(double size, Color color) {
    return FadeIn(
      delay: const Duration(milliseconds: 800),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
