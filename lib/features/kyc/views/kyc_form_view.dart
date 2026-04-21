import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/startup_input_field.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/chip_selector.dart';
import 'package:aisep_capstone_mobile/features/kyc/widgets/kyc_file_upload_card.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/startup_dropdown_field.dart';
import 'package:aisep_capstone_mobile/features/kyc/view_models/kyc_view_model.dart';
import 'package:aisep_capstone_mobile/features/kyc/models/kyc_status_model.dart';
import 'package:provider/provider.dart';

class KycFormView extends StatefulWidget {
  final bool isIncorporated;
  final VoidCallback? onBack;

  const KycFormView({super.key, required this.isIncorporated, this.onBack});

  @override
  State<KycFormView> createState() => _KycFormViewState();
}

class _KycFormViewState extends State<KycFormView> {
  late final KycViewModel _viewModel;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<KycViewModel>();
    
    // Khởi tạo trạng thái ban đầu từ Dashboard
    _viewModel.isIncorporated = widget.isIncorporated;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadStatus();
    });

    // Đăng ký listeners cho TẤT CẢ bộ controllers để Auto-save hoạt động mọi lúc
    _attachListeners();
  }

  void _attachListeners() {
    // Bộ Có pháp nhân
    _viewModel.nameControllerInc.addListener(_viewModel.triggerAutoSave);
    _viewModel.taxControllerInc.addListener(_viewModel.triggerAutoSave);
    _viewModel.repNameControllerInc.addListener(_viewModel.triggerAutoSave);
    _viewModel.workEmailControllerInc.addListener(_viewModel.triggerAutoSave);
    _viewModel.linkControllerInc.addListener(_viewModel.triggerAutoSave);

    // Bộ Chưa có pháp nhân
    _viewModel.nameControllerNoInc.addListener(_viewModel.triggerAutoSave);
    _viewModel.descriptionControllerNoInc.addListener(_viewModel.triggerAutoSave);
    _viewModel.repNameControllerNoInc.addListener(_viewModel.triggerAutoSave);
    _viewModel.workEmailControllerNoInc.addListener(_viewModel.triggerAutoSave);
    _viewModel.linkControllerNoInc.addListener(_viewModel.triggerAutoSave);
  }

  void _removeListeners() {
    _viewModel.nameControllerInc.removeListener(_viewModel.triggerAutoSave);
    _viewModel.taxControllerInc.removeListener(_viewModel.triggerAutoSave);
    _viewModel.repNameControllerInc.removeListener(_viewModel.triggerAutoSave);
    _viewModel.workEmailControllerInc.removeListener(_viewModel.triggerAutoSave);
    _viewModel.linkControllerInc.removeListener(_viewModel.triggerAutoSave);

    _viewModel.nameControllerNoInc.removeListener(_viewModel.triggerAutoSave);
    _viewModel.descriptionControllerNoInc.removeListener(_viewModel.triggerAutoSave);
    _viewModel.repNameControllerNoInc.removeListener(_viewModel.triggerAutoSave);
    _viewModel.workEmailControllerNoInc.removeListener(_viewModel.triggerAutoSave);
    _viewModel.linkControllerNoInc.removeListener(_viewModel.triggerAutoSave);
  }

  @override
  void dispose() {
    _removeListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
            onPressed: () {
              if (_showForm) {
                setState(() => _showForm = false);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(_showForm ? 'Thông tin KYC' : 'Xác thực hồ sơ'),
          centerTitle: true,
          actions: [
            if (_showForm)
              _buildAutoSaveIndicator(),
          ],
        ),
        body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            if (_viewModel.isLoading && _viewModel.status == KycStatus.none) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!_showForm) {
               return _buildStatusDashboard();
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildIntroSection(),
                        const SizedBox(height: 32),
                        _buildTypeSelector(),
                        const SizedBox(height: 32),
                        
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
    );
  }

  Widget _buildAutoSaveIndicator() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _viewModel.isSavingDraft
            ? Row(
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: StartupOnboardingTheme.goldAccent),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Đang lưu...',
                    style: GoogleFonts.workSans(fontSize: 12, color: StartupOnboardingTheme.goldAccent),
                  ),
                ],
              )
            : Text(
                'Đã lưu nháp',
                style: GoogleFonts.workSans(fontSize: 12, color: Colors.greenAccent.withOpacity(0.5)),
              ),
        ),
      ),
    );
  }

  Widget _buildStatusDashboard() {
    final status = _viewModel.status;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusProgressHeader(status),
          const SizedBox(height: 32),
          Text(
            'LỘ TRÌNH XÁC THỰC',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          _buildStepRow(1, 'Thông tin định danh', 'Cung cấp tên pháp lý và mã số doanh nghiệp.', isCompleted: status != KycStatus.none),
          _buildStepDivider(status != KycStatus.none),
          _buildStepRow(2, 'Tài liệu minh chứng', 'Tải lên Pitch deck hoặc Giấy phép kinh doanh.', isCompleted: status != KycStatus.none),
          _buildStepDivider(status == KycStatus.verified || status == KycStatus.pending || status == KycStatus.rejected),
          _buildStepRow(
            3, 
            'Thẩm định hồ sơ', 
            'Chuyên gia AISEP đánh giá và phê duyệt.', 
            isCompleted: status == KycStatus.verified,
            isFailed: status == KycStatus.rejected,
            isInProgress: status == KycStatus.pending,
          ),
          const SizedBox(height: 48),
          _buildDashboardActions(status),
        ],
      ),
    );
  }

  Widget _buildStatusProgressHeader(KycStatus status) {
    Color color;
    IconData icon;
    String title;
    String message;

    switch (status) {
      case KycStatus.pending:
        color = Theme.of(context).primaryColor;
        icon = Icons.hourglass_empty_rounded;
        title = 'Đang chờ duyệt';
        message = 'Hồ sơ KYC của bạn đang được các chuyên gia AISEP thẩm định kỹ lưỡng.';
        break;
      case KycStatus.verified:
        color = Colors.greenAccent;
        icon = Icons.verified_rounded;
        title = 'Đã xác thực KYC';
        message = 'Hồ sơ của bạn đã được xác thực chính thức. Bạn có thể sử dụng đầy đủ tính năng AI.';
        break;
      case KycStatus.rejected:
        color = Colors.redAccent;
        icon = Icons.report_problem_outlined;
        title = 'Xác thực thất bại';
        message = _viewModel.rejectionReason ?? 'Hồ sơ không đáp ứng tiêu chuẩn. Vui lòng cập nhật lại.';
        break;
      default:
        color = Theme.of(context).primaryColor;
        icon = Icons.shield_outlined;
        title = 'Chưa xác thực';
        message = 'Xác thực hồ sơ KYC để mở khóa toàn bộ quyền lợi hỗ trợ từ mạng lưới nhà đầu tư.';
    }

    return FadeInDown(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 56),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 28, 
                fontWeight: FontWeight.bold, 
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(
                  fontSize: 15,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(int step, String title, String sub, {required bool isCompleted, bool isFailed = false, bool isInProgress = false}) {
    Color bgColor = isCompleted 
        ? Theme.of(context).primaryColor 
        : (isFailed ? Colors.redAccent : (isInProgress ? Theme.of(context).primaryColor.withOpacity(0.1) : Theme.of(context).cardColor));
    
    Color borderColor = (isCompleted || isFailed || isInProgress) 
        ? (isFailed ? Colors.redAccent : Theme.of(context).primaryColor)
        : Theme.of(context).primaryColor.withOpacity(0.3);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Center(
            child: isCompleted 
              ? Icon(Icons.check, size: 16, color: Theme.of(context).scaffoldBackgroundColor)
              : (isFailed 
                  ? Icon(Icons.close, size: 16, color: Colors.white)
                  : Text(
                      '$step', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 12, 
                        color: (isCompleted || isFailed) ? Colors.white : (isInProgress ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.4))
                      )
                    )),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: GoogleFonts.workSans(
                  fontWeight: FontWeight.bold, 
                  color: (isCompleted || isFailed || isInProgress) ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.4),
                  fontSize: 15,
                ),
              ),
              Text(
                sub, 
                style: GoogleFonts.workSans(
                  fontSize: 12, 
                  color: (isCompleted || isFailed || isInProgress) ? Theme.of(context).textTheme.bodyMedium?.color : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(bool isActive) {
    return Container(
      margin: const EdgeInsets.only(left: 15, top: 2, bottom: 2),
      width: 2,
      height: 30,
      color: isActive ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
    );
  }

  Widget _buildDashboardActions(KycStatus status) {
    String text = status == KycStatus.none ? 'Bắt đầu xác thực hồ sơ' : 'Cập nhật/Xem lại thông tin';
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => setState(() => _showForm = true),
            child: Text(text),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Quay lại Dashboard',
            style: GoogleFonts.workSans(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildIntroSection() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.verified_user_rounded, color: Theme.of(context).primaryColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xác thực KYC',
                    style: GoogleFonts.workSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Giúp startup của bạn được nhận diện và tăng độ tin cậy với các nhà đầu tư.',
                    style: GoogleFonts.workSans(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
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
            color: Theme.of(context).primaryColor.withOpacity(0.8),
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
          color: isSelected ? Colors.white : StartupOnboardingTheme.goldAccent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: StartupOnboardingTheme.goldAccent,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              color: isSelected ? StartupOnboardingTheme.navyBg : Colors.white,
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
        color: Theme.of(context).primaryColor.withOpacity(0.5),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
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
          fileName: _viewModel.getFileNameByKind(
            _viewModel.isIncorporated 
              ? EvidenceFileKind.BUSINESS_REGISTRATION 
              : EvidenceFileKind.OTHER
          ),
          isUploading: _viewModel.isFileUploading,
          onUpload: () => _viewModel.pickFiles(
            _viewModel.isIncorporated 
              ? EvidenceFileKind.BUSINESS_REGISTRATION 
              : EvidenceFileKind.OTHER
          ),
          onRemove: () => _viewModel.removeFileByKind(
            _viewModel.isIncorporated 
              ? EvidenceFileKind.BUSINESS_REGISTRATION 
              : EvidenceFileKind.OTHER
          ),
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
                activeColor: Theme.of(context).primaryColor,
                checkColor: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tôi cam kết các thông tin cung cấp trên là hoàn toàn trung thực và chịu trách nhiệm về tính pháp lý của các tài liệu đính kèm.',
                style: GoogleFonts.workSans(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
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
    bool isPending = _viewModel.status == KycStatus.pending;
    bool canSubmit = _viewModel.canSubmit() && !isPending;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: canSubmit ? () => _viewModel.submitKyc(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPending ? Colors.grey.withOpacity(0.1) : Theme.of(context).primaryColor,
                  disabledBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  disabledForegroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                child: _viewModel.isLoading 
                  ? SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).scaffoldBackgroundColor)
                    )
                  : Text(isPending ? 'Đang trong quá trình xét duyệt' : 'Gửi hồ sơ xác thực'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
