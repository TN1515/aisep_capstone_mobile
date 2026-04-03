import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/features/onboarding/models/onboarding_page_model.dart';

class OnboardingContentWidget extends StatelessWidget {
  final OnboardingPageModel model;

  const OnboardingContentWidget({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          // Illustration - Large and Clean
          Flexible(
            flex: 6,
            child: Image.asset(
              model.imagePath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            model.title,
            textAlign: TextAlign.center,
            style: textTheme.displayLarge,
          ),
          const SizedBox(height: 20),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              model.description,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
