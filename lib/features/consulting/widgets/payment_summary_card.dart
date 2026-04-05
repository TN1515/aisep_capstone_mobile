import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class PaymentSummaryCard extends StatelessWidget {
  final double amount;
  final String? txHash;
  final DateTime? paymentDate;
  final String status;

  const PaymentSummaryCard({
    Key? key,
    required this.amount,
    this.txHash,
    this.paymentDate,
    this.status = 'Thành công',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.1)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            StartupOnboardingTheme.navySurface,
            StartupOnboardingTheme.navySurface.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng thanh toán',
                style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory.withOpacity(0.5)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.workSans(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(amount),
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: StartupOnboardingTheme.goldAccent,
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow(LucideIcons.hash, 'Mã giao dịch', txHash ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(LucideIcons.calendar, 'Thời gian', paymentDate != null ? dateFormat.format(paymentDate!) : 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(LucideIcons.shieldCheck, 'Phương thức', 'Thanh toán SEPAY (QR)'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: StartupOnboardingTheme.softIvory.withOpacity(0.3)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.workSans(fontSize: 12, color: StartupOnboardingTheme.softIvory.withOpacity(0.5)),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: StartupOnboardingTheme.softIvory,
          ),
        ),
      ],
    );
  }
}
