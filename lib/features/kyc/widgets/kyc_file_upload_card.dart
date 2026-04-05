import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';

class KycFileUploadCard extends StatelessWidget {
  final String title;
  final String hint;
  final String? fileName;
  final VoidCallback onUpload;
  final VoidCallback onRemove;
  final bool isUploading;

  const KycFileUploadCard({
    super.key,
    required this.title,
    required this.hint,
    this.fileName,
    required this.onUpload,
    required this.onRemove,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.workSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: StartupOnboardingTheme.goldAccent.withOpacity(0.9),
            ),
          ),
        ),
        InkWell(
          onTap: fileName == null && !isUploading ? onUpload : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: fileName != null 
                  ? StartupOnboardingTheme.goldAccent 
                  : StartupOnboardingTheme.goldAccent.withOpacity(0.1),
                width: 1.5,
                style: fileName != null ? BorderStyle.solid : BorderStyle.none, // Can use dotted package if needed, but solid is premium
              ),
            ),
            child: isUploading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(StartupOnboardingTheme.goldAccent),
                    ),
                  )
                : fileName != null
                    ? Row(
                        children: [
                          const Icon(
                            Icons.insert_drive_file_rounded,
                            color: StartupOnboardingTheme.goldAccent,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fileName!,
                                  style: GoogleFonts.workSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Tải lên thành công',
                                  style: GoogleFonts.workSans(
                                    fontSize: 12,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: onRemove,
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          const Icon(
                            Icons.cloud_upload_outlined,
                            size: 40,
                            color: StartupOnboardingTheme.goldAccent,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Nhấn để tải tệp lên',
                            style: GoogleFonts.workSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hint,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.workSans(
                              fontSize: 13,
                              color: StartupOnboardingTheme.slateGray.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }
}
