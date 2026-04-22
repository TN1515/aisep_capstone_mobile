import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/investor_model.dart';
import 'package:aisep_capstone_mobile/core/utils/ui_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/config/app_config.dart';

class InvestorProfileHeader extends StatelessWidget {
  final InvestorModel investor;

  const InvestorProfileHeader({
    Key? key,
    required this.investor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color accentColor = theme.primaryColor;
    final Color textColor = theme.textTheme.displayLarge?.color ?? Colors.white;
    final Color surfaceColor = theme.cardColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: isDark ? null : LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accentColor.withOpacity(0.05),
            surfaceColor,
          ],
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor.withOpacity(0.5), width: 2),
                ),
                child: GestureDetector(
                  onTap: () {
                    final String? url = UIUtils.getFullImageUrl(investor.avatarUrl);
                    if (url != null) {
                      UIUtils.showImagePreview(context, imageUrl: url, tag: 'investor_profile_avatar_${investor.id}');
                    }
                  },
                  child: Hero(
                    tag: 'investor_profile_avatar_${investor.id}',
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: accentColor.withOpacity(0.1),
                      backgroundImage: (investor.avatarUrl != null && investor.avatarUrl!.isNotEmpty)
                          ? NetworkImage(UIUtils.getFullImageUrl(investor.avatarUrl)!)
                          : null,
                      child: (investor.avatarUrl == null || investor.avatarUrl!.isEmpty)
                          ? Icon(LucideIcons.user, color: accentColor, size: 40)
                          : null,
                    ),
                  ),
                ),
              ),
              if (investor.isVerified)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            investor.name,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${investor.position}${investor.organization != null ? ' tại ${investor.organization}' : ''}',
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: textColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMetric(
                context, 
                LucideIcons.users, 
                '${investor.acceptedConnectionCount}', 
                'Đã kết nối'
              ),
              Container(
                height: 30,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                color: theme.dividerColor.withOpacity(0.1),
              ),
              _buildMetric(
                context, 
                LucideIcons.dollarSign, 
                _formatTicketSize(investor),
                'Quy mô'
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTicketSize(InvestorModel investor) {
    if (investor.ticketSizeMin == null && investor.ticketSizeMax == null) return 'Liên hệ';
    
    String format(double? val) {
      if (val == null) return '';
      double value = val;
      String unit = 'K';
      
      if (value >= 1000000) {
        value /= 1000000;
        unit = 'M';
      } else if (value >= 1000) {
        value /= 1000;
        unit = 'K';
      } else {
        // If it's already small (e.g. 50), keep it as is assuming it's in K
        unit = 'K';
      }
      
      // Remove .0 if it exists
      String formatted = value.toString();
      if (formatted.endsWith('.0')) {
        formatted = formatted.substring(0, formatted.length - 2);
      }
      return '\$$formatted$unit';
    }

    if (investor.ticketSizeMin == null) return '< ${format(investor.ticketSizeMax)}';
    if (investor.ticketSizeMax == null) return '> ${format(investor.ticketSizeMin)}';
    return '${format(investor.ticketSizeMin)} - ${format(investor.ticketSizeMax)}';
  }

  Widget _buildMetric(BuildContext context, IconData icon, String value, String label) {
    final theme = Theme.of(context);
    final accentColor = theme.primaryColor;
    final textColor = theme.textTheme.displayLarge?.color ?? Colors.white;

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: accentColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 10,
            color: textColor.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}
