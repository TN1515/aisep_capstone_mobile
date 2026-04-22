import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/investor_model.dart';
import '../view_models/connection_view_model.dart';
import '../../../../core/utils/ui_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/config/app_config.dart';

class InvestorDiscoveryCard extends StatelessWidget {
  final InvestorModel investor;
  final VoidCallback onTap;

  const InvestorDiscoveryCard({
    Key? key,
    required this.investor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color accentColor = theme.primaryColor;
    final Color surfaceColor = theme.cardColor;
    final Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: accentColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (investor.isVerified) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified, color: Color(0xFF10B981), size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Đã xác thực',
                              style: GoogleFonts.workSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final String? url = UIUtils.getFullImageUrl(investor.avatarUrl);
                        if (url != null) {
                          UIUtils.showImagePreview(context, imageUrl: url, tag: 'investor_avatar_${investor.id}');
                        }
                      },
                      child: Hero(
                        tag: 'investor_avatar_${investor.id}',
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: accentColor.withOpacity(0.1),
                          backgroundImage: (investor.avatarUrl != null && investor.avatarUrl!.isNotEmpty)
                              ? NetworkImage(UIUtils.getFullImageUrl(investor.avatarUrl)!)
                              : null,
                          child: (investor.avatarUrl == null || investor.avatarUrl!.isEmpty)
                              ? Icon(LucideIcons.briefcase, color: accentColor)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            investor.name,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            '${investor.position}${investor.organization != null ? ' tại ${investor.organization}' : ''}',
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => ConnectionViewModel().toggleFavorite(investor.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: investor.isFavorite ? Colors.red.withOpacity(0.1) : theme.dividerColor.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          investor.isFavorite ? Icons.favorite : LucideIcons.heart,
                          color: investor.isFavorite ? Colors.redAccent : theme.textTheme.bodySmall?.color?.withOpacity(0.4),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                if (investor.investmentThesis != null && investor.investmentThesis!.isNotEmpty && investor.investmentThesis != 'Chưa có thông tin')
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      investor.investmentThesis!,
                      style: GoogleFonts.workSans(
                        fontSize: 13,
                        color: textColor.withOpacity(0.8),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 16),
                _buildInfoGrid(context),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (investor.preferredIndustries.isNotEmpty)
                      ...investor.preferredIndustries.take(2).map((tag) => _buildTag(context, tag, LucideIcons.tag)),
                    if (investor.preferredStages.isNotEmpty)
                      ...investor.preferredStages.take(1).map((tag) => _buildTag(context, tag, LucideIcons.trendingUp)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context) {
    String ticketRange = 'Liên hệ';
    if (investor.ticketSizeMin != null && investor.ticketSizeMax != null) {
      ticketRange = '${_formatCurrency(investor.ticketSizeMin!)} - ${_formatCurrency(investor.ticketSizeMax!)}';
    } else if (investor.ticketSizeMin != null) {
      ticketRange = '> ${_formatCurrency(investor.ticketSizeMin!)}';
    } else if (investor.ticketSizeMax != null) {
      ticketRange = '< ${_formatCurrency(investor.ticketSizeMax!)}';
    }

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildInfoItem(context, LucideIcons.users, '${investor.acceptedConnectionCount} đã kết nối'),
        _buildInfoItem(context, LucideIcons.banknote, 'Quy mô: $ticketRange'),
      ],
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(amount % 1000000 == 0 ? 0 : 1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}k';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.primaryColor.withOpacity(0.6)),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }



  Widget _buildTag(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.dividerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: theme.textTheme.bodySmall?.color?.withOpacity(0.5)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: 11,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
