import 'package:flutter/material.dart';
import '../../../../core/theme/startup_onboarding_theme.dart';

class ProfileSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onEdit;
  final bool showEdit;

  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.onEdit,
    this.showEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: StartupOnboardingTheme.softIvory.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: StartupOnboardingTheme.goldAccent.withOpacity(0.9),
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
                if (showEdit && onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: onEdit,
                    color: StartupOnboardingTheme.goldAccent,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
          Divider(
            height: 1, 
            thickness: 0.5, 
            color: StartupOnboardingTheme.softIvory.withOpacity(0.1),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ],
      ),
    );
  }
}
