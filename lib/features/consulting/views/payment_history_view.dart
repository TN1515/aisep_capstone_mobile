import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/widgets/payment_summary_card.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/consulting_session_model.dart';

class PaymentHistoryView extends StatelessWidget {
  const PaymentHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StartupOnboardingTheme.navyBg,
      appBar: AppBar(
        backgroundColor: StartupOnboardingTheme.navyBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: StartupOnboardingTheme.softIvory),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lịch sử thanh toán',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: StartupOnboardingTheme.softIvory,
          ),
        ),
      ),
      body: Consumer<ConsultingViewModel>(
        builder: (context, viewModel, child) {
          final paidSessions = viewModel.sessions
              .where((s) => s.status == ConsultingStatus.paid || s.status == ConsultingStatus.conducted || s.status == ConsultingStatus.completed)
              .toList();

          if (paidSessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.history, size: 64, color: StartupOnboardingTheme.softIvory.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có lịch sử giao dịch.',
                    style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory.withOpacity(0.3)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: paidSessions.length,
            itemBuilder: (context, index) {
              final session = paidSessions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PaymentSummaryCard(
                  amount: session.amount,
                  txHash: session.txHash,
                  paymentDate: session.requestedAt, // Mocking payment date with request date
                ),
              );
            },
          );
        },
      ),
    );
  }
}
