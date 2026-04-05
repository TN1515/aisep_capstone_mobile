import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/consulting_session_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/core/utils/toast_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PaymentCheckoutView extends StatefulWidget {
  final ConsultingSessionModel session;

  const PaymentCheckoutView({Key? key, required this.session}) : super(key: key);

  @override
  State<PaymentCheckoutView> createState() => _PaymentCheckoutViewState();
}

class _PaymentCheckoutViewState extends State<PaymentCheckoutView> {
  bool _isChecking = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final String shortId = widget.session.id.length > 8 ? widget.session.id.substring(0, 8) : widget.session.id;
    final String transactionContent = 'AISEP $shortId'.toUpperCase();
    final String qrUrl = 'https://qr.sepay.vn/img?bank=MBBank&acc=0000123456789&amount=${widget.session.amount.toInt()}&des=$transactionContent';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: StartupOnboardingTheme.navyBg,
        appBar: AppBar(
          backgroundColor: StartupOnboardingTheme.navyBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Thanh toán',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: StartupOnboardingTheme.softIvory,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: StartupOnboardingTheme.navySurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Quét mã QR để thanh toán',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.softIvory),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hệ thống sẽ tự động xác nhận sau khi nhận được tiền.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.workSans(fontSize: 12, color: StartupOnboardingTheme.softIvory.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 32),
                    _buildQRImage(qrUrl),
                    const SizedBox(height: 32),
                    _buildPaymentDetail(context, 'Số tiền', currencyFormat.format(widget.session.amount), isAmount: true),
                    const Divider(color: Colors.white10, height: 32),
                    _buildPaymentDetail(context, 'Nội dung chuyển khoản', transactionContent, canCopy: true),
                    _buildPaymentDetail(context, 'Ngân hàng', 'MB Bank (Quân Đội)'),
                    _buildPaymentDetail(context, 'Số tài khoản', '0000 1234 5678 9', canCopy: true),
                    _buildPaymentDetail(context, 'Chủ tài khoản', 'CÔNG TY CP AISEP VIỆT NAM'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSafetyInfo(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomButton(context),
      ),
    );
  }

  Widget _buildQRImage(String url) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: StartupOnboardingTheme.goldAccent.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Image.network(
        url,
        width: 220,
        height: 220,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(width: 220, height: 220, child: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }

  Widget _buildPaymentDetail(BuildContext context, String label, String value, {bool isAmount = false, bool canCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory.withOpacity(0.4), fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.workSans(
                      color: isAmount ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.softIvory,
                      fontWeight: FontWeight.bold,
                      fontSize: isAmount ? 18 : 13,
                    ),
                  ),
                ),
                if (canCopy)
                  IconButton(
                    icon: const Icon(LucideIcons.copy, size: 14, color: StartupOnboardingTheme.goldAccent),
                    onPressed: () {
                      ToastUtils.showTopToast(context, 'Đã sao chép vào bộ nhớ tạm.');
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.shieldCheck, size: 14, color: StartupOnboardingTheme.softIvory.withOpacity(0.3)),
        const SizedBox(width: 8),
        Text(
          'Thanh toán an toàn qua cổng SEPAY',
          style: GoogleFonts.workSans(fontSize: 11, color: StartupOnboardingTheme.softIvory.withOpacity(0.3)),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: ElevatedButton(
        onPressed: _isChecking ? null : _verifyPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: StartupOnboardingTheme.goldAccent,
          foregroundColor: StartupOnboardingTheme.navyBg,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isChecking 
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: StartupOnboardingTheme.navyBg, strokeWidth: 2))
          : Text('Xác nhận tôi đã chuyển khoản', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _verifyPayment() async {
    setState(() => _isChecking = true);
    
    // Simulate SEPAY verification
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      final String shortId = widget.session.id.length > 8 ? widget.session.id.substring(0, 8) : widget.session.id;
      await context.read<ConsultingViewModel>().processPayment(widget.session.id, 'SEPAY-$shortId'.toUpperCase());
      
      if (mounted) {
        setState(() => _isChecking = false);
        ToastUtils.showTopToast(context, 'Thanh toán thành công!');
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }
  }
}
