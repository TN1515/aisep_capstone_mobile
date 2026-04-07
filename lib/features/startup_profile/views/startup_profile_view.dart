import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/startup_profile/view_models/startup_view_model.dart';
import 'package:aisep_capstone_mobile/features/startup_profile/models/startup_models.dart';
import 'package:aisep_capstone_mobile/features/startup_profile/views/create_startup_profile_view.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StartupProfileView extends StatefulWidget {
  const StartupProfileView({super.key});

  @override
  State<StartupProfileView> createState() => _StartupProfileViewState();
}

class _StartupProfileViewState extends State<StartupProfileView> {
  @override
  void initState() {
    super.initState();
    // MAPPING API: Tải thông tin hồ sơ ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StartupViewModel>().loadMyProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StartupViewModel>();
    final theme = Theme.of(context);

    if (viewModel.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!viewModel.hasProfile) {
       return const CreateStartupProfileView();
    }

    final profile = viewModel.profile!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(profile),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(profile),
                  const SizedBox(height: 32),
                  _buildDetailSection(profile),
                  const SizedBox(height: 32),
                  _buildTeamSection(viewModel),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Logic mở form edit (Update API)
        },
        icon: const Icon(LucideIcons.edit3),
        label: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: StartupOnboardingTheme.goldAccent,
      ),
    );
  }

  Widget _buildAppBar(StartupProfileDto profile) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (profile.logoUrl != null)
              Image.network(profile.logoUrl!, fit: BoxFit.cover)
            else
              Container(color: StartupOnboardingTheme.navySurface),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(StartupProfileDto profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                profile.companyName,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: StartupOnboardingTheme.softIvory,
                ),
              ),
            ),
            _buildStatusBadge(profile.profileStatus),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          profile.oneLiner,
          style: GoogleFonts.workSans(
            fontSize: 16,
            color: StartupOnboardingTheme.goldAccent,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(LucideIcons.mapPin, size: 16, color: Colors.white54),
            const SizedBox(width: 8),
            Text(profile.location ?? 'Chưa cập nhật địa điểm', style: const TextStyle(color: Colors.white54)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'Approved' ? Colors.greenAccent : StartupOnboardingTheme.goldAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailSection(StartupProfileDto profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thông tin chi tiết'),
        const SizedBox(height: 16),
        _buildInfoRow(LucideIcons.briefcase, 'Ngành nghề', profile.industryName ?? 'N/A'),
        _buildInfoRow(LucideIcons.trendingUp, 'Giai đoạn', profile.stage ?? 'N/A'),
        _buildInfoRow(LucideIcons.globe, 'Website', profile.website ?? 'N/A'),
        _buildInfoRow(LucideIcons.fileText, 'Mã số DN', profile.businessCode ?? 'Chưa cập nhật'),
        const SizedBox(height: 24),
        Text(
          'Mô tả',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          profile.description ?? 'Chưa có mô tả chi tiết.',
          style: GoogleFonts.workSans(color: Colors.white70, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildTeamSection(StartupViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Đội ngũ (Team)'),
            IconButton(
              icon: const Icon(LucideIcons.plusCircle, color: StartupOnboardingTheme.goldAccent),
              onPressed: () {
                // Logic thêm member mới
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (viewModel.teamMembers.isEmpty)
          const Text('Chưa có thành viên nào được thêm.', style: TextStyle(color: Colors.white54))
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.teamMembers.length,
              itemBuilder: (context, index) {
                final member = viewModel.teamMembers[index];
                return _buildMemberCard(member);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMemberCard(TeamMemberDto member) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: member.photoUrl != null ? NetworkImage(member.photoUrl!) : null,
            child: member.photoUrl == null ? const Icon(LucideIcons.user) : null,
          ),
          const SizedBox(height: 12),
          Text(
            member.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            member.role,
            style: const TextStyle(color: StartupOnboardingTheme.goldAccent, fontSize: 11),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: StartupOnboardingTheme.goldAccent,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white38),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(color: Colors.white38, fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
