import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../view_models/chat_view_model.dart';
import '../widgets/chat_tile.dart';
import 'chat_detail_view.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(),
      child: Scaffold(
        backgroundColor: StartupOnboardingTheme.navyBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Tin nhắn'),
        ),
        body: Consumer<ChatViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                _buildSearchSection(viewModel),
                Expanded(
                  child: _buildChatList(context, viewModel),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchSection(ChatViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Container(
        height: 52, // Explicitly scaled height
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: StartupOnboardingTheme.navySurface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: TextField(
          onChanged: viewModel.updateSearchQuery,
          style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory, fontSize: 14),
          decoration: InputDecoration(
            icon: Icon(LucideIcons.search, color: StartupOnboardingTheme.goldAccent.withOpacity(0.5), size: 18),
            hintText: 'Tìm kiếm Investor...',
            hintStyle: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory.withOpacity(0.3), fontSize: 14),
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
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      color: StartupOnboardingTheme.goldAccent,
      backgroundColor: StartupOnboardingTheme.navySurface,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        itemCount: viewModel.chats.length,
        itemBuilder: (context, index) {
          final chat = viewModel.chats[index];
          return ChatTile(
            chat: chat,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: viewModel,
                    child: ChatDetailView(chat: chat),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
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
              color: StartupOnboardingTheme.softIvory,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy kết nối với Investor để bắt đầu trò chuyện.',
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: StartupOnboardingTheme.softIvory.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
