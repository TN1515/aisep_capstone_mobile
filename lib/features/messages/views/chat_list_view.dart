import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/chat_model.dart';
import '../view_models/chat_view_model.dart';
import '../widgets/chat_tile.dart';
import 'chat_detail_view.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tin nhắn',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: Consumer<ChatViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              _buildSearchSection(context, viewModel),
              Expanded(
                child: _buildChatList(context, viewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, ChatViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
        child: TextField(
          onChanged: viewModel.updateSearchQuery,
          style: GoogleFonts.workSans(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14),
          decoration: InputDecoration(
            icon: Icon(LucideIcons.search, color: StartupOnboardingTheme.goldAccent.withOpacity(0.5), size: 18),
            hintText: 'Tìm kiếm Investor...',
            hintStyle: GoogleFonts.workSans(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3), fontSize: 14),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(BuildContext context, ChatViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator(color: StartupOnboardingTheme.goldAccent));
    }

    if (viewModel.chats.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      color: StartupOnboardingTheme.goldAccent,
      backgroundColor: Theme.of(context).cardColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: viewModel.chats.length,
        itemBuilder: (context, index) {
          final chat = viewModel.chats[index];
          return _buildChatItem(context, chat);
        },
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ConversationModel chat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: ListTile(
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
        contentPadding: const EdgeInsets.all(16),
        leading: _buildAvatar(chat),
        title: Row(
          children: [
            Expanded(
              child: Text(
                chat.partnerName,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.displayLarge?.color,
                ),
              ),
            ),
            if (chat.lastMessageTime != null)
              Text(
                _formatTime(chat.lastMessageTime!),
                style: GoogleFonts.workSans(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.4),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  chat.lastMessage ?? 'Bắt đầu cuộc trò chuyện',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    color: chat.unreadCount > 0 
                        ? Theme.of(context).textTheme.bodyLarge?.color 
                        : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.4),
                    fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (chat.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: StartupOnboardingTheme.goldAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    chat.unreadCount.toString(),
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ConversationModel chat) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.2)),
      ),
      child: Center(
        child: chat.partnerAvatar != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.network(chat.partnerAvatar!, fit: BoxFit.cover),
              )
            : Text(
                chat.partnerName.substring(0, 1).toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: StartupOnboardingTheme.goldAccent,
                ),
              ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.messageSquare, size: 64, color: StartupOnboardingTheme.goldAccent.withOpacity(0.1)),
          const SizedBox(height: 24),
          Text(
            'Hộp thư trống',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.displayLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy kết nối với Investor để bắt đầu trò chuyện.',
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
