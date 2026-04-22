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
import '../models/startup_models.dart';
import '../../kyc/views/kyc_form_view.dart';
import '../../settings/views/settings_view.dart';
import '../../membership/views/membership_upgrade_view.dart';
import '../../../../core/utils/ui_utils.dart';
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
      // Fallback: Nếu khởi động nhanh thất bại, màn hình này sẽ tự nạp lại dữ liệu
      if (!_viewModel.isInitialized) {
        _viewModel.loadProfile();
      }
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
    
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                _buildUnifiedHeader(viewModel),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      isScrollable: true,
                      indicatorPadding: const EdgeInsets.symmetric(horizontal: 4),
                      indicatorColor: StartupOnboardingTheme.goldAccent,
                      labelColor: StartupOnboardingTheme.goldAccent,
                      unselectedLabelColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                      labelStyle: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 13),
                      unselectedLabelStyle: GoogleFonts.workSans(fontWeight: FontWeight.w500, fontSize: 13),
                      tabs: const [
                        Tab(text: 'Tổng quan'),
                        Tab(text: 'Kinh doanh'),
                        Tab(text: 'Gọi vốn'),
                        Tab(text: 'Đội ngũ'),
                        Tab(text: 'Liên hệ'),
                      ],
                    ),
                    theme.scaffoldBackgroundColor,
                    MediaQuery.of(context).padding.top,
                  ),
                ),
              ],
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TabBarView(
                  children: [
                    _buildOverviewTab(viewModel),
                    _buildBusinessTab(viewModel),
                    _buildFundingTab(viewModel),
                    _buildTeamTab(viewModel),
                    _buildContactTab(viewModel),
                  ],
                ),
              ),
            ),
            // Loading indicator chỉ hiện một thanh nhỏ phía trên nếu đã có data (mượt mà hơn)
            if (viewModel.isLoading)
              Positioned(
                top: 0, left: 0, right: 0,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: StartupOnboardingTheme.goldAccent.withOpacity(0.5),
                  minHeight: 2,
                ),
              ),
          ],
        ),
        bottomNavigationBar: viewModel.isEditMode ? _buildStickyFooter(viewModel) : null,
      ),
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
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
                    _buildTagBadges(viewModel),
                    const SizedBox(height: 16),
                    if (!viewModel.isEditMode) _buildActionButtons(),
                  ],
                ),
              ),
            ],
          ),
          // Buttons positioned on the image part
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
          // Logo centered horizontally and positioned vertically overlapping image bottom
          Positioned(
            top: 135, // 180 - (90/2) = 135
            left: 0, right: 0,
            child: Center(child: _buildProfileLogo(viewModel)),
          ),
        ],
      ),
    );
  }

  Widget _buildTagBadges(StartupProfileViewModel viewModel) {
    final p = viewModel.profile;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBadge(LucideIcons.trendingUp, p.stage, const Color(0xFFE6F7ED), const Color(0xFF22C55E)),
          const SizedBox(width: 8),
          _buildBadge(LucideIcons.box, p.industry, const Color(0xFFEFF6FF), const Color(0xFF3B82F6)),
          const SizedBox(width: 8),
          _buildBadge(LucideIcons.globe, p.marketScope.isEmpty ? 'B2B' : p.marketScope, const Color(0xFFF5F3FF), const Color(0xFF8B5CF6)),
          const SizedBox(width: 8),
          _buildBadge(LucideIcons.checkCircle, 'Đã đăng ký DN', const Color(0xFFE6F7ED), const Color(0xFF22C55E)),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
        ],
      ),
    );
  }


  Widget _buildProfileLogo(StartupProfileViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.isEditMode ? _pickLogo : () => UIUtils.showImagePreview(
        context, 
        imageUrl: viewModel.profile.logoUrl, 
        imageFile: viewModel.newLogoFile,
        tag: 'profile_logo'
      ),
      child: Hero(
        tag: 'profile_logo',
        child: Stack(
          clipBehavior: Clip.none,
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
                    : (viewModel.profile.logoUrl.isNotEmpty 
                        ? Image.network(
                            UIUtils.getFullImageUrl(viewModel.profile.logoUrl)!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(LucideIcons.building, size: 36, color: Theme.of(context).dividerColor),
                          )
                        : Icon(LucideIcons.building, size: 36, color: Theme.of(context).dividerColor)),
              ),
            ),
            if (viewModel.isEditMode) ...[
              Positioned(
                bottom: 0, right: 0, 
                child: Container(
                  padding: const EdgeInsets.all(6), 
                  decoration: const BoxDecoration(color: StartupOnboardingTheme.goldAccent, shape: BoxShape.circle), 
                  child: const Icon(LucideIcons.camera, color: StartupOnboardingTheme.navyBg, size: 14)
                )
              ),
              if (viewModel.newLogoFile != null || viewModel.profile.logoUrl.isNotEmpty)
                Positioned(
                  top: -5, right: -5,
                  child: GestureDetector(
                    onTap: () => viewModel.removeLogo(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.x, color: Colors.white, size: 12),
                    ),
                  ),
                ),
            ],
          ],
        ),
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

  Widget _buildOverviewTab(StartupProfileViewModel viewModel) {
    if (viewModel.isEditMode) return _buildOverviewEdit(viewModel);
    
    final p = viewModel.profile;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildDetailCard(LucideIcons.alertCircle, 'Vấn đề', p.problemStatement, Colors.redAccent),
          _buildDetailCard(LucideIcons.lightbulb, 'Giải pháp', p.solutionSummary, Colors.amber),
          _buildDetailCard(LucideIcons.fileText, 'Mô tả chi tiết', p.description, StartupOnboardingTheme.slateGray),
          if (p.currentNeeds.isNotEmpty) _buildTagCard(LucideIcons.target, 'Nhu cầu hiện tại', p.currentNeeds),
          
          const SizedBox(height: 24),
          _buildSectionHeader('THÔNG TIN NHANH'),
          ProfileSectionCard(
            title: '',
            child: Column(
              children: [
                _buildInfoRow(LucideIcons.trendingUp, 'GIAI ĐOẠN', p.stage),
                _buildInfoRow(LucideIcons.box, 'NGÀNH', p.industry),
                _buildInfoRow(LucideIcons.globe, 'THỊ TRƯỜNG', p.marketScope),
                _buildInfoRow(LucideIcons.checkCircle, 'SẢN PHẨM', p.productStatus),
                _buildInfoRow(LucideIcons.calendar, 'THÀNH LẬP', p.foundedDate != null ? DateFormat('dd/MM/yyyy').format(p.foundedDate!) : 'Chưa cập nhật'),
                _buildInfoRow(LucideIcons.users, 'TEAM SIZE', p.teamSize),
                _buildInfoRow(LucideIcons.mapPin, 'ĐỊA ĐIỂM', '${p.location}, ${p.country}', isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildOverviewEdit(StartupProfileViewModel vm) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 16),
          ProfileSectionCard(
            title: 'THÔNG TIN CƠ BẢN',
            child: Column(
              children: [
                ProfileTextField(label: 'Tên Startup / Dự án *', controller: vm.nameController),
                ProfileTextField(label: 'Tagline / Khẩu hiệu *', controller: vm.taglineController),
                ProfileDropdownField(
                  label: 'Lĩnh vực chính (Industry) *', 
                  items: vm.industryList.map((i) => i.name).toList(), 
                  value: vm.selectedParentIndustry?.name, 
                  onChanged: (v) {
                    final parent = vm.industryList.firstWhere((i) => i.name == v);
                    vm.onParentIndustryChanged(parent);
                  }
                ),
                if (vm.subIndustryList.isNotEmpty)
                  ProfileDropdownField(
                    label: ' Lĩnh vực phụ (Sub-Industry) *', 
                    items: vm.subIndustryList.map((i) => i.name).toList(), 
                    value: vm.selectedIndustryName, 
                    onChanged: (v) {
                      final sub = vm.subIndustryList.firstWhere((i) => i.name == v);
                      vm.onSubIndustryChanged(sub.id, sub.name);
                    }
                  ),
                ProfileTextField(label: 'Mô tả thêm lĩnh vực (Tùy chọn)', controller: vm.subIndustryController),
                ProfileDropdownField(
                  label: 'Giai đoạn phát triển *', 
                  items: vm.stages, 
                  value: vm.selectedStage, 
                  onChanged: (v) => setState(() => vm.selectedStage = v)
                ),
                ProfileTextField(label: 'Quy mô nhân sự (Team Size)', controller: vm.teamSizeController, keyboardType: TextInputType.number),
              ],
            ),
          ),
          ProfileSectionCard(
            title: 'NGƯỜI ĐĂNG KÝ & PHÁP LÝ',
            child: Column(
              children: [
                ProfileTextField(label: 'Họ tên người đăng ký *', controller: vm.applicantNameController),
                ProfileTextField(label: 'Vai trò đăng ký *', controller: vm.applicantRoleController),
                ProfileTextField(label: 'Email liên hệ *', controller: vm.emailController, keyboardType: TextInputType.emailAddress),
                _buildBusinessCodeField(vm),
              ],
            ),
          ),
          ProfileSectionCard(
            title: 'MÔ TẢ & NHU CẦU',
            child: Column(
              children: [
                ProfileTextField(label: 'Mô tả công ty (Description)', controller: vm.descriptionController, maxLines: 5),
                const SizedBox(height: 16),
                _buildTagInputLabel(),
                TagInputField(
                  tags: vm.profile.currentNeeds,
                  onAdd: (tag) => vm.addNeed(tag),
                  onRemove: (index) => vm.removeNeed(index),
                ),
                const SizedBox(height: 16),
                ProfileTextField(label: 'Lực kéo tóm tắt (Traction / Metrics)', controller: vm.tractionIndexController, maxLines: 3),
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildBusinessTab(StartupProfileViewModel viewModel) {
    if (viewModel.isEditMode) return _buildBusinessEdit(viewModel);
    
    final p = viewModel.profile;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildDetailCard(LucideIcons.briefcase, 'Chiến lược kinh doanh', 'VẤN ĐỀ\n${p.problemStatement.isEmpty ? "Chưa cập nhật" : p.problemStatement}\n\nGIẢI PHÁP\n${p.solutionSummary.isEmpty ? "Chưa cập nhật" : p.solutionSummary}', StartupOnboardingTheme.goldAccent),
          
          const SizedBox(height: 24),
          _buildSectionHeader('THI TRƯỜNG'),
          ProfileSectionCard(
            title: '',
            child: Column(
              children: [
                _buildInfoRow(LucideIcons.globe, 'PHẠM VI THỊ TRƯỜNG', p.marketScope),
                _buildInfoRow(LucideIcons.rocket, 'TRẠNG THÁI SẢN PHẨM', p.productStatus, isLast: true),
              ],
            ),
          ),
          
          if (p.currentNeeds.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildTagCard(LucideIcons.target, 'Nhu cầu hiện tại', p.currentNeeds),
          ],
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildBusinessEdit(StartupProfileViewModel vm) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 16),
          ProfileSectionCard(
            title: 'CHIẾN LƯỢC KINH DOANH',
            child: Column(
              children: [
                ProfileTextField(label: 'Vấn đề cốt lõi (Problem)', controller: vm.problemController, maxLines: 4),
                ProfileTextField(label: 'Giải pháp (Solution)', controller: vm.solutionController, maxLines: 4),
              ],
            ),
          ),
          ProfileSectionCard(
            title: 'THỊ TRƯỜNG & SẢN PHẨM',
            child: Column(
              children: [
                ProfileDropdownField(
                  label: 'Thị trường mục tiêu (Market Scope)', 
                  items: vm.marketScopeOptions, 
                  value: vm.marketScopeOptions.contains(vm.marketScopeController.text) ? vm.marketScopeController.text : vm.marketScopeOptions.first, 
                  onChanged: (v) => setState(() => vm.marketScopeController.text = v!)
                ),
                ProfileDropdownField(
                  label: 'Trạng thái sản phẩm (Product Status)', 
                  items: vm.productStatusOptions, 
                  value: vm.productStatusOptions.contains(vm.productStatusController.text) ? vm.productStatusController.text : vm.productStatusOptions.first, 
                  onChanged: (v) => setState(() => vm.productStatusController.text = v!)
                ),
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildFundingTab(StartupProfileViewModel viewModel) {
    if (viewModel.isEditMode) return _buildFundingEdit(viewModel);
    
    final p = viewModel.profile;
    final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    double progress = 0;
    if (p.fundingAmountSought > 0) {
      progress = p.currentFundingRaised / p.fundingAmountSought;
    }
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildMetricCard(LucideIcons.trendingUp, 'GIAI ĐOẠN GỌI VỐN', p.stage, 'Vòng hiện tại'),
          const SizedBox(height: 12),
          _buildMetricCard(LucideIcons.dollarSign, 'SỐ VỐN CẦN', currency.format(p.fundingAmountSought), 'USD'),
          const SizedBox(height: 12),
          _buildMetricCard(LucideIcons.checkCircle, 'ĐÃ HUY ĐỘNG', currency.format(p.currentFundingRaised), '${(progress * 100).toInt()}% mục tiêu'),
          
          const SizedBox(height: 24),
          _buildSectionHeader('TIẾN ĐỘ HUY ĐỘNG VỐN'),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05))),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(value: progress.clamp(0.0, 1.0), minHeight: 12, backgroundColor: Colors.black12, color: StartupOnboardingTheme.goldAccent),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${currency.format(p.currentFundingRaised)} đã huy động', 
                        style: GoogleFonts.workSans(fontSize: 12, color: StartupOnboardingTheme.slateGray),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mục tiêu ${currency.format(p.fundingAmountSought)}', 
                        style: GoogleFonts.workSans(fontSize: 12, color: StartupOnboardingTheme.slateGray),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildFundingEdit(StartupProfileViewModel vm) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 16),
          ProfileSectionCard(
            title: 'THÔNG TIN GỌI VỐN (\$ USD)',
            child: Column(
              children: [
                ProfileTextField(label: 'Mục tiêu gọi vốn (\$ USD)', controller: vm.fundingSoughtController, keyboardType: TextInputType.number),
                ProfileTextField(label: 'Đã huy động được (\$ USD)', controller: vm.fundingRaisedController, keyboardType: TextInputType.number),
                ProfileTextField(label: 'Định giá công ty dự kiến (\$ USD)', controller: vm.valuationController, keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                Text(
                  'Chi dành cho các dự án đã ước tính được Valuation Post-Money/Pre-Money rõ ràng.',
                  style: GoogleFonts.workSans(fontSize: 11, color: StartupOnboardingTheme.slateGray, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildTeamTab(StartupProfileViewModel viewModel) {
    final p = viewModel.profile;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 16),
          if (viewModel.isEditMode) 
            _buildSectionHeaderWithAction('ĐỘI NGŨ SÁNG LẬP & NHÂN SỰ CHỦ CHỐT', 'Thêm thành viên', () => _showMemberForm(viewModel)),
          if (!viewModel.isEditMode)
            _buildSectionHeader('THÀNH VIÊN CỐT CÁN'),
            
          _buildTeamList(viewModel),
          
          if (!viewModel.isEditMode) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('CHỈ SỐ TRACTION'),
            _buildDetailCard(LucideIcons.lineChart, 'Traction Index', p.tractionIndex, Colors.blueAccent),
            
            const SizedBox(height: 24),
            _buildSectionHeader('PHÁP LÝ & XÁC THỰC'),
            ProfileSectionCard(
              title: '',
              child: Column(
                children: [
                  _buildInfoRow(LucideIcons.shieldCheck, 'TRẠNG THÁI', p.kycStatus, iconColor: Colors.green),
                  _buildInfoRow(LucideIcons.calendarCheck, 'NGÀY DUYỆT', p.approvedAt != null ? DateFormat('HH:mm dd/MM/yyyy').format(p.approvedAt!) : 'Chưa xác thực', isLast: true),
                ],
              ),
            ),
          ],
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildContactTab(StartupProfileViewModel viewModel) {
    if (viewModel.isEditMode) return _buildContactEdit(viewModel);
    
    final p = viewModel.profile;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader('LIÊN HỆ TRỰC TIẾP'),
          ProfileSectionCard(
            title: '',
            child: Column(
              children: [
                _buildInfoRow(LucideIcons.mail, 'EMAIL', p.contactEmail),
                _buildInfoRow(LucideIcons.phone, 'ĐIỆN THOẠI', p.phoneNumber),
                _buildInfoRow(LucideIcons.mapPin, 'ĐỊA CHỈ', '${p.location}, ${p.country}', isLast: true),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('LIÊN KẾT NGOÀI'),
          ProfileSectionCard(
            title: '',
            child: Column(
              children: [
                _buildInfoRow(LucideIcons.globe, 'WEBSITE', p.websiteLink),
                _buildInfoRow(LucideIcons.linkedin, 'LINKEDIN', p.linkedInUrl, isLast: true),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('HỆ THỐNG'),
          ProfileSectionCard(
            title: '',
            child: Column(
              children: [
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
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildContactEdit(StartupProfileViewModel vm) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 16),
          ProfileSectionCard(
            title: 'LIÊN KẾT & ĐỊA CHỈ',
            child: Column(
              children: [
                ProfileTextField(label: 'Website dự án', controller: vm.websiteController),
                ProfileTextField(label: 'Trang LinkedIn', controller: vm.linkedinController),
                ProfileTextField(label: 'Email liên hệ đại diện', controller: vm.emailController),
                ProfileTextField(label: 'Hotline liên hệ (tùy chọn)', controller: vm.phoneController),
                ProfileTextField(label: 'Tỉnh / Thành phố (Location)', controller: vm.locationController),
                ProfileTextField(label: 'Quốc gia (Country)', controller: vm.countryController),
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildTagInputLabel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nhu cầu tìm kiếm hiện tại (Current Needs)', style: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
        const SizedBox(height: 4),
        Text('Hiển thị dạng hiệu hiệu (badge) cho nhà đầu tư dễ nắm bắt.', style: GoogleFonts.workSans(fontSize: 11, color: StartupOnboardingTheme.slateGray)),
        Text('Nhập xong mỗi nhu cầu, hãy ấn Enter để thêm!', style: GoogleFonts.workSans(fontSize: 11, color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSectionHeaderWithAction(String title, String buttonText, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.goldAccent, letterSpacing: 1.2))),
          ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(LucideIcons.plus, size: 14),
            label: Text(buttonText, style: const TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: StartupOnboardingTheme.navyBg, 
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCodeField(StartupProfileViewModel vm) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mã số Doanh nghiệp', style: GoogleFonts.workSans(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Theme.of(context).dividerColor.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1))),
            child: Row(
              children: [
                Icon(vm.profile.businessCode.isNotEmpty ? LucideIcons.fileText : LucideIcons.shieldAlert, size: 16, color: StartupOnboardingTheme.slateGray),
                const SizedBox(width: 12),
                Expanded(child: Text(vm.profile.businessCode.isNotEmpty ? vm.profile.businessCode : 'Chưa xác minh', style: GoogleFonts.workSans(fontSize: 14, color: vm.profile.businessCode.isNotEmpty ? Theme.of(context).textTheme.bodyLarge?.color : StartupOnboardingTheme.slateGray, fontWeight: vm.profile.businessCode.isNotEmpty ? FontWeight.w600 : FontWeight.normal))),
                if (vm.profile.businessCode.isEmpty)
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KycFormView(isIncorporated: true))),
                    child: Text('Hoàn thiện KYC', style: GoogleFonts.workSans(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(LucideIcons.checkCircle, size: 14, color: Colors.green),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String title, String content, Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.displayLarge?.color)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content.isEmpty ? 'Chưa cập nhật' : content,
            style: GoogleFonts.workSans(fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTagCard(IconData icon, String title, List<String> tags) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: StartupOnboardingTheme.goldAccent),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: tags.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: StartupOnboardingTheme.goldAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.2))),
              child: Text(t, style: GoogleFonts.workSans(fontSize: 12, fontWeight: FontWeight.w500, color: StartupOnboardingTheme.goldAccent)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(IconData icon, String label, String value, String subLabel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: StartupOnboardingTheme.goldAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: StartupOnboardingTheme.goldAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.slateGray, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          if (subLabel.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(6)),
              child: Text(subLabel, style: GoogleFonts.workSans(fontSize: 12, color: StartupOnboardingTheme.slateGray, fontWeight: FontWeight.w500)),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildTeamList(StartupProfileViewModel vm) {
    if (vm.teamMembers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('Chưa có thông tin đội ngũ', style: TextStyle(color: Colors.white70))),
      );
    }
    return Column(
      children: vm.teamMembers.map((m) => _buildTeamMemberCard(vm, m)).toList(),
    );
  }

  Widget _buildTeamMemberCard(StartupProfileViewModel vm, TeamMemberDto m) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => UIUtils.showImagePreview(context, imageUrl: m.photoUrl, tag: 'member_${m.id}'),
                  child: Hero(
                    tag: 'member_${m.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: (m.photoUrl != null && m.photoUrl!.isNotEmpty)
                        ? Image.network(UIUtils.getFullImageUrl(m.photoUrl!)!, width: 70, height: 70, fit: BoxFit.cover)
                        : Container(
                            width: 70, height: 70,
                            color: theme.dividerColor.withOpacity(0.1),
                            child: Icon(LucideIcons.user, color: theme.dividerColor.withOpacity(0.3), size: 30),
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              m.fullName,
                              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.displayLarge?.color),
                            ),
                          ),
                          if (m.isFounder)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: StartupOnboardingTheme.goldAccent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(LucideIcons.star, size: 10, color: StartupOnboardingTheme.goldAccent),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Founder',
                                    style: GoogleFonts.workSans(fontSize: 10, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.goldAccent),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(LucideIcons.briefcase, size: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                          const SizedBox(width: 6),
                          Text(
                            m.title ?? m.role,
                            style: GoogleFonts.workSans(fontSize: 13, color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
                          ),
                          if (m.title != null && m.title!.isNotEmpty) ...[
                            Container(width: 3, height: 3, margin: const EdgeInsets.symmetric(horizontal: 8), decoration: BoxDecoration(color: theme.dividerColor, shape: BoxShape.circle)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: theme.dividerColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(m.role, style: GoogleFonts.workSans(fontSize: 10, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9), fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(LucideIcons.clock, size: 12, color: StartupOnboardingTheme.goldAccent.withOpacity(0.6)),
                          const SizedBox(width: 6),
                          Text(
                            '${m.experienceYears ?? 0} năm KN',
                            style: GoogleFonts.workSans(fontSize: 12, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (m.bio != null && m.bio!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                m.bio!,
                style: GoogleFonts.workSans(fontSize: 13, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                if (m.linkedInUrl != null && m.linkedInUrl!.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.linkedin, size: 14),
                    label: const Text('LinkedIn'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.dividerColor.withOpacity(0.05),
                      foregroundColor: theme.textTheme.bodyLarge?.color,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), 
                        side: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                      ),
                    ),
                  ),
                const Spacer(),
                if (vm.isEditMode) ...[
                  IconButton(
                    icon: Icon(LucideIcons.edit3, size: 18, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4)),
                    onPressed: () {
                      vm.setMemberForm(m);
                      _showMemberForm(vm, id: m.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.redAccent),
                    onPressed: () => _confirmDeleteMember(vm, m),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMemberForm(StartupProfileViewModel vm, {int? id}) {
    if (id == null) vm.clearMemberForm();
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            id == null ? 'Thêm thành viên mới' : 'Chỉnh sửa thành viên',
                            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textTheme.displayLarge?.color),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Điền thông tin thành viên dự án',
                            style: GoogleFonts.workSans(fontSize: 13, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(LucideIcons.x, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(color: theme.dividerColor.withOpacity(0.1)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar Section
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 100, height: 100,
                                decoration: BoxDecoration(
                                  color: theme.dividerColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: vm.memberPhotoFile != null
                                    ? Image.file(vm.memberPhotoFile!, fit: BoxFit.cover)
                                    : Icon(LucideIcons.user, color: theme.dividerColor.withOpacity(0.2), size: 40),
                                ),
                              ),
                              Positioned(
                                bottom: -5, right: -5,
                                child: GestureDetector(
                                  onTap: () async {
                                    final picker = ImagePicker();
                                    final picked = await picker.pickImage(source: ImageSource.gallery);
                                    if (picked != null) {
                                      vm.setMemberPhoto(File(picked.path));
                                      setModalState(() {});
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: StartupOnboardingTheme.goldAccent, shape: BoxShape.circle, border: Border.all(color: theme.scaffoldBackgroundColor, width: 2)),
                                    child: const Icon(LucideIcons.camera, color: StartupOnboardingTheme.navyBg, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        _buildFormLabel('THÔNG TIN CƠ BẢN'),
                        ProfileTextField(
                          label: 'Họ & Tên',
                          hint: 'Nguyễn Văn A',
                          controller: vm.teamMemberNameController,
                          icon: LucideIcons.user,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ProfileTextField(
                                label: 'Chức danh',
                                hint: 'CEO & Founder',
                                controller: vm.teamMemberTitleController,
                                icon: LucideIcons.briefcase,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ProfileTextField(
                                label: 'H.thức tham gia',
                                hint: 'Full-time',
                                controller: vm.teamMemberRoleController,
                                icon: LucideIcons.userCheck,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ProfileTextField(
                          label: 'Số năm kinh nghiệm',
                          hint: '5',
                          controller: vm.teamMemberExpController,
                          icon: LucideIcons.trendingUp,
                          keyboardType: TextInputType.number,
                        ),
                        
                        const SizedBox(height: 32),
                        _buildFormLabel('GIỚI THIỆU'),
                        ProfileTextField(
                          label: 'Tiểu sử ngắn',
                          hint: 'Tóm tắt ngắn gọn năng lực và đóng góp...',
                          controller: vm.teamMemberBioController,
                          maxLines: 4,
                        ),
                        
                        const SizedBox(height: 32),
                        _buildFormLabel('LIÊN KẾT & VAI TRÒ'),
                        ProfileTextField(
                          label: 'LinkedIn URL',
                          hint: 'https://linkedin.com/in/...',
                          controller: vm.teamMemberLinkedInController,
                          icon: LucideIcons.linkedin,
                        ),
                        const SizedBox(height: 12),
                        _buildFounderToggle(vm, setModalState),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                // Footer Actions
                Container(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.of(context).padding.bottom),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text('Hủy', style: GoogleFonts.outfit(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7))),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            final success = id == null ? await vm.addMember() : await vm.updateMember(id);
                            if (success && mounted) Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: StartupOnboardingTheme.goldAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: vm.isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: StartupOnboardingTheme.navyBg))
                            : Text(id == null ? 'Thêm thành viên' : 'Lưu thay đổi', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: StartupOnboardingTheme.navyBg)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        label,
        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent.withOpacity(0.8), letterSpacing: 1),
      ),
    );
  }


  Widget _buildFounderToggle(StartupProfileViewModel vm, Function setModalState) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        vm.isFounderMember = !vm.isFounderMember;
        setModalState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: vm.isFounderMember ? StartupOnboardingTheme.goldAccent.withOpacity(0.05) : theme.dividerColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: vm.isFounderMember ? StartupOnboardingTheme.goldAccent.withOpacity(0.3) : theme.dividerColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Checkbox(
              value: vm.isFounderMember,
              activeColor: StartupOnboardingTheme.goldAccent,
              onChanged: (val) {
                vm.isFounderMember = val ?? false;
                setModalState(() {});
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Là Co-founder sáng lập dự án', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
                  const SizedBox(height: 4),
                  Text('Thành viên này là một trong những người lập startup', style: GoogleFonts.workSans(fontSize: 11, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteMember(StartupProfileViewModel vm, TeamMemberDto m) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: StartupOnboardingTheme.navyBg,
        title: Text('Xác nhận xóa', style: GoogleFonts.outfit(color: Colors.white)),
        content: Text('Bạn có chắc chắn muốn xóa thành viên ${m.fullName}?', style: GoogleFonts.workSans(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await vm.deleteMember(m.id);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
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

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLast = false, Color? iconColor}) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: (iconColor ?? StartupOnboardingTheme.goldAccent).withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor ?? StartupOnboardingTheme.goldAccent, size: 16),
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this._backgroundColor, this.topPadding);

  final TabBar _tabBar;
  final Color _backgroundColor;
  final double topPadding;

  @override
  double get minExtent => _tabBar.preferredSize.height + topPadding;
  @override
  double get maxExtent => _tabBar.preferredSize.height + topPadding;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: EdgeInsets.only(top: topPadding),
      decoration: BoxDecoration(
        color: _backgroundColor,
        boxShadow: overlapsContent || shrinkOffset > 0 ? [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ] : null,
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding || oldDelegate._tabBar != _tabBar;
  }
}

class TagInputField extends StatefulWidget {
  final List<String> tags;
  final Function(String) onAdd;
  final Function(int) onRemove;

  const TagInputField({
    super.key,
    required this.tags,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onAdd(_controller.text.trim());
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey(widget.tags.length), // Rebuild container with new height key to avoid jump
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              key: const PageStorageKey('tags_wrap'),
              spacing: 8,
              runSpacing: 8,
              children: List.generate(widget.tags.length, (index) {
                return Chip(
                  key: ValueKey('tag_$index'),
                  label: Text(widget.tags[index], style: GoogleFonts.workSans(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                  backgroundColor: StartupOnboardingTheme.navyBg,
                  deleteIcon: const Icon(LucideIcons.x, size: 14, color: Colors.white),
                  onDeleted: () => widget.onRemove(index),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                );
              }),
            ),
          ),
        TextField(
          controller: _controller,
          onSubmitted: (_) => _submit(),
          style: GoogleFonts.workSans(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Thêm nhu cầu & Enter...',
            hintStyle: GoogleFonts.workSans(fontSize: 14, color: StartupOnboardingTheme.slateGray.withOpacity(0.5)),
            filled: true,
            fillColor: Theme.of(context).dividerColor.withOpacity(0.05),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffixIcon: IconButton(
              icon: const Icon(LucideIcons.plusCircle, color: StartupOnboardingTheme.goldAccent),
              onPressed: _submit,
            ),
          ),
        ),
      ],
    );
  }
}
