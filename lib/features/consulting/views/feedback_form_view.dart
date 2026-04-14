import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/consulting_session_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/core/utils/toast_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class FeedbackFormView extends StatefulWidget {
  final ConsultingSessionModel session;

  const FeedbackFormView({Key? key, required this.session}) : super(key: key);

  @override
  State<FeedbackFormView> createState() => _FeedbackFormViewState();
}

class _FeedbackFormViewState extends State<FeedbackFormView> {
  double _rating = 5;
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: StartupOnboardingTheme.navyBg,
        appBar: AppBar(
          backgroundColor: StartupOnboardingTheme.navyBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Gửi Đánh giá',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: StartupOnboardingTheme.softIvory,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildAdvisorHero(),
              const SizedBox(height: 48),
              Text(
                'Buổi tư vấn như thế nào?',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.softIvory),
              ),
              const SizedBox(height: 8),
              Text(
                'Đánh giá của bạn giúp chúng tôi cải thiện chất lượng.',
                style: GoogleFonts.workSans(fontSize: 12, color: StartupOnboardingTheme.softIvory.withOpacity(0.5)),
              ),
              const SizedBox(height: 32),
              _buildStarRating(),
              const SizedBox(height: 48),
              _buildCommentSection(),
            ],
          ),
        ),
        bottomNavigationBar: _buildSubmitButton(context),
      ),
    );
  }

  Widget _buildAdvisorHero() {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(widget.session.advisor?.profilePhotoURL ?? ''),
        ),
        const SizedBox(height: 16),
        Text(
          widget.session.advisor?.fullName ?? 'Unknown',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.softIvory),
        ),
        Text(
          widget.session.objective,
          style: GoogleFonts.workSans(fontSize: 14, color: StartupOnboardingTheme.goldAccent),
        ),
      ],
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => setState(() => _rating = index + 1.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
              color: index < _rating ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.softIvory.withOpacity(0.2),
              size: 48,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cảm nhận của bạn',
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.softIvory),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _commentController,
          maxLines: 5,
          style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory),
          decoration: InputDecoration(
            hintText: 'Nhận xét của bạn giúp Cố vấn cải thiện hơn...',
            hintStyle: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory.withOpacity(0.2), fontSize: 13),
            filled: true,
            fillColor: StartupOnboardingTheme.navySurface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: StartupOnboardingTheme.goldAccent)),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: ElevatedButton(
        onPressed: () => _handleSubmit(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: StartupOnboardingTheme.goldAccent,
          foregroundColor: StartupOnboardingTheme.navyBg,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          'Gửi Đánh giá',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _handleSubmit(BuildContext context) {
    context.read<ConsultingViewModel>().submitFeedback(
      widget.session.id,
      _rating,
      _commentController.text,
    );
    
    ToastUtils.showTopToast(context, 'Cảm ơn bạn đã gửi đánh giá!');
    Navigator.pop(context);
  }
}
