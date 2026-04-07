import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../view_models/kyc_view_model.dart';

class KycStatusView extends StatefulWidget {
  const KycStatusView({super.key});

  @override
  State<KycStatusView> createState() => _KycStatusViewState();
}

class _KycStatusViewState extends State<KycStatusView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KycViewModel>().loadStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<KycViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Trạng thái xác thực'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _buildBody(context, viewModel),
      ),
    );
  }

  Widget _buildBody(BuildContext context, KycViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator(color: StartupOnboardingTheme.goldAccent));
    }

    if (viewModel.errorMessage != null) {
      return _buildErrorState(context, viewModel);
    }

    switch (viewModel.status) {
      case KycStatus.none:
        return _buildNotSubmittedState(context);
      case KycStatus.pending:
        return _buildPendingState(context);
      case KycStatus.rejected:
        return _buildRejectedState(context, viewModel.rejectionReason);
      case KycStatus.verified:
        return _buildApprovedState(context);
      default:
        return _buildNotSubmittedState(context);
    }
  }

  Widget _buildNotSubmittedState(BuildContext context) {
    return _StatusContent(
      icon: Icons.assignment_late_outlined,
      title: 'Chưa có hồ sơ',
      description: 'Hồ sơ doanh nghiệp của bạn chưa được gửi xác thực. Hãy bắt đầu ngay để tiếp cận các nhà đầu tư.',
      buttonLabel: 'Bắt đầu xác thực ngay',
      onPressed: () {
        Navigator.of(context).pushNamed('/kyc-intro');
      },
    );
  }

  Widget _buildPendingState(BuildContext context) {
    return const _StatusContent(
      icon: Icons.hourglass_top_rounded,
      title: 'Đang xét duyệt hồ sơ',
      description: 'Hồ sơ của bạn đang được các chuyên gia AISEP đánh giá. Quy trình này thường mất từ 1-3 ngày làm việc.',
      isReadOnly: true,
    );
  }

  Widget _buildRejectedState(BuildContext context, String? reason) {
    return _StatusContent(
      icon: Icons.error_outline_rounded,
      iconColor: Colors.redAccent,
      title: 'Hồ sơ bị từ chối',
      description: 'Rất tiếc, hồ sơ của bạn chưa đạt yêu cầu.\n\nLý do: ${reason ?? "Thông tin chưa rõ ràng"}',
      buttonLabel: 'Chỉnh sửa lại hồ sơ',
      onPressed: () {
        Navigator.of(context).pushNamed('/kyc-form');
      },
    );
  }

  Widget _buildApprovedState(BuildContext context) {
    return _StatusContent(
      icon: Icons.check_circle_outline_rounded,
      iconColor: Colors.greenAccent,
      title: 'Đã xác thực thành công',
      description: 'Chúc mừng! Doanh nghiệp của bạn đã được xác thực chính thức trên nền tảng AISEP.',
      buttonLabel: 'Quay lại Trang chủ',
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildErrorState(BuildContext context, KycViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(viewModel.errorMessage ?? 'Có lỗi xảy ra'),
          ElevatedButton(
            onPressed: () => viewModel.loadStatus(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _StatusContent extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String description;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final bool isReadOnly;

  const _StatusContent({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.description,
    this.buttonLabel,
    this.onPressed,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: (iconColor ?? StartupOnboardingTheme.goldAccent).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 80, color: iconColor ?? StartupOnboardingTheme.goldAccent),
            ),
          ),
          const SizedBox(height: 48),
          FadeInUp(
            child: Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26)),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(description, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const Spacer(),
          if (!isReadOnly && buttonLabel != null)
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  child: Text(buttonLabel!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
