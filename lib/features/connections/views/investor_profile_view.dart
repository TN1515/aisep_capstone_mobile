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
import 'connection_request_form_view.dart';

class InvestorProfileView extends StatefulWidget {
  final InvestorModel investor;

  const InvestorProfileView({Key? key, required this.investor}) : super(key: key);

  @override
  State<InvestorProfileView> createState() => _InvestorProfileViewState();
}

class _InvestorProfileViewState extends State<InvestorProfileView> {
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
    final investor = connectionVM.currentDetailedInvestor?.id == widget.investor.id
        ? connectionVM.currentDetailedInvestor!
        : widget.investor;

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
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSectionTitle(context, 'GIỚI THIỆU'),
                      const SizedBox(height: 12),
                      Text(
                        investor.bio ?? 'Chưa có thông tin giới thiệu.',
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle(context, 'CHIẾN LƯỢC ĐẦU TƯ (THESIS)'),
                      const SizedBox(height: 12),
                      Text(
                        investor.thesis,
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle(context, 'LĨNH VỰC QUAN TÂM'),
                      const SizedBox(height: 12),
                      _buildChipGroup(context, investor.preferredIndustries),
                      const SizedBox(height: 32),
                      _buildSectionTitle(context, 'GIAI ĐOẠN ĐẦU TƯ'),
                      const SizedBox(height: 12),
                      _buildChipGroup(context, investor.preferredStages),
                      const SizedBox(height: 32),
                      
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle(context, 'VỊ TRÍ'),
                                const SizedBox(height: 12),
                                _buildIconValue(context, LucideIcons.mapPin, investor.location ?? 'Chưa xác định'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle(context, 'WEBSITE'),
                                const SizedBox(height: 12),
                                _buildIconValue(context, LucideIcons.globe, investor.website ?? 'Chưa cập nhật'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
            ],
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: Icon(LucideIcons.arrowLeft, color: theme.textTheme.displayLarge?.color),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Global CTA
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

  Widget _buildIconValue(BuildContext context, IconData icon, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.primaryColor.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCTA(BuildContext context, ConnectionStatus? status, ConnectionModel? connection, ChatViewModel chatVM, InvestorModel investor) {
    final theme = Theme.of(context);
    
    String label = 'Gửi yêu cầu kết nối';
    VoidCallback? onPressed = () => _navigateToRequestForm(context, investor);
    Color? bgColor = theme.primaryColor;

    if (status == ConnectionStatus.requested) {
      label = 'Đang chờ phản hồi';
      onPressed = null;
      bgColor = Colors.grey;
    } else if (status == ConnectionStatus.accepted) {
      label = 'Nhắn tin';
      onPressed = () => _handleChat(context, connection!, chatVM, investor);
    }

    return Container(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: theme.brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          shadowColor: bgColor?.withOpacity(0.3),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
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
    final convId = await chatVM.ensureConversation(
      connection.id, 
      partnerName: investor.fullName,
      partnerAvatar: investor.avatarUrl,
    );
    if (convId != null && context.mounted) {
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildChipGroup(BuildContext context, List<String> items) {
    if (items.isEmpty) return Text('Chưa cập nhật', style: GoogleFonts.workSans(fontSize: 12, color: Colors.grey));
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(
          item,
          style: GoogleFonts.workSans(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
          ),
        ),
      )).toList(),
    );
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

