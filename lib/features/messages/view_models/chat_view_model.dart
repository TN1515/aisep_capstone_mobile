import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../../connections/models/connection_model.dart';
import 'dart:async';

class ChatViewModel extends ChangeNotifier {
  List<ChatModel> _chats = [];
  Map<String, List<MessageModel>> _messagesMap = {}; // chatId -> messages
  bool _isLoading = false;
  String _searchQuery = '';

  List<ChatModel> get chats => _chats.where((c) => 
    c.investorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
    (c.organizationName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
  ).toList();
  
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  ChatViewModel() {
    _loadInitialChats();
  }

  void _loadInitialChats() {
    _isLoading = true;
    notifyListeners();

    // Mock data mimicking active connections
    // In a real app, this would fetch from a ConnectionRepository and MessageRepository
    _chats = [
      ChatModel(
        id: 'conn_1',
        investorId: 'inv_1',
        investorName: 'Shark Bình',
        organizationName: 'NextTech Group',
        lastMessage: 'Dự án của bạn rất tiềm năng, hãy gửi Pitch Deck chi tiết hơn.',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
      ),
      ChatModel(
        id: 'conn_2',
        investorId: 'inv_2',
        investorName: 'Trương Lý Hoàng Phi',
        organizationName: 'Vintech City',
        lastMessage: 'Chào bạn, mình đã xem qua hồ sơ startup của bạn.',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
      ),
      ChatModel(
        id: 'conn_3',
        investorId: 'inv_3',
        investorName: 'Lê Diệp Kiều Trang',
        organizationName: 'Harrison.ai',
        lastMessage: 'Chưa có tin nhắn',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
      ),
    ];

    // Mock message history for 'conn_1'
    _messagesMap['conn_1'] = [
      MessageModel(
        id: 'm1',
        chatId: 'conn_1',
        senderId: 'inv_1',
        text: 'Chào bạn, mình là Bình từ NextTech.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isMe: false,
      ),
      MessageModel(
        id: 'm2',
        chatId: 'conn_1',
        senderId: 'me',
        text: 'Dạ chào Shark, rất vinh dự được kết nối với Shark ạ.',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isMe: true,
      ),
      MessageModel(
        id: 'm3',
        chatId: 'conn_1',
        senderId: 'inv_1',
        text: 'Dự án của bạn rất tiềm năng, hãy gửi Pitch Deck chi tiết hơn.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isMe: false,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<MessageModel> getMessages(String chatId) {
    return _messagesMap[chatId] ?? [];
  }

  Future<void> sendMessage(String chatId, String text) async {
    if (text.trim().isEmpty) return;
    
    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      senderId: 'me',
      text: text,
      timestamp: DateTime.now(),
      isMe: true,
    );

    if (_messagesMap[chatId] == null) {
      _messagesMap[chatId] = [];
    }
    _messagesMap[chatId]!.add(newMessage);

    // Update last message in the chat list
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      _chats[chatIndex] = _chats[chatIndex].copyWith(
        lastMessage: text,
        lastMessageTime: DateTime.now(),
      );
    }

    notifyListeners();
    // Simulate real-time response or API call
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _loadInitialChats();
  }
}
