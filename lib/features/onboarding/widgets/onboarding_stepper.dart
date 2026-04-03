import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/theme/app_colors.dart';

class OnboardingStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const OnboardingStepper({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        bool isActive = index == currentStep;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            width: isActive ? 24 : 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.accent : AppColors.text.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
