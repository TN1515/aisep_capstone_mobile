import 'package:flutter/material.dart';

class OnboardingNavButtons extends StatelessWidget {
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingNavButtons({
    super.key,
    required this.isLastPage,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: Text(isLastPage ? 'Bắt đầu ngay' : 'Tiếp theo'),
            ),
          ),
          const SizedBox(height: 12),
          if (!isLastPage)
            TextButton(
              onPressed: onSkip,
              child: const Text('Bỏ qua'),
            )
          else
            const SizedBox(height: 48), // Spacer for consistency
        ],
      ),
    );
  }
}
