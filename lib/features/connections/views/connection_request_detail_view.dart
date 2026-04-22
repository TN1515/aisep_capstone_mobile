import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/connection_model.dart';
import '../models/investor_model.dart';
import '../models/connection_request_model.dart';
import '../view_models/connection_view_model.dart';
import '../widgets/connection_status_badge.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'connection_request_form_view.dart';
import '../../messages/view_models/chat_view_model.dart';
import '../../messages/views/chat_detail_view.dart';
import '../../messages/models/chat_model.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_config.dart';

class ConnectionRequestDetailView extends StatefulWidget {
  final ConnectionModel connection;
  final String? requestId;

  const ConnectionRequestDetailView({
    Key? key,
    required this.connection,
    this.requestId,
  }) : super(key: key);

  @override
  State<ConnectionRequestDetailView> createState() => _ConnectionRequestDetailViewState();
}

class _ConnectionRequestDetailViewState extends State<ConnectionRequestDetailView> {
  @override
  void initState() {
    super.initState();
    // Fetch full investor profile in background to get the correct 'investorType/title'
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ConnectionViewModel.instance.loadInvestorDetail(widget.connection.investorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ConnectionViewModel.instance;
    final theme = Theme.of(context);
    final Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        // Find latest connection status and enrich with profile data
        final rawConnection = (viewModel.sentRequests.followedBy(viewModel.receivedRequests))
            .firstWhere((c) => c.id == widget.connection.id, orElse: () => widget.connection);
        
        final currentConnection = viewModel.enrichConnection(rawConnection);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Chi tiết kết nối'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSummary(context, currentConnection),
                const SizedBox(height: 32),
                _buildMessageSection(context, currentConnection, textColor),
                const SizedBox(height: 32),
                if (currentConnection.status == ConnectionStatus.accepted) ...[
                  _buildInfoRequestsSection(context, viewModel, currentConnection),
                  const SizedBox(height: 32),
                ],
                _buildTimelineSection(context, currentConnection, textColor),
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomActions(context, viewModel, currentConnection),
        );
      },
    );
  }

  Widget _buildProfileSummary(BuildContext context, ConnectionModel currentConnection) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.primaryColor.withOpacity(0.2), width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  backgroundImage: (currentConnection.investorAvatarUrl != null && currentConnection.investorAvatarUrl!.isNotEmpty)
                      ? NetworkImage(
                          currentConnection.investorAvatarUrl!.startsWith('http')
                              ? currentConnection.investorAvatarUrl!
                              : '${AppConfig.apiBaseUrl}${currentConnection.investorAvatarUrl!.startsWith('/') ? '' : '/'}${currentConnection.investorAvatarUrl!}'
                        )
                      : null,
                  child: (currentConnection.investorAvatarUrl == null || currentConnection.investorAvatarUrl!.isEmpty)
                      ? Icon(LucideIcons.user, color: theme.primaryColor, size: 30)
                      : null,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        currentConnection.name,
                        maxLines: 1,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currentConnection.position}${currentConnection.organization != null ? ' tại ${currentConnection.organization}' : ''}',
                      style: GoogleFonts.workSans(
                        fontSize: 14,
                        color: textColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cập nhật',
                    style: GoogleFonts.workSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: textColor.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(currentConnection.createdAt.toLocal()),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              ConnectionStatusBadge(status: currentConnection.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMetric(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.workSans(fontSize: 10, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.4)),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
        ),
      ],
    );
  }

  Widget _buildMessageSection(BuildContext context, ConnectionModel currentConnection, Color textColor) {
    final theme = Theme.of(context);
    final hasMessage = currentConnection.message != null && currentConnection.message!.trim().isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'LỜI NHẮN KẾT NỐI'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasMessage ? theme.primaryColor.withOpacity(0.1) : theme.dividerColor.withOpacity(0.1),
            ),
          ),
          child: hasMessage 
            ? Text(
                currentConnection.message!,
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  color: textColor.withOpacity(0.8),
                  height: 1.6,
                ),
              )
            : Row(
                children: [
                  Icon(LucideIcons.info, size: 16, color: theme.textTheme.bodySmall?.color?.withOpacity(0.4)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Đối tác không gửi kèm lời nhắn cho yêu cầu này.',
                      style: GoogleFonts.workSans(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: textColor.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
        ),
      ],
    );
  }

  Widget _buildTimelineSection(BuildContext context, ConnectionModel currentConnection, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'DÒNG THỜI GIAN'),
        const SizedBox(height: 20),
        
        // Luôn có mốc gửi yêu cầu
        _buildTimelineTile(
          context, 
          'Gửi yêu cầu', 
          'Yêu cầu kết nối đã được gửi đến đối tác.', 
          currentConnection.createdAt, 
          true,
          isCompleted: true,
        ),
        
        // Mốc sự kiện tiếp theo dựa trên status
        _buildStatusTimelineItem(context, currentConnection),
      ],
    );
  }

  Widget _buildStatusTimelineItem(BuildContext context, ConnectionModel currentConnection) {
    String title = 'Đang chờ xử lý';
    String desc = 'Yêu cầu đang được đối tác xem xét.';
    DateTime time = currentConnection.updatedAt;
    bool isCompleted = false;

    switch (currentConnection.status) {
      case ConnectionStatus.requested:
        title = 'Đang chờ phản hồi';
        desc = 'Nhà đầu tư đã nhận được lời mời và đang xem xét hồ sơ của bạn.';
        isCompleted = false;
        break;
      case ConnectionStatus.accepted:
        title = 'Đã chấp nhận';
        desc = 'Đối tác đã đồng ý kết nối. Bạn có thể bắt đầu nhắn tin ngay.';
        isCompleted = true;
        break;
      case ConnectionStatus.rejected:
        title = 'Bị từ chối';
        desc = 'Đối tác đã từ chối yêu cầu kết nối này.';
        isCompleted = true;
        break;
      case ConnectionStatus.withdrawn:
        title = 'Đã thu hồi';
        desc = 'Bạn đã chủ động rút lại lời mời kết nối này.';
        isCompleted = true;
        break;
      case ConnectionStatus.closed:
        title = 'Đã kết thúc';
        desc = 'Cuộc hội thoại/kết nối này đã được đóng lại.';
        isCompleted = true;
        break;
      default:
        break;
    }

    return _buildTimelineTile(context, title, desc, time, false, isCompleted: isCompleted);
  }

  Widget _buildTimelineTile(BuildContext context, String title, String desc, DateTime time, bool isFirst, {bool isCompleted = false}) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isCompleted ? theme.primaryColor : theme.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: isCompleted ? [
                  BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 4)
                ] : null,
              ),
            ),
            if (!isCompleted && !isFirst)
              Container(
                width: 1,
                height: 40,
                color: theme.primaryColor.withOpacity(0.1),
              )
            else
              Container(
                width: 1,
                height: 40,
                color: theme.primaryColor.withOpacity(0.1),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(
                fontSize: 14, 
                fontWeight: FontWeight.bold, 
                color: isCompleted ? textColor : textColor.withOpacity(0.5)
              )),
              Text(desc, style: GoogleFonts.workSans(fontSize: 11, color: textColor.withOpacity(0.4))),
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm - dd/MM/yyyy').format(time.toLocal()), 
                style: GoogleFonts.workSans(fontSize: 10, color: theme.primaryColor.withOpacity(0.5))
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget? _buildBottomActions(BuildContext context, ConnectionViewModel vm, ConnectionModel currentConnection) {
    if (currentConnection.status == ConnectionStatus.requested) {
      if (currentConnection.isReceived) {
        return _buildReceiverActions(context, vm, currentConnection);
      } else {
        return _buildSenderActions(context, vm, currentConnection);
      }
    } else if (currentConnection.status == ConnectionStatus.accepted) {
      return _buildAcceptedActions(context, currentConnection);
    }
    return null;
  }

  Widget _buildAcceptedActions(BuildContext context, ConnectionModel currentConnection) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      color: theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleChat(context, currentConnection),
                  icon: const Icon(LucideIcons.messageSquare, size: 18),
                  label: Text('Bắt đầu Chat', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Kết nối đã sẵn sàng, bạn có thể trao đổi trực tiếp.",
            style: GoogleFonts.workSans(
              fontSize: 12,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleChat(BuildContext context, ConnectionModel currentConnection) async {
    final chatVm = Provider.of<ChatViewModel>(context, listen: false);

    // 1. If we already have a conversationId, just navigate directly
    if (currentConnection.conversationId != null && currentConnection.conversationId! > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailView(
            conversationId: currentConnection.conversationId!,
            partnerName: currentConnection.investorName, // Assuming partner is investor for Startup role
            partnerAvatar: currentConnection.investorAvatarUrl,
          ),
        ),
      );
      return;
    }

    // 2. Otherwise, use initialization logic
    final convId = await chatVm.ensureConversation(connectionId: currentConnection.id);
    
    if (convId != null && context.mounted) {
      final conversation = chatVm.conversations.firstWhere((c) => c.id == convId, 
          orElse: () => ConversationModel(
            id: convId, 
            partnerName: currentConnection.investorName, 
            status: ConversationStatus.Active, 
            connectionId: currentConnection.id
          ));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailView(
            conversationId: conversation.id,
            partnerName: conversation.partnerName,
            partnerAvatar: conversation.partnerAvatar,
          ),
        ),
      );
    }
  }

  Widget _buildInfoRequestsSection(BuildContext context, ConnectionViewModel vm, ConnectionModel currentConnection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(context, 'YÊU CẦU THÔNG TIN'),
            if (vm.isLoading) const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
        const SizedBox(height: 12),
        if (vm.infoRequests.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.info, size: 16, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Expanded(child: Text('Chưa có yêu cầu tài liệu nào.', style: GoogleFonts.workSans(fontSize: 12, color: Colors.grey))),
              ],
            ),
          )
        else
          ...vm.infoRequests.map((req) => _buildInfoRequestCard(context, vm, req, currentConnection)).toList(),
      ],
    );
  }

  Widget _buildInfoRequestCard(BuildContext context, ConnectionViewModel vm, dynamic req, ConnectionModel currentConnection) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.fileText, color: theme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(req.content ?? 'Yêu cầu tài liệu', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(DateFormat('dd/MM/yyyy').format(req.createdAt), style: GoogleFonts.workSans(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          if (req.status == 'Pending')
            ElevatedButton(
              onPressed: () { /* TODO: Open fulfillment dialog */ },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                foregroundColor: theme.primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Gửi', style: TextStyle(fontSize: 12)),
            )
          else
             Icon(LucideIcons.checkCircle, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  Widget _buildReceiverActions(BuildContext context, ConnectionViewModel vm, ConnectionModel currentConnection) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _confirmAction(context, 'Từ chối', () => vm.rejectRequest(currentConnection.id)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Từ chối', style: GoogleFonts.outfit(color: const Color(0xFFEF4444), fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => vm.acceptRequest(currentConnection.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Chấp nhận', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSenderActions(BuildContext context, ConnectionViewModel vm, ConnectionModel currentConnection) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _confirmAction(context, 'Hủy yêu cầu', () => vm.cancelRequest(currentConnection.id)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: textColor.withOpacity(0.2)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Hủy yêu cầu', style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConnectionRequestFormView(
                      investor: InvestorModel(
                        id: currentConnection.investorId,
                        fullName: currentConnection.investorName,
                        firmName: currentConnection.organization,
                      ),
                      initialMessage: currentConnection.message,
                      requestId: currentConnection.id.toString(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: theme.brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Cập nhật', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmAction(BuildContext context, String actionDesc, VoidCallback onConfirm) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.alertTriangle, color: theme.primaryColor, size: 48),
            const SizedBox(height: 24),
            Text(
              'Xác nhận $actionDesc?',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 12),
            Text(
              'Hành động này không thể hoàn tác. Bạn có chắc chắn muốn tiếp tục?',
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(color: textColor.withOpacity(0.5)),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Hủy', style: GoogleFonts.outfit(color: textColor.withOpacity(0.4))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onConfirm();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Xác nhận'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
