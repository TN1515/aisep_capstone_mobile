import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/chat_model.dart';
import '../view_models/chat_view_model.dart';
import '../../connections/models/connection_model.dart';
import '../../connections/view_models/connection_view_model.dart';
import '../../consulting/models/mentorship_models.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'chat_detail_view.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  bool _showUnreadOnly = false;
  @override
  void initState() {
    super.initState();
    // Pre-load conversations when hitting the tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatVm = Provider.of<ChatViewModel>(context, listen: false);
      final connVm = Provider.of<ConnectionViewModel>(context, listen: false);
      final consultingVm = Provider.of<ConsultingViewModel>(context, listen: false);
      chatVm.loadConversations(
        connections: connVm.allConnections,
        mentorships: consultingVm.mentorships,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectionVm = context.watch<ConnectionViewModel>();
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer3<ChatViewModel, ConnectionViewModel, ConsultingViewModel>(
          builder: (context, viewModel, connectionVm, consultingVm, child) {
            // Trigger name repair whenever connections/mentorships are available or updated
            if (connectionVm.allConnections.isNotEmpty || consultingVm.mentorships.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                viewModel.repairNames(
                  connections: connectionVm.allConnections,
                  mentorships: consultingVm.mentorships,
                );
              });
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildSearchSection(context, viewModel),
                _buildFilterChips(context, viewModel),
                Expanded(
                  child: _buildChatList(context, viewModel, connectionVm.allConnections, consultingVm.mentorships),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Text(
        'Tin nhắn',
        style: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.displayLarge?.color,
        ),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, ChatViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
        ),
        child: TextField(
          onChanged: viewModel.updateSearchQuery,
          style: GoogleFonts.workSans(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14),
          decoration: InputDecoration(
            icon: Icon(LucideIcons.search, color: Colors.grey.withOpacity(0.5), size: 20),
            hintText: 'Tìm kiếm hội thoại...',
            hintStyle: GoogleFonts.workSans(color: Colors.grey.withOpacity(0.5), fontSize: 14),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, ChatViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Row(
        children: [
          _buildChip(
            context, 
            'Tất cả', 
            !_showUnreadOnly,
            () => setState(() => _showUnreadOnly = false),
          ),
          const SizedBox(width: 12),
          _buildChip(
            context, 
            'Chưa đọc', 
            _showUnreadOnly,
            () => setState(() => _showUnreadOnly = true),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? StartupOnboardingTheme.goldAccent : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? StartupOnboardingTheme.goldAccent : Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: StartupOnboardingTheme.goldAccent.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ] : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.black : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
        ),
      ),
    ),
  );
}

  Widget _buildChatList(BuildContext context, ChatViewModel viewModel, List<ConnectionModel> connections, List<MentorshipDto> mentorships) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator(color: StartupOnboardingTheme.goldAccent));
    }

    final filteredChats = viewModel.chats.where((c) {
      if (_showUnreadOnly) {
        return c.unreadCount > 0;
      }
      return true;
    }).toList();

    if (filteredChats.isEmpty) {
      return _buildEmptyState(
        context, 
        title: _showUnreadOnly ? 'Không tìm thấy kết quả' : 'Hộp thư trống'
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(connections: connections, mentorships: mentorships),
      color: StartupOnboardingTheme.goldAccent,
      backgroundColor: Theme.of(context).cardColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        itemCount: filteredChats.length,
        itemBuilder: (context, index) {
          final chat = filteredChats[index];
          return _buildChatItem(context, viewModel, chat);
        },
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatViewModel viewModel, ConversationModel chat) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailView(
                conversationId: chat.id,
                partnerName: chat.partnerName,
                partnerAvatar: chat.partnerAvatar,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildAvatar(chat),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chat.partnerName,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.displayLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: chat.partnerRole == 'CỐ VẤN' 
                                      ? const Color(0xFFECFDF5) // Light emerald
                                      : const Color(0xFFEBF5FF), // Light blue
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  chat.partnerRole.toUpperCase(),
                                  style: GoogleFonts.workSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: chat.partnerRole == 'CỐ VẤN'
                                        ? const Color(0xFF10B981) // Emerald
                                        : const Color(0xFF3B82F6), // Professional blue
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (chat.lastMessageTime != null)
                              Text(
                                _formatTime(chat.lastMessageTime!),
                                style: GoogleFonts.workSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: chat.unreadCount > 0 
                                      ? Colors.grey.withOpacity(0.6)
                                      : StartupOnboardingTheme.goldAccent,
                                ),
                              ),
                            const SizedBox(height: 8),
                            if (chat.unreadCount > 0)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: StartupOnboardingTheme.goldAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    chat.unreadCount.toString(),
                                    style: GoogleFonts.workSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      chat.lastMessage != null 
                        ? (viewModel.currentUserId == chat.lastMessageSenderId && chat.lastMessageSenderId != 0 
                            ? 'Bạn: ${chat.lastMessage}' 
                            : chat.lastMessage!)
                        : '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.workSans(
                        fontSize: 14,
                        color: chat.unreadCount > 0 
                            ? theme.textTheme.bodyLarge?.color?.withOpacity(1.0)
                            : theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                        fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildAvatar(ConversationModel chat) {
    final bgColor = const Color(0xFFE8F1FF); // Soft blue background from mockup
    final textColor = const Color(0xFF3B82F6);

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: chat.partnerAvatar != null && chat.partnerAvatar!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.network(
                  chat.partnerAvatar!, 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildInitials(chat, textColor),
                ),
              )
            : _buildInitials(chat, textColor),
      ),
    );
  }

  Widget _buildInitials(ConversationModel chat, Color color) {
    return Text(
      chat.partnerName.isNotEmpty ? chat.partnerName.substring(0, 1).toUpperCase() : '?',
      style: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildEmptyState(BuildContext context, {String title = 'Hộp thư trống'}) {
    final chatVm = Provider.of<ChatViewModel>(context, listen: false);
    final connVm = Provider.of<ConnectionViewModel>(context, listen: false);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_showUnreadOnly) ...[
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: StartupOnboardingTheme.goldAccent.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.messageSquare, 
                  size: 64, 
                  color: StartupOnboardingTheme.goldAccent.withOpacity(0.5)
                ),
              ),
              const SizedBox(height: 32),
            ],
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.displayLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _showUnreadOnly 
                ? 'Bạn hiện không có tin nhắn nào chưa đọc.'
                : 'Các cuộc hội thoại đã bắt đầu sẽ xuất hiện tại đây. Nếu bạn không thấy, hãy thử tải lại.',
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
                height: 1.5,
              ),
            ),
            if (!_showUnreadOnly) ...[
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final consultingVm = Provider.of<ConsultingViewModel>(context, listen: false);
                    final connVm = Provider.of<ConnectionViewModel>(context, listen: false);
                    chatVm.loadConversations(
                      connections: connVm.allConnections,
                      mentorships: consultingVm.mentorships,
                    );
                  },
                  icon: const Icon(LucideIcons.refreshCw, size: 18),
                  label: Text('TẢI LẠI DỮ LIỆU', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: StartupOnboardingTheme.goldAccent.withOpacity(0.3)),
                    foregroundColor: StartupOnboardingTheme.goldAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
