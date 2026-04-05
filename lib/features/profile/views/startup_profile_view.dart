import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/startup_onboarding_theme.dart';
import '../view_models/startup_profile_view_model.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/profile_text_field.dart';
import '../widgets/profile_dropdown_field.dart';
import '../../kyc/views/kyc_form_view.dart';
import '../../settings/views/settings_view.dart'; // NEW
import '../../membership/views/membership_upgrade_view.dart'; // NEW

class StartupProfileView extends StatefulWidget {
  const StartupProfileView({super.key});

  @override
  State<StartupProfileView> createState() => _StartupProfileViewState();
}

class _StartupProfileViewState extends State<StartupProfileView> {
  late final StartupProfileViewModel _viewModel;
  late final ScrollController _scrollController;
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _viewModel = StartupProfileViewModel();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    // Check if near enough to bottom to trigger docking
    final isBottom = _scrollController.position.pixels >= 
                     (_scrollController.position.maxScrollExtent - 20);
                     
    if (isBottom != _isAtBottom) {
      setState(() {
        _isAtBottom = isBottom;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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
                controller: _scrollController,
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
                
              if (_viewModel.isEditMode)
                _buildStickyFooter(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStickyFooter() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        decoration: BoxDecoration(
          // Transparent when at bottom, white-ish/blurred when sticky
          color: _isAtBottom 
              ? Colors.transparent 
              : Colors.white,
          boxShadow: _isAtBottom ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _viewModel.toggleEditMode(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12), // Reduced from 16
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Reduced from 16
                ),
                child: Text('Hủy bỏ', style: GoogleFonts.workSans(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13)), // Added fontSize
              ),
            ),
            const SizedBox(width: 12), // Reduced from 16
            Expanded(
              child: ElevatedButton(
                onPressed: () => _viewModel.saveProfile(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 12), // Reduced from 16
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Reduced from 16
                  elevation: 0,
                ),
                child: Text('Lưu thay đổi', style: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 13)), // Added fontSize
              ),
            ),
          ],
        ),
      ),
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
              
              // Backdrop Edit Button (Semi-transparent camera icon)
              if (_viewModel.isEditMode)
                Positioned(
                  bottom: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
                  ),
                ),
              
              // Floating Buttons (Actions)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                child: _buildFloatingActionCircle(Icons.arrow_back, () => Navigator.of(context).pop()),
              ),

              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 16,
                child: Row(
                  children: [
                    if (!_viewModel.isEditMode)
                      _buildFloatingActionCircle(
                        Icons.workspace_premium_rounded, 
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MembershipUpgradeView()),
                          );
                        },
                        iconColor: StartupOnboardingTheme.goldAccent,
                      ),
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

  Widget _buildFloatingActionCircle(IconData icon, VoidCallback onTap, {Color iconColor = Colors.white}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildProfileLogo() {
    return Stack(
      children: [
        Container(
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
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.business, size: 50, color: AppColors.textMuted),
            ),
          ),
        ),
        if (_viewModel.isEditMode)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileHeaderInfo() {
    return Column(
      children: [
        // Name
        Text(
          _viewModel.profile.startupName,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
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
              style: GoogleFonts.workSans(
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
    if (_viewModel.isEditMode) return const SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => _viewModel.toggleEditMode(),
          icon: const Icon( Icons.edit_rounded, size: 16),
          label: const Text('Chỉnh sửa hồ sơ'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.workSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
              side: const BorderSide(color: StartupOnboardingTheme.goldAccent, width: 1),
            ),
            textStyle: GoogleFonts.workSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsView()),
              );
            },
            icon: const Icon(Icons.settings_outlined, color: AppColors.accent, size: 20),
            tooltip: 'Cài đặt',
          ),
        ),
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
                        Text('Sáng lập viên', style: GoogleFonts.workSans(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                        Text(_viewModel.profile.founderNames.replaceAll('\n', ', '), style: GoogleFonts.workSans(fontSize: 14, color: AppColors.text, fontWeight: FontWeight.w600)),
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
                Text(label, style: GoogleFonts.workSans(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                Text(
                  displayValue,
                  style: GoogleFonts.workSans(
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
        Text(label, style: GoogleFonts.workSans(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? 'Chưa cập nhật' : value,
          style: GoogleFonts.workSans(
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
        // Removed "CHỈNH SỬA HỒ SƠ" title
        
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

        const SizedBox(height: 40),
      ],
    );
  }
}
