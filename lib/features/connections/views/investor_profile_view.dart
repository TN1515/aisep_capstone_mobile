import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/investor_model.dart';
import '../models/connection_model.dart';
import '../widgets/investor_profile_header.dart';
import '../view_models/connection_view_model.dart';
import '../../messages/view_models/chat_view_model.dart';
import '../../messages/views/chat_detail_view.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'connection_request_form_view.dart';

class InvestorProfileView extends StatefulWidget {
  final InvestorModel investor;

  const InvestorProfileView({Key? key, required this.investor}) : super(key: key);

  @override
  State<InvestorProfileView> createState() => _InvestorProfileViewState();
}

class _InvestorProfileViewState extends State<InvestorProfileView> {
  bool _isInitializingChat = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConnectionViewModel>(context, listen: false)
          .loadInvestorDetail(widget.investor.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final connectionVM = Provider.of<ConnectionViewModel>(context);
    final chatVM = Provider.of<ChatViewModel>(context, listen: false);

    // Use detailed data if available, otherwise fallback to discovery data
    // Preserve verification status from discovery data if detailed data is missing it
    final detailedInvestor = connectionVM.currentDetailedInvestor?.id == widget.investor.id
        ? connectionVM.currentDetailedInvestor!
        : null;
        
    var investor = detailedInvestor != null
        ? (detailedInvestor.isVerified ? detailedInvestor : detailedInvestor.copyWith(isVerified: widget.investor.isVerified))
        : widget.investor;

    // Merge data from discovery card if detailed data is missing counts/sizes
    if (detailedInvestor != null) {
      investor = investor.copyWith(
        acceptedConnectionCount: (investor.acceptedConnectionCount == 0 && widget.investor.acceptedConnectionCount > 0)
            ? widget.investor.acceptedConnectionCount
            : investor.acceptedConnectionCount,
        ticketSizeMin: (investor.ticketSizeMin == null) ? widget.investor.ticketSizeMin : investor.ticketSizeMin,
        ticketSizeMax: (investor.ticketSizeMax == null) ? widget.investor.ticketSizeMax : investor.ticketSizeMax,
      );
    }

    final connection = _findConnection(connectionVM, investor.id);
    final status = connection?.status;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: InvestorProfileHeader(investor: investor),
              ),
              if (connectionVM.isLoading && connectionVM.currentDetailedInvestor?.id != widget.investor.id)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: StartupOnboardingTheme.goldAccent)),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Introduction Section
                      _buildDetailCard(
                        context,
                        LucideIcons.user,
                        'GIỚI THIỆU',
                        investor.bio ?? 'Chưa có thông tin giới thiệu.',
                        StartupOnboardingTheme.goldAccent,
                      ),

                      // Investment Thesis
                      _buildDetailCard(
                        context,
                        LucideIcons.lightbulb,
                        'LUẬN ĐIỂM ĐẦU TƯ',
                        investor.investmentThesis ?? 'Chưa cập nhật luận điểm đầu tư.',
                        Colors.blueAccent,
                      ),

                      // Preferred Industries
                      _buildTagSection(
                        context,
                        LucideIcons.briefcase,
                        'LĨNH VỰC QUAN TÂM',
                        investor.preferredIndustries,
                      ),

                      // Preferred Stages
                      _buildTagSection(
                        context,
                        LucideIcons.trendingUp,
                        'GIAI ĐOẠN ĐẦU TƯ',
                        investor.preferredStages,
                      ),

                      // Contact Information
                      _buildContactSection(context, investor),
                      
                      const SizedBox(height: 140), // Space for CTA
                    ]),
                  ),
                ),
            ],
          ),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: _buildCircularButton(
              context,
              LucideIcons.arrowLeft,
              () => Navigator.pop(context),
            ),
          ),

          // Favorite Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: _buildCircularButton(
              context,
              investor.isFavorite ? Icons.favorite : LucideIcons.heart,
              () => connectionVM.toggleFavorite(investor.id),
              color: investor.isFavorite ? Colors.red : null,
            ),
          ),

          // Action Button (CTA)
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: _buildCTA(context, status, connection, chatVM, investor),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, InvestorModel investor) {
    return Row(
      children: [
        _buildSummaryItem(context, 'LOẠI HÌNH', investor.investorType ?? 'Cá nhân'),
        _buildVerticalDivider(context),
        _buildSummaryItem(context, 'LĨNH VỰC', '${investor.preferredIndustries.length} ngành'),
        _buildVerticalDivider(context),
        _buildSummaryItem(context, 'VỊ TRÍ', investor.location?.split(',').last.trim() ?? 'VN'),
      ],
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.displayLarge?.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(
      height: 24,
      width: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.1),
    );
  }

  Widget _buildDetailCard(BuildContext context, IconData icon, String title, String content, Color accentColor) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: theme.textTheme.displayLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
              height: 1.6,
            ),
            softWrap: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTagSection(BuildContext context, IconData icon, String title, List<String> tags) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: StartupOnboardingTheme.goldAccent),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.displayLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (tags.isEmpty)
            Text('Chưa cập nhật', style: GoogleFonts.workSans(fontSize: 13, color: Colors.grey))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: StartupOnboardingTheme.goldAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.15)),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: StartupOnboardingTheme.goldAccent,
                  ),
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, InvestorModel investor) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THÔNG TIN LIÊN HỆ',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: theme.textTheme.displayLarge?.color,
            ),
          ),
          const SizedBox(height: 24),
          _buildContactRow(
            context, 
            LucideIcons.globe, 
            'Website chính thức', 
            investor.website,
            color: Colors.blueAccent,
            onTap: (investor.website != null && investor.website!.isNotEmpty) ? () => _launchURL(investor.website!) : null,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 0.5),
          ),
          _buildContactRow(
            context, 
            LucideIcons.linkedin, 
            'Linkedin', 
            investor.linkedinUrl,
            color: const Color(0xFF0077B5),
            onTap: (investor.linkedinUrl != null && investor.linkedinUrl!.isNotEmpty) ? () => _launchURL(investor.linkedinUrl!) : null,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 0.5),
          ),
          _buildContactRow(
            context, 
            LucideIcons.mapPin, 
            'Vị trí', 
            investor.location,
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, IconData icon, String label, String? value, {Color? color, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final bool hasValue = value != null && value.isNotEmpty;
    
    return InkWell(
      onTap: hasValue ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (color ?? theme.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: color ?? theme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label, 
                  style: GoogleFonts.workSans(
                    fontSize: 11, 
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasValue ? value : '',
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: (hasValue && onTap != null) ? Colors.blue : theme.textTheme.displayLarge?.color,
                    decoration: (hasValue && onTap != null) ? TextDecoration.underline : null,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
          if (hasValue && onTap != null)
            Icon(LucideIcons.externalLink, size: 14, color: Colors.blue.withOpacity(0.5)),
        ],
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    String formattedUrl = urlString;
    if (!formattedUrl.startsWith('http')) {
      formattedUrl = 'https://$formattedUrl';
    }
    final Uri url = Uri.parse(formattedUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $formattedUrl');
    }
  }

  Widget _buildCircularButton(BuildContext context, IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
          ],
        ),
        child: Icon(icon, size: 20, color: color ?? Theme.of(context).textTheme.displayLarge?.color),
      ),
    );
  }

  Widget _buildCTA(BuildContext context, ConnectionStatus? status, ConnectionModel? connection, ChatViewModel chatVM, InvestorModel investor) {
    final theme = Theme.of(context);
    
    String label = 'Gửi yêu cầu kết nối';
    VoidCallback? onPressed = () => _navigateToRequestForm(context, investor);
    Color? bgColor = theme.primaryColor;
    IconData? icon;

    if (status == ConnectionStatus.requested) {
      label = 'Đang chờ phản hồi';
      onPressed = null;
      bgColor = Colors.grey;
    } else if (status == ConnectionStatus.accepted) {
      label = 'Bắt đầu Chat';
      icon = LucideIcons.messageSquare;
      onPressed = () => _handleChat(context, connection!, chatVM, investor);
    }

    return Column(
      children: [
        if (status == ConnectionStatus.accepted)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Đã kết nối • Sẵn sàng trao đổi",
                style: GoogleFonts.workSans(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isInitializingChat ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: theme.brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 4,
            ),
            child: _isInitializingChat 
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
          ),
        ),
      ],
    );
  }

  ConnectionModel? _findConnection(ConnectionViewModel vm, int investorId) {
    final sent = vm.sentRequests.where((c) => c.investorId == investorId);
    final received = vm.receivedRequests.where((c) => c.investorId == investorId);

    if (received.isNotEmpty && received.first.status == ConnectionStatus.accepted) {
      return received.first;
    }
    
    if (sent.isNotEmpty) return sent.first;
    if (received.isNotEmpty) return received.first;
    
    return null;
  }

  Future<void> _handleChat(BuildContext context, ConnectionModel connection, ChatViewModel chatVM, InvestorModel investor) async {
    if (connection.conversationId != null && connection.conversationId! > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailView(
            conversationId: connection.conversationId!, 
            partnerName: investor.fullName,
            partnerAvatar: investor.avatarUrl,
          ),
        ),
      );
      return;
    }

    setState(() => _isInitializingChat = true);
    
    final convId = await chatVM.ensureConversation(
      connectionId: connection.id, 
      partnerName: investor.fullName,
      partnerAvatar: investor.avatarUrl,
    );
    
    if (context.mounted) {
      setState(() => _isInitializingChat = false);
      if (convId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailView(
              conversationId: convId, 
              partnerName: investor.fullName,
              partnerAvatar: investor.avatarUrl,
            ),
          ),
        );
      }
    }
  }

  void _navigateToRequestForm(BuildContext context, InvestorModel investor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConnectionRequestFormView(investor: investor),
      ),
    );
  }
}

