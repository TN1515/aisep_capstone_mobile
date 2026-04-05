import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/theme/app_colors.dart';

class DotIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const DotIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        bool isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isActive ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
