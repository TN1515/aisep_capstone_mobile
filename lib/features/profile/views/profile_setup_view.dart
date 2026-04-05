import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/startup_input_field.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/startup_dropdown_field.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/chip_selector.dart';
import 'package:aisep_capstone_mobile/features/profile/view_models/profile_setup_view_model.dart';
import 'package:aisep_capstone_mobile/features/dashboard/views/main_navigation_container.dart';
import 'package:aisep_capstone_mobile/features/dashboard/views/dashboard_view.dart';

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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
          actions: [
            TextButton(
              onPressed: () => _viewModel.skipToDashboard(context, const DashboardView()),
              child: const Text('Bỏ qua'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            return SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: Text(
                          'Hoàn thiện hồ sơ',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          'Hãy chia sẻ thông tin cơ bản để chúng tôi hỗ trợ bạn tốt hơn.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Section 1: Identification
                      _buildSectionHeader('1. Định danh Startup'),
                      const SizedBox(height: 16),
                      StartupInputField(
                        label: 'Tên Startup',
                        hint: 'VD: BioCore AI',
                        controller: _viewModel.nameController,
                        validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tên startup' : null,
                      ),
                      const SizedBox(height: 24),
                      StartupInputField(
                        label: 'Họ và tên Founder',
                        hint: 'VD: Nguyễn Alpha',
                        controller: _viewModel.founderController,
                        validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tên người sáng lập' : null,
                      ),
                      const SizedBox(height: 40),

                      // Section 2: Stage & Industry
                      _buildSectionHeader('2. Giai đoạn & Lĩnh vực'),
                      const SizedBox(height: 16),
                      StartupDropdownField(
                        label: 'Giai đoạn hiện tại',
                        hint: 'Chọn giai đoạn phát triển',
                        items: _viewModel.stages,
                        value: _viewModel.selectedStage,
                        onChanged: (v) => _viewModel.selectStage(v ?? ''),
                        validator: (v) => v == null || v.isEmpty ? 'Vui lòng chọn giai đoạn' : null,
                      ),
                      const SizedBox(height: 24),
                      StartupDropdownField(
                        label: 'Lĩnh vực chính',
                        hint: 'Chọn lĩnh vực hoạt động',
                        items: _viewModel.industries,
                        value: _viewModel.selectedIndustry,
                        onChanged: (v) => _viewModel.selectIndustry(v ?? ''),
                        validator: (v) => v == null || v.isEmpty ? 'Vui lòng chọn lĩnh vực' : null,
                      ),
                      const SizedBox(height: 40),

                      // Section 3: More Details
                      _buildSectionHeader('3. Thông tin bổ sung'),
                      const SizedBox(height: 16),
                      StartupDropdownField(
                        label: 'Trụ sở chính',
                        hint: 'Chọn quốc gia / khu vực',
                        items: _viewModel.locations,
                        value: _viewModel.selectedLocation,
                        onChanged: (v) => _viewModel.selectLocation(v ?? ''),
                        validator: (v) => v == null || v.isEmpty ? 'Vui lòng chọn vị trí' : null,
                      ),
                      const SizedBox(height: 24),
                      StartupInputField(
                        label: 'Khẩu hiệu / Slogan',
                        hint: 'Mô tả ngắn về startup của bạn',
                        controller: _viewModel.taglineController,
                      ),
                      const SizedBox(height: 48),

                      // Actions
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _viewModel.isLoading 
                              ? null 
                              : () => _viewModel.saveAndContinue(context, _formKey, const DashboardView()),
                          child: _viewModel.isLoading 
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Theme.of(context).brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white, strokeWidth: 2),
                                )
                              : const Text('Lưu và tiếp tục'),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 400),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.workSans(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: StartupOnboardingTheme.goldAccent.withOpacity(0.6),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.workSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: StartupOnboardingTheme.softIvory.withOpacity(0.9),
      ),
    );
  }
}
