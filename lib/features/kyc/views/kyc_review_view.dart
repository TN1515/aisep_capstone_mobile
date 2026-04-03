import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/kyc/view_models/kyc_view_model.dart';

class KycReviewView extends StatefulWidget {
  final KycViewModel viewModel;

  const KycReviewView({
    super.key,
    required this.viewModel,
  });

  @override
  State<KycReviewView> createState() => _KycReviewViewState();
}

class _KycReviewViewState extends State<KycReviewView> {
  bool _isAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: StartupOnboardingTheme.darkTheme,
      child: Scaffold(
        backgroundColor: StartupOnboardingTheme.navyBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Xem lại hồ sơ',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: StartupOnboardingTheme.softIvory,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: StartupOnboardingTheme.softIvory),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, child) {
            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeInDown(
                            child: _buildSection(
                              'Thông tin Startup',
                              [
                                _buildInfoRow(widget.viewModel.isIncorporated ? 'Tên pháp lý' : 'Tên Dự án', widget.viewModel.nameController.text),
                                _buildInfoRow(widget.viewModel.isIncorporated ? 'Mã số thuế' : 'Mô tả', widget.viewModel.taxOrDescriptionController.text),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          FadeInDown(
                            delay: const Duration(milliseconds: 100),
                            child: _buildSection(
                              'Người đại diện',
                              [
                                _buildInfoRow('Họ và tên', widget.viewModel.repNameController.text),
                                _buildInfoRow('Email', widget.viewModel.workEmailController.text),
                                _buildInfoRow('Vai trò', widget.viewModel.selectedRole),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          FadeInDown(
                            delay: const Duration(milliseconds: 200),
                            child: _buildSection(
                              'Tài liệu & Liên kết',
                              [
                                _buildFileRow(widget.viewModel.isIncorporated ? 'Giấy đăng ký doanh nghiệp' : 'Minh chứng dự án', widget.viewModel.uploadedFileName),
                                _buildInfoRow('Website / Link', widget.viewModel.linkController.text),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          FadeInUp(
                            delay: const Duration(milliseconds: 300),
                            child: _buildDeclaration(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isAgreed && !widget.viewModel.isLoading 
                            ? () => widget.viewModel.submitKyc(context) 
                            : null,
                          child: widget.viewModel.isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: StartupOnboardingTheme.navyBg, strokeWidth: 2))
                            : const Text('Gửi hồ sơ xác thực'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: StartupOnboardingTheme.goldAccent,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: 12,
              color: StartupOnboardingTheme.slateGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? 'N/A' : value,
            style: GoogleFonts.workSans(
              fontSize: 15,
              color: StartupOnboardingTheme.softIvory,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileRow(String label, String? fileName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: 12,
              color: StartupOnboardingTheme.slateGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: StartupOnboardingTheme.navyBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file_rounded, color: StartupOnboardingTheme.goldAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fileName ?? 'N/A',
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      color: StartupOnboardingTheme.goldAccent,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeclaration() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _isAgreed,
            onChanged: (val) => setState(() => _isAgreed = val ?? false),
            activeColor: StartupOnboardingTheme.goldAccent,
            checkColor: StartupOnboardingTheme.navyBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () => setState(() => _isAgreed = !_isAgreed),
            child: Text(
              'Tôi cam đoan rằng mọi thông tin cung cấp ở trên là chính xác và hoàn toàn chịu trách nhiệm về tính trung thực của hồ sơ.',
              style: GoogleFonts.workSans(
                fontSize: 13,
                height: 1.5,
                color: StartupOnboardingTheme.softIvory.withOpacity(0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
