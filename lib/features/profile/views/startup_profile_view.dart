import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
    _viewModel = context.read<StartupProfileViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.resetMode();
    });
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
                      const SizedBox(height: 24),
                      if (viewModel.isEditMode) _buildEditForm(viewModel) else _buildPreviewMode(viewModel),
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
        ],
      ),
      bottomNavigationBar: viewModel.isEditMode ? _buildStickyFooter(viewModel) : null,
    );
  }

  Widget _buildStickyFooter(StartupProfileViewModel viewModel) {
    return SafeArea(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => viewModel.toggleEditMode(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Hủy bỏ', style: GoogleFonts.workSans(
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                )),
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
                height: 180, width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Theme.of(context).cardColor, Theme.of(context).scaffoldBackgroundColor],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1558591710-4b4a1ae0f04d?auto=format&fit=crop&q=80&w=1000',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
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
                    _buildFloatingActionCircle(LucideIcons.crown, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MembershipUpgradeView()))),
                    const SizedBox(width: 12),
                    _buildFloatingActionCircle(LucideIcons.settings, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsView()))),
                  ],
                ),
              ),
              Positioned(bottom: -40, child: _buildProfileLogo(viewModel)),
            ],
          ),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Text(
                  profile.startupName, 
                  textAlign: TextAlign.center, 
                  style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.displayLarge?.color),
                ),
                const SizedBox(height: 6),
                Text(
                  profile.tagline, 
                  textAlign: TextAlign.center, 
                  style: GoogleFonts.workSans(fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7), fontWeight: FontWeight.w500)
                ),
                const SizedBox(height: 20),
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
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: StartupOnboardingTheme.goldAccent, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: ClipOval(
              child: viewModel.newLogoFile != null
                  ? Image.file(viewModel.newLogoFile!, fit: BoxFit.cover)
                  : Image.network(
                      viewModel.profile.logoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(LucideIcons.building, size: 36, color: Theme.of(context).dividerColor),
                    ),
            ),
          ),
          if (viewModel.isEditMode)
            Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: StartupOnboardingTheme.goldAccent, shape: BoxShape.circle), child: const Icon(LucideIcons.camera, color: StartupOnboardingTheme.navyBg, size: 14))),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _viewModel.toggleEditMode(),
            icon: const Icon(LucideIcons.edit3, size: 16),
            label: const Text('Chỉnh sửa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: StartupOnboardingTheme.goldAccent, 
              foregroundColor: StartupOnboardingTheme.navyBg,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KycFormView(isIncorporated: true))),
            icon: const Icon(LucideIcons.shieldCheck, size: 16),
            label: const Text('Xác thực KYC'),
            style: OutlinedButton.styleFrom(
              foregroundColor: StartupOnboardingTheme.goldAccent, 
              side: const BorderSide(color: StartupOnboardingTheme.goldAccent),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewMode(StartupProfileViewModel viewModel) {
    final theme = Theme.of(context);
    final p = viewModel.profile;
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      children: [
        _buildSectionHeader('TỔNG QUAN DOANH NGHIỆP'),
        ProfileSectionCard(
          title: 'Chi tiết Startup',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(LucideIcons.globe, 'Website', p.websiteLink),
              _buildInfoRow(LucideIcons.box, 'Lĩnh vực', p.industry),
              _buildInfoRow(LucideIcons.rocket, 'Giai đoạn', p.stage),
              _buildInfoRow(LucideIcons.calendar, 'Thành lập', p.foundedDate != null ? dateFormat.format(p.foundedDate!) : ''),
              _buildInfoRow(LucideIcons.mapPin, 'Địa điểm', '${p.location}, ${p.country}'),
              _buildInfoRow(LucideIcons.fileText, 'Mô tả', p.description.isEmpty ? 'Chưa có mô tả' : p.description, isLast: true),
            ],
          ),
        ),

        const SizedBox(height: 12),
        _buildSectionHeader('THÔNG TIN TÀI CHÍNH'),
        ProfileSectionCard(
          title: 'Số liệu đầu tư',
          child: Column(
            children: [
              _buildInfoRow(LucideIcons.trendingUp, 'Vốn mong muốn', currencyFormat.format(p.fundingAmountSought)),
              _buildInfoRow(LucideIcons.banknote, 'Vốn đã huy động', currencyFormat.format(p.currentFundingRaised)),
              _buildInfoRow(LucideIcons.pieChart, 'Định giá hiện tại', currencyFormat.format(p.valuation), isLast: true),
            ],
          ),
        ),

        const SizedBox(height: 12),
        _buildSectionHeader('LIÊN HỆ & HỆ THỐNG'),
        ProfileSectionCard(
          title: 'Người đại diện & Trạng thái',
          child: Column(
            children: [
              _buildInfoRow(LucideIcons.user, 'Họ tên', p.fullNameOfApplicant),
              _buildInfoRow(LucideIcons.mail, 'Email', p.contactEmail),
              _buildInfoRow(LucideIcons.shield, 'KYC Status', p.kycStatus),
              Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: Row(
                  children: [
                    const Icon(LucideIcons.eye, color: StartupOnboardingTheme.goldAccent, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hiển thị trên Marketplace', style: GoogleFonts.workSans(fontSize: 11, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5))),
                          Text(p.isVisible ? 'Đang công khai' : 'Đang ẩn', style: GoogleFonts.workSans(fontSize: 14, color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: p.isVisible,
                      activeColor: StartupOnboardingTheme.goldAccent,
                      onChanged: (val) => viewModel.toggleVisibility(val),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        _buildSectionHeader('ĐỘI NGŨ SÁNG LẬP'),
        _buildTeamList(viewModel),
      ],
    );
  }

  Widget _buildEditForm(StartupProfileViewModel vm) {
    return Column(
      children: [
        ProfileSectionCard(
          title: '1. THÔNG TIN CƠ BẢN',
          child: Column(
            children: [
              ProfileTextField(label: 'Tên Startup', controller: vm.nameController),
              ProfileTextField(label: 'Tagline', controller: vm.taglineController),
              ProfileTextField(label: 'Website', controller: vm.websiteController),
              ProfileTextField(label: 'Mô tả chi tiết', controller: vm.descriptionController, maxLines: 4),
            ],
          ),
        ),
        ProfileSectionCard(
          title: '2. LĨNH VỰC & GIAI ĐOẠN',
          child: Column(
            children: [
              ProfileDropdownField(label: 'Giai đoạn', items: vm.stages, value: vm.selectedStage, onChanged: (v) => setState(() => vm.selectedStage = v)),
              ProfileDropdownField(label: 'Lĩnh vực', items: vm.industryList.map((i) => i.name).toList(), value: vm.selectedIndustryName, onChanged: (v) {
                final ind = vm.industryList.firstWhere((i) => i.name == v);
                setState(() { vm.selectedIndustryName = v; vm.selectedIndustryId = ind.id; });
              }),
              ProfileTextField(label: 'Lĩnh vực chuyên sâu', controller: vm.subIndustryController),
              ProfileTextField(label: 'Vùng/Thành phố', controller: vm.locationController),
              ProfileTextField(label: 'Quốc gia', controller: vm.countryController),
            ],
          ),
        ),
        ProfileSectionCard(
          title: '3. THÔNG TIN TÀI CHÍNH (\$)',
          child: Column(
            children: [
              ProfileTextField(label: 'Vốn mong muốn', controller: vm.fundingSoughtController, keyboardType: TextInputType.number),
              ProfileTextField(label: 'Vốn đã huy động', controller: vm.fundingRaisedController, keyboardType: TextInputType.number),
              ProfileTextField(label: 'Doanh thu', controller: vm.revenueController, keyboardType: TextInputType.number),
              ProfileTextField(label: 'Định giá', controller: vm.valuationController, keyboardType: TextInputType.number),
            ],
          ),
        ),
        ProfileSectionCard(
          title: '4. THÔNG TIN LIÊN HỆ',
          child: Column(
            children: [
              ProfileTextField(label: 'Họ tên người đại diện', controller: vm.applicantNameController),
              ProfileTextField(label: 'Chức vụ', controller: vm.applicantRoleController),
              ProfileTextField(label: 'Email liên hệ', controller: vm.emailController, keyboardType: TextInputType.emailAddress),
              ProfileTextField(label: 'Số điện thoại', controller: vm.phoneController, keyboardType: TextInputType.phone),
              ProfileTextField(label: 'Link LinkedIn', controller: vm.linkedinController),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamList(StartupProfileViewModel vm) {
    if (vm.teamMembers.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: Text('Chưa có thông tin đội ngũ', style: TextStyle(color: Colors.white70))));
    return Column(
      children: vm.teamMembers.map((m) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: CircleAvatar(backgroundImage: m.photoUrl != null ? NetworkImage(m.photoUrl!) : null, child: m.photoUrl == null ? const Icon(LucideIcons.user) : null),
          title: Text(m.fullName, style: GoogleFonts.workSans(fontWeight: FontWeight.bold)),
          subtitle: Text(m.role, style: GoogleFonts.workSans(fontSize: 12)),
        ),
      )).toList(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Align(
        alignment: Alignment.centerLeft, 
        child: Text(title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.goldAccent, letterSpacing: 1.2))
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLast = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: StartupOnboardingTheme.goldAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: StartupOnboardingTheme.goldAccent, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.workSans(fontSize: 10, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(value.isEmpty ? 'Chưa cập nhật' : value, style: GoogleFonts.workSans(fontSize: 14, color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionCircle(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(color: Colors.black38, shape: BoxShape.circle, border: Border.all(color: Colors.white10)), 
      child: IconButton(icon: Icon(icon, color: Colors.white, size: 18), onPressed: onTap)
    );
  }
}
