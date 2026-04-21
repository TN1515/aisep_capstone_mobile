import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/features/messages/models/chat_model.dart';
import 'package:aisep_capstone_mobile/features/messages/services/message_service.dart';
import 'package:aisep_capstone_mobile/features/connections/models/connection_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/mentorship_models.dart';
import 'package:aisep_capstone_mobile/core/config/app_config.dart';
import 'package:aisep_capstone_mobile/core/services/signalr_service.dart';
import 'dart:async';

class ChatViewModel extends ChangeNotifier {
  final _messageService = MessageService();
  
  List<ConversationModel> _conversations = [];
  Map<int, List<MessageModel>> _messagesMap = {}; // conversationId -> messages
  bool _isLoading = false;
  String _searchQuery = '';
  int? _currentUserId;
  int? get currentUserId => _currentUserId;

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
    _initSignalR();
  }

  void _initSignalR() {
    dev.log('ChatViewModel: Initializing SignalR for user $_currentUserId');
    SignalRService().init((newMessage) {
      final convId = newMessage.conversationId ?? 0;
      if (convId == 0) return;

      // 1. Update the message specific map if we have it
      if (_messagesMap.containsKey(convId)) {
        _messagesMap[convId] = [...(_messagesMap[convId] ?? []), newMessage];
      }

      // 2. Update the conversation list (Last Message & Unread)
      final index = _conversations.indexWhere((c) => c.id == convId);
      if (index != -1) {
        final conv = _conversations[index];
        _conversations[index] = ConversationModel(
          id: conv.id,
          partnerName: conv.partnerName,
          partnerAvatar: conv.partnerAvatar,
          partnerRole: conv.partnerRole,
          lastMessage: newMessage.content,
          lastMessageTime: newMessage.sentAt,
          unreadCount: conv.unreadCount + 1,
          status: conv.status,
          connectionId: conv.connectionId,
          lastMessageSenderId: newMessage.senderId,
        );
        // Move to top
        _conversations.insert(0, _conversations.removeAt(index));
      } else {
        // 100% REAL DATA: Add a new conversation row dynamically from the real message data
        final newConv = ConversationModel(
          id: convId,
          partnerName: 'Unknown', // Will be repaired if a connection exists
          partnerRole: 'HỘI THOẠI',
          lastMessage: newMessage.content,
          lastMessageTime: newMessage.sentAt,
          unreadCount: 1,
          status: ConversationStatus.Active,
          connectionId: 0, // Unknown yet
          lastMessageSenderId: newMessage.senderId,
        );
        _conversations.insert(0, newConv);
      }
      notifyListeners();
    });
  }

  Future<void> loadConversations({
    List<ConnectionModel>? connections,
    List<MentorshipDto>? mentorships,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      dev.log('ChatViewModel: Fetching conversations from ${AppConfig.apiBaseUrl}/api/conversations');
      final response = await _messageService.getConversations();
      if (response.isSuccess && response.data != null) {
        _conversations = response.data!;
        
        // Auto-repair if connections or mentorships are provided
        if (connections != null || mentorships != null) {
          repairNames(connections: connections, mentorships: mentorships);
        } else {
          _deduplicateAndSort();
        }
        
        // 3. Hydrate latest messages from real message history API for 100% accuracy
        _hydrateLatestMessages();

        dev.log('ChatViewModel: Loaded ${_conversations.length} conversations');
      } else {
        dev.log('ChatViewModel: Error loading conversations: ${response.message ?? response.error}');
      }
    } catch (e) {
      dev.log('ChatViewModel: Exception in loadConversations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _hydrateLatestMessages() async {
    // Only hydrate active conversations to save bandwidth
    final activeConvs = List<ConversationModel>.from(_conversations);
    
    for (var conv in activeConvs) {
      // Skip if we already have a very fresh message (likely from SignalR or session)
      if (conv.lastMessageTime != null && 
          DateTime.now().difference(conv.lastMessageTime!).inMinutes < 1) {
        continue;
      }
      
      _hydrateConversation(conv.id);
    }
  }

  Future<void> _hydrateConversation(int conversationId) async {
    final response = await _messageService.getMessages(
      conversationId: conversationId,
      pageSize: 1, // Only need the top 1
      currentUserId: _currentUserId ?? 0,
    );

    if (response.isSuccess && response.data != null && response.data!.isNotEmpty) {
      final latestMsg = response.data!.first;
      
      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        final conv = _conversations[index];
        
        // Only update if the message is actually newer than what we have
        if (conv.lastMessageTime == null || 
            latestMsg.sentAt.isAfter(conv.lastMessageTime!)) {
          _conversations[index] = ConversationModel(
            id: conv.id,
            partnerName: conv.partnerName,
            partnerAvatar: conv.partnerAvatar,
            partnerRole: conv.partnerRole,
            lastMessage: latestMsg.content,
            lastMessageTime: latestMsg.sentAt,
            unreadCount: conv.unreadCount,
            status: conv.status,
            connectionId: conv.connectionId,
            lastMessageSenderId: latestMsg.senderId,
            mentorshipId: conv.mentorshipId,
          );
          notifyListeners();
        }
      }
    }
  }

  void markAsRead(int conversationId) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      final conv = _conversations[index];
      if (conv.unreadCount > 0) {
        _conversations[index] = ConversationModel(
          id: conv.id,
          partnerName: conv.partnerName,
          partnerAvatar: conv.partnerAvatar,
          partnerRole: conv.partnerRole,
          lastMessage: conv.lastMessage,
          lastMessageTime: conv.lastMessageTime,
          unreadCount: 0,
          status: conv.status,
          connectionId: conv.connectionId,
        );
        notifyListeners();
        dev.log('ChatViewModel: Marked conversation $conversationId as read locally');
      }
    }
  }

  void repairNames({
    List<ConnectionModel>? connections,
    List<MentorshipDto>? mentorships,
  }) {
    bool wasUpdated = false;
    final List<ConversationModel> updatedList = [];

    for (var conv in _conversations) {
      ConversationModel currentConv = conv;

      // 1. Repair for Connections (Investor/Startup)
      if (conv.connectionId != 0 && connections != null && connections.isNotEmpty) {
        try {
          final conn = connections.firstWhere((c) => c.id == conv.connectionId);
          if (conv.partnerName == 'Unknown' || conv.partnerName == 'Hội thoại' || conv.partnerRole.isEmpty) {
            currentConv = ConversationModel(
              id: conv.id,
              partnerName: conn.investorName,
              partnerAvatar: conv.partnerAvatar ?? conn.investorAvatarUrl,
              partnerRole: 'NHÀ ĐẦU TƯ',
              lastMessage: conv.lastMessage,
              lastMessageTime: conv.lastMessageTime,
              unreadCount: conv.unreadCount,
              status: conv.status,
              connectionId: conv.connectionId,
              mentorshipId: conv.mentorshipId,
              lastMessageSenderId: conv.lastMessageSenderId,
            );
            wasUpdated = true;
          }
        } catch (_) {}
      } 
      
      // 2. Repair for Mentorships (Advisor/Startup)
      if (conv.mentorshipId != null && conv.mentorshipId != 0 && mentorships != null && mentorships.isNotEmpty) {
        try {
          final mentorship = mentorships.firstWhere((m) => m.id == conv.mentorshipId);
          if (conv.partnerName == 'Unknown' || conv.partnerName == 'Hội thoại' || conv.partnerRole != 'CỐ VẤN') {
            currentConv = ConversationModel(
              id: conv.id,
              partnerName: mentorship.advisorName ?? 'Advisor',
              partnerAvatar: conv.partnerAvatar ?? mentorship.advisorAvatar,
              partnerRole: 'CỐ VẤN',
              lastMessage: conv.lastMessage,
              lastMessageTime: conv.lastMessageTime,
              unreadCount: conv.unreadCount,
              status: conv.status,
              connectionId: conv.connectionId,
              mentorshipId: conv.mentorshipId,
              lastMessageSenderId: conv.lastMessageSenderId,
            );
            wasUpdated = true;
          }
        } catch (_) {}
      }

      updatedList.add(currentConv);
    }

    _conversations = updatedList;
    _deduplicateAndSort();
    
    if (wasUpdated) {
      dev.log('ChatViewModel: Completed name repair and deduplication');
    }
  }

  /// Deduplicates the list based on first-created (lowest ID) per unique partner
  /// and then sorts by latest message time.
  void _deduplicateAndSort() {
    if (_conversations.isEmpty) return;

    final Map<int, ConversationModel> connectionMap = {};
    final Map<int, ConversationModel> mentorshipMap = {};
    final List<ConversationModel> standaloneChats = [];

    for (var conv in _conversations) {
      if (conv.connectionId != 0) {
        final existing = connectionMap[conv.connectionId];
        if (existing == null || conv.id < existing.id) {
          connectionMap[conv.connectionId] = conv;
        }
      } else if (conv.mentorshipId != null && conv.mentorshipId != 0) {
        final existing = mentorshipMap[conv.mentorshipId!];
        if (existing == null || conv.id < existing.id) {
          mentorshipMap[conv.mentorshipId!] = conv;
        }
      } else {
        standaloneChats.add(conv);
      }
    }

    final List<ConversationModel> deduplicated = [
      ...connectionMap.values,
      ...mentorshipMap.values,
      ...standaloneChats,
    ];

    deduplicated.sort((a, b) {
      if (a.lastMessageTime != null && b.lastMessageTime != null) {
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      }
      if (a.lastMessageTime != null) return -1;
      if (b.lastMessageTime != null) return 1;
      return b.id.compareTo(a.id);
    });

    _conversations = deduplicated;
    notifyListeners();
  }

  Future<int?> ensureConversation({int? connectionId, int? mentorshipId, String? partnerName, String? partnerAvatar}) async {
    // 1. Initial check in existing list
    var existing = _conversations.where((c) {
      if (connectionId != null && connectionId > 0) return c.connectionId == connectionId;
      if (mentorshipId != null && mentorshipId > 0) return c.mentorshipId == mentorshipId;
      return false;
    });
    
    if (existing.isNotEmpty) {
      return existing.first.id;
    }

    // 2. Proactively refresh list once to see if backend created it automatically
    await loadConversations();
    existing = _conversations.where((c) {
      if (connectionId != null && connectionId > 0) return c.connectionId == connectionId;
      if (mentorshipId != null && mentorshipId > 0) return c.mentorshipId == mentorshipId;
      return false;
    });
    
    if (existing.isNotEmpty) {
      return existing.first.id;
    }

    // 3. Create new conversation if still not found
    final response = await _messageService.createConversation(
      connectionId: connectionId,
      mentorshipId: mentorshipId,
    );
    if (response.isSuccess && response.data != null) {
      final newConv = response.data!;
      _conversations.insert(0, newConv);
      notifyListeners();
      return newConv.id;
    }
    return null;
  }

  Future<void> loadMessages(int conversationId) async {
    _isLoading = true;
    notifyListeners();

    final response = await _messageService.getMessages(
      conversationId: conversationId,
      currentUserId: _currentUserId ?? 0,
    );

    if (response.isSuccess && response.data != null) {
      // Clear old messages for this conversation to ensure real-time feel
      _messagesMap[conversationId] = [];
      
      // Sort messages: Oldest to Newest
      final sortedMessages = response.data!;
      sortedMessages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
      
      _messagesMap[conversationId] = sortedMessages;
      
      dev.log('ChatViewModel: Loaded ${sortedMessages.length} real messages for conv $conversationId');
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
    // 1. Optimistic Update (Immediate Feedback)
    final tempMsg = MessageModel(
      id: -DateTime.now().millisecondsSinceEpoch,
      conversationId: conversationId,
      content: text,
      senderId: _currentUserId ?? 0,
      sentAt: DateTime.now(),
      isMine: true,
    );
    
    _messagesMap[conversationId] = [...(_messagesMap[conversationId] ?? []), tempMsg];
    
    // Update last message in the list
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      final conv = _conversations[index];
      _conversations[index] = ConversationModel(
        id: conv.id,
        partnerName: conv.partnerName,
        partnerAvatar: conv.partnerAvatar,
        partnerRole: conv.partnerRole,
        lastMessage: text,
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        status: conv.status,
        connectionId: conv.connectionId,
        lastMessageSenderId: _currentUserId ?? 0,
      );
      // Move to top
      _conversations.insert(0, _conversations.removeAt(index));
    }
    notifyListeners();

    // 2. API Call
    final response = await _messageService.sendMessage(
      conversationId: conversationId,
      content: text,
      currentUserId: _currentUserId ?? 0,
    );

    if (response.isSuccess) {
      // Refresh to get official ID and timestamp if needed
      await loadMessages(conversationId);
    } else {
      dev.log('ChatViewModel: Failed to send message: ${response.message ?? response.error}');
    }
  }

  Future<void> refresh({
    List<ConnectionModel>? connections,
    List<MentorshipDto>? mentorships,
  }) async {
    _searchQuery = ''; // Reset search on refresh
    await loadConversations(connections: connections, mentorships: mentorships);
  }
}
