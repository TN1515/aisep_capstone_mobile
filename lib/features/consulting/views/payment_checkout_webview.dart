import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/core/utils/toast_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentCheckoutWebView extends StatefulWidget {
  final String checkoutUrl;
  final int orderCode;

  const PaymentCheckoutWebView({
    Key? key,
    required this.checkoutUrl,
    required this.orderCode,
  }) : super(key: key);

  @override
  State<PaymentCheckoutWebView> createState() => _PaymentCheckoutWebViewState();
}

class _PaymentCheckoutWebViewState extends State<PaymentCheckoutWebView> with WidgetsBindingObserver {
  bool _isLaunched = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _launchPaymentUrl();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isLaunched) {
      // User returned from browser, trigger a refresh/check
      _verifyPayment();
    }
  }

  Future<void> _launchPaymentUrl() async {
    final uri = Uri.parse(widget.checkoutUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      setState(() => _isLaunched = true);
    } else {
      if (mounted) {
        ToastUtils.showTopToast(context, 'Không thể mở liên kết thanh toán');
        Navigator.pop(context);
      }
    }
  }

  Future<void> _verifyPayment() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    
    // In a real app, you would call an API to check the order status
    // For now, we refresh the mentorship list in the background
    await context.read<ConsultingViewModel>().fetchMentorships();
    
    if (mounted) {
      setState(() => _isChecking = false);
      // We don't necessarily know if it succeeded yet, but we show a hint
      ToastUtils.showTopToast(context, 'Đang cập nhật trạng thái thanh toán...');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? StartupOnboardingTheme.navyBg : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.x),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.creditCard,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Đang chuyển hướng...',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Vui lòng hoàn tất thanh toán tại trình duyệt web. Quay lại ứng dụng sau khi hoàn tất.',
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              if (_isChecking)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _launchPaymentUrl,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    minimumSize: const Size(200, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Mở lại trình duyệt',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
