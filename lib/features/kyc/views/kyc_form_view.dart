import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/startup_input_field.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/chip_selector.dart';
import 'package:aisep_capstone_mobile/features/kyc/widgets/kyc_file_upload_card.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/startup_dropdown_field.dart';
import 'package:aisep_capstone_mobile/features/kyc/view_models/kyc_view_model.dart';
import 'package:aisep_capstone_mobile/features/kyc/views/kyc_review_view.dart';

class KycFormView extends StatefulWidget {
  final bool isIncorporated;
  final VoidCallback? onBack;

  const KycFormView({super.key, required this.isIncorporated, this.onBack});

  @override
  State<KycFormView> createState() => _KycFormViewState();
}

class _KycFormViewState extends State<KycFormView> {
  late final KycViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = KycViewModel(isIncorporated: widget.isIncorporated);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: StartupOnboardingTheme.darkTheme,
      child: Scaffold(
        backgroundColor: StartupOnboardingTheme.navyBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: StartupOnboardingTheme.softIvory),
          ),
          title: Text(
            'Xác thực hồ sơ',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: StartupOnboardingTheme.softIvory,
            ),
          ),
          centerTitle: true,
        ),
        body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildStatusBanner(),
                        const SizedBox(height: 16),
                        _buildIntroSection(),
                        const SizedBox(height: 32),
                        _buildTypeSelector(),
                        const SizedBox(height: 32),
                        
                        // Form Sections with Animations
                        _buildSectionHeader('1. Thông tin định danh'),
                        const SizedBox(height: 16),
                        _buildBasicInfoSection(),
                        
                        const SizedBox(height: 32),
                        _buildSectionHeader('2. Người nộp hồ sơ'),
                        const SizedBox(height: 16),
                        _buildRepresentativeSection(),
                        
                        const SizedBox(height: 32),
                        _buildSectionHeader('3. Minh chứng hoạt động'),
                        const SizedBox(height: 16),
                        _buildVerificationSection(),
                        
                        const SizedBox(height: 32),
                        _buildCommitmentSection(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    if (_viewModel.status == KycStatus.none) return const SizedBox.shrink();

    Color color;
    IconData icon;
    String title;
    String message;

    switch (_viewModel.status) {
      case KycStatus.pending:
        color = StartupOnboardingTheme.goldAccent;
        icon = Icons.hourglass_empty_rounded;
        title = 'Đang chờ duyệt';
        message = 'Hồ sơ của bạn đang được chuyên gia thẩm định.';
        break;
      case KycStatus.verified:
        color = Colors.greenAccent;
        icon = Icons.check_circle_outline_rounded;
        title = 'Đã xác thực';
        message = 'Tài khoản của bạn đã được xác thực thành công.';
        break;
      case KycStatus.rejected:
        color = Colors.redAccent;
        icon = Icons.error_outline_rounded;
        title = 'Từ chối xác thực';
        message = _viewModel.rejectionReason ?? 'Hồ sơ không đạt yêu cầu. Vui lòng kiểm tra lại.';
        break;
      case KycStatus.infoRequired:
        color = Colors.orangeAccent;
        icon = Icons.info_outline_rounded;
        title = 'Cần bổ sung thông tin';
        message = 'Vui lòng cập nhật thêm tài liệu theo yêu cầu bên dưới.';
        break;
      default:
        return const SizedBox.shrink();
    }

    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.workSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_user_rounded, color: StartupOnboardingTheme.goldAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'MÔ PHỎNG XÁC THỰC KYC',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: StartupOnboardingTheme.goldAccent,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroSection() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: StartupOnboardingTheme.goldAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: StartupOnboardingTheme.goldAccent, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xác thực nhanh (Light)',
                    style: GoogleFonts.workSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: StartupOnboardingTheme.goldAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Giúp startup của bạn được nhận diện và tăng độ tin cậy với các nhà đầu tư.',
                    style: GoogleFonts.workSans(
                      fontSize: 13,
                      color: StartupOnboardingTheme.softIvory.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại hình Startup',
          style: GoogleFonts.workSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: StartupOnboardingTheme.goldAccent.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTypeToggleItem(
                title: 'Có pháp nhân',
                isSelected: _viewModel.isIncorporated,
                onTap: () => _viewModel.toggleIncorporated(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeToggleItem(
                title: 'Chưa pháp nhân',
                isSelected: !_viewModel.isIncorporated,
                onTap: () => _viewModel.toggleIncorporated(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeToggleItem({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.navySurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.goldAccent.withOpacity(0.2),
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: StartupOnboardingTheme.goldAccent.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.workSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? StartupOnboardingTheme.navyBg : StartupOnboardingTheme.softIvory.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.workSans(
        fontSize: 12,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w800,
        color: StartupOnboardingTheme.goldAccent.withOpacity(0.5),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return FadeIn(
      key: ValueKey(_viewModel.isIncorporated),
      child: Column(
        children: [
          StartupInputField(
            label: _viewModel.isIncorporated ? 'Tên pháp lý đầy đủ' : 'Tên dự án / Startup',
            hint: _viewModel.isIncorporated ? 'VD: Công ty TNHH AISEP Tech' : 'VD: BioCore AI Project',
            controller: _viewModel.nameController,
          ),
          const SizedBox(height: 20),
          StartupInputField(
            label: _viewModel.isIncorporated ? 'Mã số doanh nghiệp' : 'Mô tả ngắn gọn',
            hint: _viewModel.isIncorporated ? 'VD: 0313XXXXXX' : 'VD: Giải pháp giải mã gen ứng dụng AI',
            controller: _viewModel.taxOrDescriptionController,
            keyboardType: _viewModel.isIncorporated ? TextInputType.number : TextInputType.text,
          ),
        ],
      ),
    );
  }

  Widget _buildRepresentativeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StartupInputField(
          label: 'Họ tên người nộp',
          hint: 'Nguyễn Văn A',
          controller: _viewModel.repNameController,
        ),
        const SizedBox(height: 20),
        StartupInputField(
          label: 'Email công việc/liên hệ',
          hint: 'founder@aisep.vn',
          controller: _viewModel.workEmailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 20),
        StartupDropdownField(
          label: 'Vai trò của bạn',
          hint: 'Chọn vai trò của bạn',
          items: _viewModel.roles,
          value: _viewModel.selectedRole,
          onChanged: (value) => _viewModel.selectRole(value ?? ''),
        ),
      ],
    );
  }

  Widget _buildVerificationSection() {
    return Column(
      children: [
        KycFileUploadCard(
          title: _viewModel.isIncorporated ? 'Giấy đăng ký kinh doanh' : 'Tài liệu dự án (Pitch Deck/Minh chứng)',
          hint: 'Vui lòng tải lên file PDF hoặc hình ảnh (max 10MB)',
          fileName: _viewModel.uploadedFileName,
          isUploading: _viewModel.isFileUploading,
          onUpload: _viewModel.handleUpload,
          onRemove: _viewModel.removeFile,
        ),
        const SizedBox(height: 20),
        StartupInputField(
          label: 'Website hoặc Link sản phẩm',
          hint: 'https://aisep.vn',
          controller: _viewModel.linkController,
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _buildCommitmentSection() {
    return InkWell(
      onTap: () => _viewModel.setCommitted(!_viewModel.isCommitted),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _viewModel.isCommitted,
                onChanged: _viewModel.setCommitted,
                activeColor: StartupOnboardingTheme.goldAccent,
                checkColor: StartupOnboardingTheme.navyBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: BorderSide(color: StartupOnboardingTheme.goldAccent.withOpacity(0.5)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tôi cam kết các thông tin cung cấp trên là hoàn toàn trung thực và chịu trách nhiệm về tính pháp lý của các tài liệu đính kèm.',
                style: GoogleFonts.workSans(
                  fontSize: 13,
                  color: StartupOnboardingTheme.softIvory.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    bool isDone = _viewModel.status == KycStatus.pending || _viewModel.status == KycStatus.verified;
    bool canSubmit = _viewModel.canSubmit() && !isDone;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navyBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canSubmit ? () => _viewModel.submitKyc(context) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDone ? Colors.grey.withOpacity(0.1) : StartupOnboardingTheme.goldAccent,
              disabledBackgroundColor: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
              disabledForegroundColor: StartupOnboardingTheme.goldAccent.withOpacity(0.3),
            ),
            child: _viewModel.isLoading 
              ? const SizedBox(
                  height: 20, 
                  width: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: StartupOnboardingTheme.navyBg)
                )
              : Text(isDone ? 'Đang trong quá trình xét duyệt' : 'Gửi hồ sơ xác thực'),
          ),
        ),
      ),
    );
  }
}
