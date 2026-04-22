import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/chat_model.dart';
import '../view_models/chat_view_model.dart';
import 'package:aisep_capstone_mobile/core/utils/ui_utils.dart';
import 'package:intl/intl.dart';

class ChatDetailView extends StatefulWidget {
  final int conversationId;
  final String partnerName;
  final String? partnerAvatar;

  const ChatDetailView({
    super.key, 
    required this.conversationId,
    required this.partnerName,
    this.partnerAvatar,
  });

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ChatViewModel>(context, listen: false);
      viewModel.loadMessages(widget.conversationId);
      viewModel.markAsRead(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0.5,
        toolbarHeight: 60,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            _buildSmallAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.partnerName,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.displayLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Consumer<ChatViewModel>(
                    builder: (context, vm, _) => Text(
                      vm.isLoading ? 'Đang cập nhật...' : 'Trực tuyến',
                      style: GoogleFonts.workSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: vm.isLoading 
                            ? Colors.grey.withOpacity(0.5)
                            : StartupOnboardingTheme.goldAccent.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatViewModel>(
              builder: (context, viewModel, child) {
                final messages = viewModel.getMessages(widget.conversationId);
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                
                if (viewModel.isLoading && messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (messages.isEmpty) {
                  return _buildEmptyChatState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _buildMessageBubble(msg);
                  },
                );
              },
            ),
          ),
          _buildInputSection(context),
        ],
      ),
    );
  }

  Widget _buildSmallAvatar() {
    return Hero(
      tag: 'chat_avatar_${widget.conversationId}',
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.2)),
        ),
        child: Center(
          child: (widget.partnerAvatar != null && widget.partnerAvatar!.isNotEmpty)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    UIUtils.getFullImageUrl(widget.partnerAvatar!)!, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildInitials(),
                  ),
                )
              : _buildInitials(),
        ),
      ),
    );
  }

  Widget _buildInitials() {
    return Text(
      widget.partnerName.substring(0, 1).toUpperCase(),
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: StartupOnboardingTheme.goldAccent,
      ),
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.messagesSquare, size: 48, color: StartupOnboardingTheme.goldAccent.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'Bắt đầu cuộc trò chuyện',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.displayLarge?.color?.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy gửi lời chào đầu tiên tới ${widget.partnerName}!',
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg) {
    final isMe = msg.isMine;
    
    // Safety check: if content is empty but it's not a temporary message, it might be a mapping issue
    final displayContent = msg.content.isEmpty ? "..." : msg.content;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const Offset(0, 2).dy == 2 ? const EdgeInsets.only(bottom: 2) : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: isMe ? StartupOnboardingTheme.goldAccent : Theme.of(context).cardColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              boxShadow: [
                if (isMe) BoxShadow(
                  color: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
              child: Text(
                displayContent,
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  color: isMe ? Colors.black : Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.4,
                ),
              ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              DateFormat('HH:mm').format(msg.timestamp),
              style: GoogleFonts.workSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.3),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    // Scaffold's resizeToAvoidBottomInset already handles the keyboard distance. 
    // Adding viewInsets.bottom here causes a double-padding/overflow issue.
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              child: Center(
                child: TextField(
                  controller: _messageController,
                  autofocus: true,
                  style: GoogleFonts.workSans(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    hintStyle: GoogleFonts.workSans(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3), fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              final text = _messageController.text;
              if (text.isNotEmpty) {
                Provider.of<ChatViewModel>(context, listen: false).sendMessage(widget.conversationId, text);
                _messageController.clear();
                _scrollToBottom();
              }
            },
            child: Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(
                color: StartupOnboardingTheme.goldAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.send, color: Colors.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
