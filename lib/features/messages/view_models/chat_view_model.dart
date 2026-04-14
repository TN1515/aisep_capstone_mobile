import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/message_service.dart';
import 'dart:async';

class ChatViewModel extends ChangeNotifier {
  final _messageService = MessageService();
  
  List<ConversationModel> _conversations = [];
  Map<int, List<MessageModel>> _messagesMap = {}; // conversationId -> messages
  bool _isLoading = false;
  String _searchQuery = '';
  int? _currentUserId; // Should be set from Auth

  List<ConversationModel> get conversations => _conversations.where((c) => 
    c.partnerName.toLowerCase().contains(_searchQuery.toLowerCase())
  ).toList();
  
  // Legacy alias for UI compatibility
  List<ConversationModel> get chats => conversations;
  
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  ChatViewModel() {
    loadConversations();
  }

  void setCurrentUserId(int id) {
    _currentUserId = id;
  }

  Future<void> loadConversations() async {
    _isLoading = true;
    notifyListeners();

    final response = await _messageService.getConversations();
    if (response.isSuccess && response.data != null) {
      _conversations = response.data!;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<int?> ensureConversation(int connectionId, {String? partnerName, String? partnerAvatar}) async {
    // Check if conversation already exists for this connection
    final existing = _conversations.where((c) => c.connectionId == connectionId);
    if (existing.isNotEmpty) {
      return existing.first.id;
    }

    // Create new conversation
    final response = await _messageService.createConversation(connectionId: connectionId);
    if (response.isSuccess && response.data != null) {
      final newConv = response.data!;
      _conversations.insert(0, newConv);
      notifyListeners();
      return newConv.id;
    }
    return null;
  }

  Future<void> loadMessages(int conversationId) async {
    if (_currentUserId == null) return;
    
    _isLoading = true;
    notifyListeners();

    final response = await _messageService.getMessages(
      conversationId: conversationId,
      currentUserId: _currentUserId!,
    );
    
    if (response.isSuccess && response.data != null) {
      _messagesMap[conversationId] = response.data!;
    }

    _isLoading = false;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<MessageModel> getMessages(int conversationId) {
    return _messagesMap[conversationId] ?? [];
  }

  Future<void> sendMessage(int conversationId, String text) async {
    if (text.trim().isEmpty || _currentUserId == null) return;
    
    final response = await _messageService.sendMessage(
      conversationId: conversationId,
      content: text,
      currentUserId: _currentUserId!,
    );

    if (response.isSuccess && response.data != null) {
      if (_messagesMap[conversationId] == null) {
        _messagesMap[conversationId] = [];
      }
      _messagesMap[conversationId]!.add(response.data!);
      
      // Update last message in the conversation list
      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        final current = _conversations[index];
        _conversations[index] = ConversationModel(
          id: current.id,
          partnerName: current.partnerName,
          partnerAvatar: current.partnerAvatar,
          lastMessage: text,
          lastMessageTime: DateTime.now(),
          unreadCount: current.unreadCount,
          status: current.status,
          connectionId: current.connectionId,
        );
      }
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadConversations();
  }
}

