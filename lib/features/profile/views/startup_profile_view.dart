import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/startup_onboarding_theme.dart';
import '../view_models/startup_profile_view_model.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/profile_text_field.dart';
import '../widgets/profile_dropdown_field.dart';
import '../../kyc/views/kyc_form_view.dart';
import '../../settings/views/settings_view.dart';
import '../../membership/views/membership_upgrade_view.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

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
    // Khởi tạo ViewModel từ Provider để đồng bộ dữ liệu
    _viewModel = context.read<StartupProfileViewModel>();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _viewModel.setLogo(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StartupProfileViewModel>();
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildUnifiedHeader(viewModel),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      if (viewModel.isEditMode) _buildEditForm(viewModel) else _buildViewMode(viewModel),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (viewModel.isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator(color: StartupOnboardingTheme.goldAccent)),
            ),
          if (viewModel.isEditMode) _buildStickyFooter(viewModel),
        ],
      ),
    );
  }

  Widget _buildStickyFooter(StartupProfileViewModel viewModel) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 20, 
              offset: const Offset(0, -5)
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => viewModel.toggleEditMode(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Theme.of(context).dividerColor.withOpacity(0.05),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Hủy bỏ', 
                  style: GoogleFonts.workSans(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  )
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => viewModel.saveProfile(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: StartupOnboardingTheme.goldAccent,
                  foregroundColor: StartupOnboardingTheme.navyBg,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Lưu thay đổi', style: GoogleFonts.workSans(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedHeader(StartupProfileViewModel viewModel) {
    final profile = viewModel.profile;
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 200, width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Theme.of(context).cardColor, Theme.of(context).scaffoldBackgroundColor],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: 0.6,
                      child: Image.network(
                        'https://images.unsplash.com/photo-1558591710-4b4a1ae0f04d?auto=format&fit=crop&q=80&w=1000',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Dark overlay for text readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                child: _buildFloatingActionCircle(LucideIcons.arrowLeft, () => Navigator.of(context).pop()),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 16,
                child: Row(
                  children: [
                    _buildFloatingActionCircle(
                      LucideIcons.crown, 
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MembershipUpgradeView())),
                    ),
                    const SizedBox(width: 12),
                    _buildFloatingActionCircle(
                      LucideIcons.settings, 
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsView())),
                    ),
                  ],
                ),
              ),
              Positioned(bottom: -50, child: _buildProfileLogo(viewModel)),
            ],
          ),
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Text(
                  profile.startupName, 
                  textAlign: TextAlign.center, 
                  style: GoogleFonts.outfit(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    color: StartupOnboardingTheme.navyBg,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile.tagline, 
                  textAlign: TextAlign.center, 
                  style: GoogleFonts.workSans(
                    fontSize: 15, 
                    color: StartupOnboardingTheme.navyBg.withOpacity(0.7), 
                    fontWeight: FontWeight.w500
                  )
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
                  children: [
                    _buildCompactChip(profile.stage, LucideIcons.rocket, StartupOnboardingTheme.goldAccent.withOpacity(0.15), StartupOnboardingTheme.goldAccent),
                    _buildCompactChip(profile.industry, LucideIcons.box, Colors.white.withOpacity(0.1), Colors.white),
                    _buildCompactChip(profile.location, LucideIcons.mapPin, Colors.white.withOpacity(0.1), Colors.white),
                  ],
                ),
                const SizedBox(height: 24),
                if (!viewModel.isEditMode) _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileLogo(StartupProfileViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.isEditMode ? _pickLogo : null,
      child: Stack(
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: StartupOnboardingTheme.goldAccent, width: 2),
              boxShadow: [BoxShadow(color: StartupOnboardingTheme.goldAccent.withOpacity(0.2), blurRadius: 15, spreadRadius: 2)],
            ),
            child: ClipOval(
              child: viewModel.newLogoFile != null
                  ? Image.file(viewModel.newLogoFile!, fit: BoxFit.cover)
                  : Image.network(
                      viewModel.profile.logoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(LucideIcons.building, size: 40, color: Colors.white24),
                    ),
            ),
          ),
          if (viewModel.isEditMode)
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.black87, shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
                child: const Icon(LucideIcons.camera, color: Colors.white, size: 16),
              ),
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
          icon: const Icon(LucideIcons.edit3, size: 16),
          label: const Text('Chỉnh sửa'),
          style: ElevatedButton.styleFrom(
            backgroundColor: StartupOnboardingTheme.goldAccent,
            foregroundColor: StartupOnboardingTheme.navyBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const KycFormView(isIncorporated: true)));
          },
          icon: const Icon(LucideIcons.shieldCheck, size: 16),
          label: const Text('Xác thực'),
          style: OutlinedButton.styleFrom(
            foregroundColor: StartupOnboardingTheme.goldAccent,
            side: const BorderSide(color: StartupOnboardingTheme.goldAccent),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildViewMode(StartupProfileViewModel viewModel) {
    return Column(
      children: [
        ProfileSectionCard(
          title: 'THÔNG TIN CƠ BẢN',
          child: Column(
            children: [
              _buildInfoRow(LucideIcons.globe, 'Website', viewModel.profile.websiteLink),
              _buildInfoRow(LucideIcons.briefcase, 'Ngành nghề', viewModel.profile.industry),
              _buildInfoRow(LucideIcons.mapPin, 'Trụ sở', viewModel.profile.location, isLast: true),
            ],
          ),
        ),
        ProfileSectionCard(
          title: 'MÔ TẢ',
          child: Text(
            viewModel.profile.problemStatement.isEmpty ? 'Chưa có mô tả chi tiết.' : viewModel.profile.problemStatement,
            style: GoogleFonts.workSans(color: Colors.white70, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(StartupProfileViewModel viewModel) {
    return Column(
      children: [
        ProfileSectionCard(
          title: 'ĐỊNH DANH STARTUP',
          child: Column(
            children: [
              ProfileTextField(label: 'Tên Startup', controller: viewModel.nameController),
              ProfileTextField(label: 'Khẩu hiệu (Tagline)', controller: viewModel.taglineController),
              ProfileDropdownField(
                label: 'Giai đoạn',
                items: viewModel.stages,
                value: viewModel.selectedStage,
                onChanged: (v) => setState(() => viewModel.selectedStage = v),
              ),
              ProfileDropdownField(
                label: 'Ngành nghề',
                items: viewModel.industryList.map((i) => i.name).toList(),
                value: viewModel.selectedIndustryName,
                onChanged: (v) {
                  final ind = viewModel.industryList.firstWhere((i) => i.name == v);
                  setState(() {
                    viewModel.selectedIndustryName = v;
                    viewModel.selectedIndustryId = ind.id;
                  });
                },
              ),
              ProfileDropdownField(
                label: 'Trụ sở chính',
                items: viewModel.locations,
                value: viewModel.selectedLocation,
                onChanged: (v) => setState(() => viewModel.selectedLocation = v),
              ),
            ],
          ),
        ),
        ProfileSectionCard(
          title: 'LIÊN KẾT & CHI TIẾT',
          child: Column(
            children: [
              ProfileTextField(label: 'Website', controller: viewModel.websiteController, keyboardType: TextInputType.url),
              ProfileTextField(label: 'Mô tả chi tiết', controller: viewModel.problemController, maxLines: 5),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionCircle(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, color: Colors.white, size: 20), onPressed: onTap),
    );
  }

  Widget _buildCompactChip(String label, IconData icon, Color bgColor, Color textColor) {
    if (label.isEmpty || label == 'Chưa xác định' || label == 'Chưa cập nhật' || label == 'Idea') {
       // Filter out empty or placeholder data
       if (label == 'Idea' && icon == LucideIcons.rocket) return _buildRealChip(label, icon, bgColor, textColor);
       if (label.isEmpty || label == 'Chưa xác định' || label == 'Chưa cập nhật') return const SizedBox.shrink();
    }
    return _buildRealChip(label, icon, bgColor, textColor);
  }

  Widget _buildRealChip(String label, IconData icon, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: textColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        children: [
          Icon(icon, color: StartupOnboardingTheme.goldAccent, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.workSans(fontSize: 12, color: Colors.white38, fontWeight: FontWeight.bold)),
              Text(value.isEmpty ? 'Chưa cập nhật' : value, style: GoogleFonts.workSans(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
