import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/startup_input_field.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/startup_dropdown_field.dart';
import 'package:aisep_capstone_mobile/features/profile/view_models/profile_setup_view_model.dart';
import 'package:aisep_capstone_mobile/features/dashboard/views/dashboard_view.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:aisep_capstone_mobile/features/onboarding/views/startup_onboarding_screen.dart';

class ProfileSetupView extends StatefulWidget {
  const ProfileSetupView({super.key});

  @override
  State<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<ProfileSetupView> {
  final _formKey = GlobalKey<FormState>();
  late final ProfileSetupViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileSetupViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Theme(
          data: StartupOnboardingTheme.lightTheme,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: _buildAppBar(),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFDFCFB), // Lighter top
                    StartupOnboardingTheme.softIvory, // Original bottom
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildStepper(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: _buildStepContent(),
                        ),
                      ),
                    ),
                    _buildBottomActions(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: StartupOnboardingTheme.navyBg),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            // Fallback nếu không có màn hình trước đó trong stack
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const StartupOnboardingScreen()),
            );
          }
        },
      ),
      centerTitle: true,
      title: Text(
        'Thiết lập hồ sơ',
        style: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: StartupOnboardingTheme.navyBg,
        ),
      ),
      actions: const [],
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepIcon(0, LucideIcons.building, 'GIỚI THIỆU'),
          _buildStepLine(0),
          _buildStepIcon(1, LucideIcons.messageSquare, 'CÂU CHUYỆN'),
          _buildStepLine(1),
          _buildStepIcon(2, LucideIcons.rocket, 'HOÀN TẤT'),
        ],
      ),
    );
  }

  Widget _buildStepIcon(int step, IconData icon, String label) {
    bool isCompleted = _viewModel.currentStep > step;
    bool isActive = _viewModel.currentStep == step;
    Color color = isActive || isCompleted ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.navyBg.withOpacity(0.15);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color.withOpacity(0.1) : Colors.transparent,
            border: Border.all(
              color: color,
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive ? [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int afterStep) {
    bool isCompleted = _viewModel.currentStep > afterStep;
    return Container(
      width: 44,
      height: 1,
      margin: const EdgeInsets.only(left: 4, right: 4, bottom: 20),
      color: isCompleted ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.navyBg.withOpacity(0.05),
    );
  }

  Widget _buildStepContent() {
    switch (_viewModel.currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1() {
    return FadeInRight(
      duration: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Startup của bạn là gì?',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: StartupOnboardingTheme.navyBg,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chỉ cần 3 thông tin cơ bản — bạn phải hoàn thành để tiếp tục.',
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: StartupOnboardingTheme.navyBg.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          StartupInputField(
            label: 'TÊN STARTUP *',
            hint: 'VD: SmartFarm',
            controller: _viewModel.nameController,
            validator: (v) => v?.trim().isEmpty ?? true ? 'Vui lòng nhập tên startup' : null,
          ),
          const SizedBox(height: 24),
          _buildFieldWithCounter(
            label: 'KHẨU HIỆU / TAGLINE *',
            hint: 'Giải pháp nông trại thông minh',
            controller: _viewModel.taglineController,
            maxLength: 100,
            validator: (v) => v?.trim().isEmpty ?? true ? 'Vui lòng nhập khẩu hiệu' : null,
          ),
          const SizedBox(height: 24),
          StartupDropdownField(
            label: 'LĨNH VỰC *',
            hint: 'Chọn lĩnh vực',
            items: _viewModel.industries,
            value: _viewModel.selectedIndustry.isEmpty ? null : _viewModel.selectedIndustry,
            onChanged: (v) => _viewModel.selectIndustry(v ?? ''),
            validator: (v) => (v == null || v.isEmpty) ? 'Bắt buộc chọn lĩnh vực' : null,
          ),
          const SizedBox(height: 24),
          StartupDropdownField(
            label: 'GIAI ĐOẠN *',
            hint: 'Chọn giai đoạn',
            items: _viewModel.stages,
            value: _viewModel.selectedStage.isEmpty ? null : _viewModel.selectedStage,
            onChanged: (v) => _viewModel.selectStage(v ?? ''),
            validator: (v) => (v == null || v.isEmpty) ? 'Bắt buộc chọn giai đoạn' : null,
          ),
          const SizedBox(height: 32),
          _buildHintBox(
            LucideIcons.lightbulb,
            'Hãy chọn thông tin chính xác nhất về Startup của bạn.',
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return FadeInRight(
      duration: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kể câu chuyện của bạn',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: StartupOnboardingTheme.navyBg,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Viết thật tự nhiên — không cần hoàn hảo. AI sẽ giúp bạn trau chuốt sau.',
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: StartupOnboardingTheme.navyBg.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          _buildFieldWithCounter(
            label: 'VẤN ĐỀ BẠN ĐANG GIẢI QUYẾT *',
            hint: 'Khách hàng của bạn đang gặp vấn đề gì lớn?',
            controller: _viewModel.problemController,
            maxLength: 300,
            maxLines: 4,
            validator: (v) => v?.trim().isEmpty ?? true ? 'Vui lòng mô tả vấn đề' : null,
          ),
          const SizedBox(height: 24),
          _buildFieldWithCounter(
            label: 'GIẢI PHÁP CỦA BẠN *',
            hint: 'Bạn giải quyết bằng cách nào khác biệt?',
            controller: _viewModel.solutionController,
            maxLength: 300,
            maxLines: 4,
            validator: (v) => v?.trim().isEmpty ?? true ? 'Vui lòng mô tả giải pháp' : null,
          ),
          const SizedBox(height: 24),
          _buildFieldWithCounter(
            label: 'KHÁCH HÀNG MỤC TIÊU *',
            hint: 'Vd: SMEs tại Việt Nam, sinh viên đại học...',
            controller: _viewModel.targetCustomersController,
            maxLength: 150,
            maxLines: 2,
            validator: (v) => v?.trim().isEmpty ?? true ? 'Vui lòng nhập đối tượng' : null,
          ),
          const SizedBox(height: 32),
          _buildHintBox(
            LucideIcons.shield,
            'Thông tin của bạn được bảo mật và không chia sẻ cho bên thứ ba.',
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(height: 60),
          ZoomIn(
            duration: const Duration(milliseconds: 800),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.greenAccent.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
                size: 100,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Hồ sơ đã được tạo!',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: StartupOnboardingTheme.navyBg,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Chào mừng bạn đến với hệ sinh thái AISEP.\nHành trình kiến tạo tương lai của bạn bắt đầu từ đây.',
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(
                fontSize: 16,
                color: StartupOnboardingTheme.navyBg.withOpacity(0.6),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }



  Widget _buildFieldWithCounter({
    required String label,
    required String hint,
    required TextEditingController controller,
    required int maxLength,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                label,
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: StartupOnboardingTheme.goldAccent.withOpacity(0.7),
                  letterSpacing: 1.0,
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, value, _) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4, bottom: 8),
                  child: Text(
                    '${value.text.length}/$maxLength',
                    style: GoogleFonts.workSans(
                      fontSize: 10,
                      color: StartupOnboardingTheme.navyBg.withOpacity(0.3),
                    ),
                  ),
                );
              }
            ),
          ],
        ),
        StartupInputField(
          label: '', // Label already handled above for counter logic
          hint: hint,
          controller: controller,
          maxLines: maxLines,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildHintBox(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navyBg.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: StartupOnboardingTheme.goldAccent, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.workSans(
                fontSize: 12,
                color: StartupOnboardingTheme.navyBg.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    if (_viewModel.currentStep == 2) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DashboardView()),
            ),
            child: const Text('Bắt đầu khám phá'),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Row(
        children: [
          if (_viewModel.currentStep == 1) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _viewModel.isLoading ? null : _viewModel.previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: StartupOnboardingTheme.navyBg.withOpacity(0.1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Quay lại', style: TextStyle(color: StartupOnboardingTheme.navyBg.withOpacity(0.6))),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _viewModel.isLoading 
                ? null 
                : () {
                    if (_viewModel.currentStep == 1) {
                      _viewModel.saveAndComplete(context, _formKey, const DashboardView());
                    } else {
                      _viewModel.nextStep(_formKey);
                    }
                  },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _viewModel.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_viewModel.currentStep == 1 ? 'Hoàn tất' : 'Tiếp tục'),
                        const SizedBox(width: 8),
                        const Icon(LucideIcons.arrowRight, size: 16),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
