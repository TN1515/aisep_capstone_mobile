import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/startup_onboarding_theme.dart';
import '../view_models/startup_profile_view_model.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/profile_text_field.dart';
import '../widgets/profile_dropdown_field.dart';
import '../../kyc/views/kyc_form_view.dart';

class StartupProfileView extends StatefulWidget {
  const StartupProfileView({super.key});

  @override
  State<StartupProfileView> createState() => _StartupProfileViewState();
}

class _StartupProfileViewState extends State<StartupProfileView> {
  late final StartupProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = StartupProfileViewModel();
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
      builder: (context, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Unified Hero Section (Backdrop + Logo + Basic Info)
                  _buildUnifiedHeader(),
                  
                  // Detail Sections
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          if (_viewModel.isEditMode) 
                            _buildEditForm() 
                          else 
                            _buildViewMode(),
                          const SizedBox(height: 100), // Bottom spacing
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_viewModel.isLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
            ],
          ),
          floatingActionButton: _viewModel.isEditMode ? FloatingActionButton.extended(
            onPressed: () => _viewModel.saveProfile(),
            label: const Text('Lưu thay đổi', style: TextStyle(fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.check_rounded),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.accent,
          ) : null,
        );
      },
    );
  }

  Widget _buildUnifiedHeader() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          // 1. Backdrop + Overlapping Logo Stack
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Backdrop Image
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.accent, Color(0xFF1F2937)],
                  ),
                ),
                child: Opacity(
                  opacity: 0.3,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1557683316-973673baf926?auto=format&fit=crop&q=80&w=1000',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Floating Buttons (Actions)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 16,
                child: Row(
                  children: [
                    if (!_viewModel.isEditMode)
                      _buildFloatingActionCircle(Icons.share_outlined, () {}),
                  ],
                ),
              ),

              // THE LOGO (Perfectly layered using Positioned within the same Stack)
              Positioned(
                bottom: -50,
                child: _buildProfileLogo(),
              ),
            ],
          ),
          
          const SizedBox(height: 60), // Space for the logo overlap

          // 2. Info Header (Name, Tagline, Chips, Buttons)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildProfileHeaderInfo(),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionCircle(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildProfileLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          _viewModel.profile.logoUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 50, color: AppColors.textMuted),
        ),
      ),
    );
  }

  Widget _buildProfileHeaderInfo() {
    return Column(
      children: [
        // Name
        Text(
          _viewModel.profile.startupName,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          // Tagline
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _viewModel.profile.tagline,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Quick Chips (Stage / Industry / Location)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildCompactChip(_viewModel.profile.stage, Icons.rocket_launch_outlined, Colors.blue.shade50, Colors.blue.shade700),
              _buildCompactChip(_viewModel.profile.industry, Icons.category_outlined, Colors.purple.shade50, Colors.purple.shade700),
              _buildCompactChip(_viewModel.profile.location, Icons.location_on_outlined, Colors.orange.shade50, Colors.orange.shade700),
            ],
          ),
        ],
      );
  }

  Widget _buildCompactChip(String label, IconData icon, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => _viewModel.toggleEditMode(),
          icon: Icon(_viewModel.isEditMode ? Icons.close_rounded : Icons.edit_rounded, size: 16),
          label: Text(_viewModel.isEditMode ? 'Hủy bỏ' : 'Chỉnh sửa hồ sơ'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _viewModel.isEditMode ? Colors.white : AppColors.accent,
            foregroundColor: _viewModel.isEditMode ? AppColors.error : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: _viewModel.isEditMode ? const BorderSide(color: AppColors.error) : BorderSide.none,
            ),
            textStyle: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (!_viewModel.isEditMode) ...[
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const KycFormView(isIncorporated: true)),
              );
            },
            icon: const Icon(Icons.verified_user_outlined, size: 16),
            label: const Text('Xác thực'),
            style: ElevatedButton.styleFrom(
              backgroundColor: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
              foregroundColor: StartupOnboardingTheme.goldAccent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: StartupOnboardingTheme.goldAccent, width: 1),
              ),
              textStyle: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        if (!_viewModel.isEditMode) ...[
          const SizedBox(width: 12),
          Container(
            height: 42, // Match button height roughly
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.share_outlined, color: AppColors.accent, size: 20),
              tooltip: 'Chia sẻ hồ sơ',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildViewMode() {
    return Column(
      children: [
        // Section 1: Basic Info
        ProfileSectionCard(
          title: 'THÔNG TIN CƠ BẢN',
          child: Column(
            children: [
              _buildInfoRow(Icons.language_rounded, 'Website', _viewModel.profile.websiteLink, isLink: true),
              _buildInfoRow(Icons.app_shortcut_rounded, 'Sản phẩm', _viewModel.profile.productLink, isLink: true),
              _buildInfoRow(Icons.play_circle_outline_rounded, 'Demo', _viewModel.profile.demoLink, isLink: true),
              _buildInfoRow(Icons.business_center_outlined, 'Lĩnh vực', _viewModel.profile.industry),
              _buildInfoRow(Icons.place_outlined, 'Trụ sở', _viewModel.profile.location),
            ],
          ),
        ),

        // Section 2: Business Overview
        ProfileSectionCard(
          title: 'TỔNG QUAN KINH DOANH',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLongTextInfo('Vấn đề giải quyết', _viewModel.profile.problemStatement),
              const Divider(height: 24),
              _buildLongTextInfo('Giải pháp của chúng tôi', _viewModel.profile.solutionSummary),
              const Divider(height: 24),
              _buildInfoRow(Icons.groups_3_outlined, 'Thị trường mục tiêu', _viewModel.profile.marketScope),
              _buildInfoRow(Icons.auto_graph_rounded, 'Trạng thái sản phẩm', _viewModel.profile.productStatus),
              _buildInfoRow(Icons.lightbulb_outline_rounded, 'Nhu cầu hiện tại', _viewModel.profile.currentNeeds, isLast: true),
            ],
          ),
        ),

        // Section 3: Team
        ProfileSectionCard(
          title: 'ĐỘI NGŨ SÁNG LẬP',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_pin_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sáng lập viên', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                        Text(_viewModel.profile.founderNames.replaceAll('\n', ', '), style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.text, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.work_outline_rounded, 'Vai trò', _viewModel.profile.founderRoles),
              _buildInfoRow(Icons.group_outlined, 'Quy mô nhân sự', _viewModel.profile.teamSize, isLast: true),
            ],
          ),
        ),

        // Section 4: Validation
        ProfileSectionCard(
          title: 'XÁC THỰC BAN ĐẦU',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.verified_outlined, 'Trạng thái', _viewModel.profile.validationStatus),
              _buildLongTextInfo('Chỉ số nổi bật', _viewModel.profile.metricSummary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLink = false, bool isLast = false}) {
    final displayValue = value.isEmpty ? 'Chưa cập nhật' : value;
    final isPlaceholder = value.isEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                Text(
                  displayValue,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: isLink && !isPlaceholder ? Colors.blue.shade700 : AppColors.text,
                    fontWeight: FontWeight.w600,
                    decoration: isLink && !isPlaceholder ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLongTextInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? 'Chưa cập nhật' : value,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppColors.text,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CHỈNH SỬA HỒ SƠ', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
        const SizedBox(height: 16),
        
        ProfileSectionCard(
          title: 'ĐỊNH DANH STARTUP',
          child: Column(
            children: [
              ProfileTextField(label: 'Tên Startup', controller: _viewModel.nameController, hint: 'VD: EcoTrack AI'),
              ProfileTextField(label: 'Khẩu hiệu (Tagline)', controller: _viewModel.taglineController, hint: 'Mô tả ngắn gọn về startup'),
              ProfileDropdownField(
                label: 'Giai đoạn',
                items: _viewModel.stages,
                value: _viewModel.selectedStage,
                onChanged: (v) => setState(() => _viewModel.selectedStage = v),
              ),
              ProfileDropdownField(
                label: 'Lĩnh vực chính',
                items: _viewModel.industries,
                value: _viewModel.selectedIndustry,
                onChanged: (v) => setState(() => _viewModel.selectedIndustry = v),
              ),
              ProfileDropdownField(
                label: 'Trụ sở chính',
                items: _viewModel.locations,
                value: _viewModel.selectedLocation,
                onChanged: (v) => setState(() => _viewModel.selectedLocation = v),
              ),
            ],
          ),
        ),

        ProfileSectionCard(
          title: 'LIÊN KẾT & MỀM',
          child: Column(
            children: [
              ProfileTextField(label: 'Website', controller: _viewModel.websiteController, hint: 'https://...', keyboardType: TextInputType.url),
              ProfileTextField(label: 'Link sản phẩm', controller: _viewModel.productController, hint: 'https://...', keyboardType: TextInputType.url),
              ProfileTextField(label: 'Link Demo/Pitch deck', controller: _viewModel.demoController, hint: 'https://...', keyboardType: TextInputType.url),
            ],
          ),
        ),

        ProfileSectionCard(
          title: 'TỔNG QUAN KINH DOANH',
          child: Column(
            children: [
              ProfileTextField(label: 'Vấn đề đang giải quyết', controller: _viewModel.problemController, maxLines: 3),
              ProfileTextField(label: 'Giải pháp', controller: _viewModel.solutionController, maxLines: 3),
              ProfileDropdownField(
                label: 'Mô hình thị trường',
                items: _viewModel.marketScopes,
                value: _viewModel.selectedMarketScope,
                onChanged: (v) => setState(() => _viewModel.selectedMarketScope = v),
              ),
              ProfileTextField(label: 'Trạng thái sản phẩm / Nhu cầu hiện tại', controller: _viewModel.needsController, maxLines: 2),
            ],
          ),
        ),

        ProfileSectionCard(
          title: 'ĐỘI NGŨ & XÁC THỰC',
          child: Column(
            children: [
              ProfileTextField(label: 'Tên các Sáng lập viên', controller: _viewModel.founderNamesController, hint: 'Mỗi tên một dòng', maxLines: 2),
              ProfileTextField(label: 'Vai trò', controller: _viewModel.founderRolesController),
              ProfileTextField(label: 'Quy mô nhân sự', controller: _viewModel.teamSizeController, hint: 'VD: 10 thành viên'),
              ProfileDropdownField(
                label: 'Trạng thái xác thực',
                items: _viewModel.validationStatuses,
                value: _viewModel.selectedValidationStatus,
                onChanged: (v) => setState(() => _viewModel.selectedValidationStatus = v),
              ),
              ProfileTextField(label: 'Chỉ số/Thành tựu nổi bật', controller: _viewModel.metricController, maxLines: 2),
            ],
          ),
        ),
      ],
    );
  }
}
