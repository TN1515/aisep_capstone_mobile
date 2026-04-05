import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/membership_plan_model.dart';

class MembershipPaymentView extends StatefulWidget {
  final MembershipPlan plan;
  final VoidCallback onPaymentConfirmed;

  const MembershipPaymentView({
    super.key,
    required this.plan,
    required this.onPaymentConfirmed,
  });

  @override
  State<MembershipPaymentView> createState() => _MembershipPaymentViewState();
}

class _MembershipPaymentViewState extends State<MembershipPaymentView> {
  bool _isVerifying = false;

  @override
  Widget build(BuildContext context) {
    // Generate QR Content matching consulting style
    final String transactionContent = 'AISEP UPGRADE ${widget.plan.name}'.toUpperCase();
    final String qrUrl = 'https://qr.sepay.vn/img?bank=MBBank&acc=0000123456789&amount=${widget.plan.price.replaceAll('.', '')}&des=$transactionContent';

    return Scaffold(
      backgroundColor: StartupOnboardingTheme.navyBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Thanh toán nâng cấp'),
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
                border: Border.all(color: (widget.plan.accentColor ?? StartupOnboardingTheme.goldAccent).withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Text(
                    'Quét mã QR để thanh toán',
                    style: GoogleFonts.outfit(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: StartupOnboardingTheme.softIvory,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dịch vụ sẽ được kích hoạt ngay sau khi giao dịch thành công.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.workSans(
                      fontSize: 12, 
                      color: StartupOnboardingTheme.softIvory.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildQRImage(qrUrl),
                  const SizedBox(height: 32),
                  _buildDetailRow('Gói nâng cấp', widget.plan.name, isHighlight: true),
                  _buildDetailRow('Số tiền', '${widget.plan.price}đ', isAmount: true),
                  const Divider(color: Colors.white10, height: 32),
                  _buildDetailRow('Nội dung', transactionContent, canCopy: true),
                  _buildDetailRow('Ngân hàng', 'MB Bank (Quân Đội)'),
                  _buildDetailRow('Số tài khoản', '0000 1234 5678 9', canCopy: true),
                  _buildDetailRow('Chủ tài khoản', 'CÔNG TY CP AISEP VIỆT NAM'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSafetyInfo(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildQRImage(String url) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (widget.plan.accentColor ?? StartupOnboardingTheme.goldAccent).withOpacity(0.2), 
            blurRadius: 20, 
            spreadRadius: 5,
          ),
        ],
      ),
      child: Image.network(
        url,
        width: 200,
        height: 200,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(width: 200, height: 200, child: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAmount = false, bool isHighlight = false, bool canCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: GoogleFonts.workSans(
              color: StartupOnboardingTheme.softIvory.withOpacity(0.4), 
              fontSize: 13,
            ),
          ),
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
                      color: isAmount || isHighlight 
                          ? (widget.plan.accentColor ?? StartupOnboardingTheme.goldAccent) 
                          : StartupOnboardingTheme.softIvory,
                      fontWeight: FontWeight.bold,
                      fontSize: isAmount ? 18 : 13,
                    ),
                  ),
                ),
                if (canCopy)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(LucideIcons.copy, size: 14, color: widget.plan.accentColor ?? StartupOnboardingTheme.goldAccent),
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

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: ElevatedButton(
        onPressed: _isVerifying ? null : _handleVerify,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.plan.accentColor ?? StartupOnboardingTheme.goldAccent,
          foregroundColor: StartupOnboardingTheme.navyBg,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isVerifying 
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: StartupOnboardingTheme.navyBg, strokeWidth: 2))
          : Text('Xác nhận tôi đã chuyển khoản', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _handleVerify() async {
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isVerifying = false);
      widget.onPaymentConfirmed();
      Navigator.pop(context);
    }
  }
}
