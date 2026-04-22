import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/connection_model.dart';
import '../models/investor_model.dart';
import '../models/information_request_model.dart';
import '../services/connection_service.dart';
import '../../messages/services/message_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ConnectionViewModel extends ChangeNotifier {
  final ConnectionService _service = ConnectionService();
  final MessageService _messageService = MessageService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _favoritesKey = 'favorite_investor_ids';

  // Filter Constants
  static const List<String> stagesOptions = ['Idea', 'Pre-Seed', 'Seed', 'Growth'];
  
  static const List<String> industriesOptions = [
    'Agri & FoodTech', 'AI in Diagnosis & Clinical Decision Support', 'Appointment & Health Records',
    'B2B Commerce', 'B2C Marketplace', 'Blockchain & Digital Assets', 'Coding & STEM Education',
    'Cold Chain Infrastructure', 'CRM & Sales Tools', 'Data Analytics & BI', 'Developer Tools & DevOps',
    'E-Commerce', 'EdTech', 'ERP & Operations', 'Farm Automation & Robotics', 'Farmer-to-Market Platforms',
    'FinTech', 'Food & Grocery Delivery', 'Fulfillment & Delivery', 'HealthTech / MedTech',
    'InsurTech', 'K-12 Learning Support', 'Language Learning', 'Marketing Tech', 'MOOCs & Skills Courses',
    'Online Lending & Credit', 'Online Pharmacy', 'Payments & Digital Wallets', 'Personal Finance & Investing',
    'Precision Agriculture', 'SaaS & Enterprise Software', 'Social Commerce', 'Telehealth',
    'Traceability & Food Safety', 'Tutor Matching Platforms', 'Wearables & Health Tracking'
  ];

  static const List<String> dealSizeOptions = [
    'Dưới \$50K', '\$50K - \$250K', '\$250K - \$1M', 'Từ \$1M'
  ];

  // Singleton instance
  static final ConnectionViewModel instance = ConnectionViewModel._internal();
  factory ConnectionViewModel() => instance;
  ConnectionViewModel._internal() {
    refreshAll();
  }

  // Connection Lists
  List<ConnectionModel> _receivedConnections = [];
  List<ConnectionModel> _sentConnections = [];
  List<ConnectionModel> _history = [];
  List<InvestorModel> _investors = [];
  List<InvestorModel> _aiInvestors = [];
  Set<int> _localFavoriteIds = {};
  List<InfoRequestModel> _infoRequests = [];
  InvestorModel? _currentDetailedInvestor;
  
  // State
  bool _isLoading = false;
  String? _errorMessage;
  
  // Search & Filter State
  String _searchQuery = '';
  Set<String> _selectedStages = {};
  Set<String> _selectedIndustries = {};
  String? _selectedDealSize;
  
  // Getters
  List<ConnectionModel> get receivedRequests => _receivedConnections;
  List<ConnectionModel> get sentRequests => _sentConnections;
  List<ConnectionModel> get history => _history;
  
  List<ConnectionModel> get allConnections {
    final Map<int, ConnectionModel> distinct = {};
    for (var c in _receivedConnections) { distinct[c.id] = c; }
    for (var c in _sentConnections) { distinct[c.id] = c; }
    for (var c in _history) { distinct[c.id] = c; }
    return distinct.values.toList();
  }
  List<InvestorModel> get discoveryResults => _investors;
  List<InvestorModel> get aiRecommendations => _aiInvestors;
  List<InvestorModel> get favoriteInvestors {
    // Merge server-side favorites with local favorites
    final Map<int, InvestorModel> favoritesMap = {};
    
    // Add server favorites
    for (var i in _investors.where((i) => i.isFavorite)) {
      favoritesMap[i.id] = i;
    }
    
    // Add local favorites if they are in the current list
    for (var i in _investors) {
      if (_localFavoriteIds.contains(i.id)) {
        favoritesMap[i.id] = i.copyWith(isFavorite: true);
      }
    }
    
    return favoritesMap.values.toList();
  }
  List<InfoRequestModel> get infoRequests => _infoRequests;
  InvestorModel? get currentDetailedInvestor => _currentDetailedInvestor;
  final Map<int, InvestorModel> _investorCache = {};

  ConnectionModel enrichConnection(ConnectionModel conn) {
    // 1. Check current detailed investor
    if (_currentDetailedInvestor?.id == conn.investorId) {
      return conn.copyWith(investorType: _currentDetailedInvestor!.investorType);
    }
    
    // 2. Check cache
    if (_investorCache.containsKey(conn.investorId)) {
      return conn.copyWith(investorType: _investorCache[conn.investorId]!.investorType);
    }
    
    // 3. Check discovery list
    try {
      final discoveryMatch = _investors.firstWhere((i) => i.id == conn.investorId);
      return conn.copyWith(investorType: discoveryMatch.investorType);
    } catch (_) {}
    
    return conn;
  }
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  Set<String> get selectedStages => _selectedStages;
  Set<String> get selectedIndustries => _selectedIndustries;
  String? get selectedDealSize => _selectedDealSize;

  Future<void> refreshAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadLocalFavorites();
      await Future.wait([
        loadInvestors(),
        loadAiRecommendations(),
        _loadReceived(),
        _loadSent(),
      ]);
      _applyLocalFavorites();
    } catch (e) {
      log('ConnectionViewModel: Error during refreshAll: $e');
      _errorMessage = 'Không thể tải dữ liệu kết nối. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 1. Investor Discovery (Search)
  Future<void> loadInvestors() async {
    final response = await _service.getInvestors(
      keyword: _searchQuery.isEmpty ? null : _searchQuery,
      stage: _selectedStages.isEmpty ? null : _selectedStages.join(','),
      industry: _selectedIndustries.isEmpty ? null : _selectedIndustries.join(','),
    );

    if (response.isSuccess) {
      _investors = response.data ?? [];
      _applyLocalFavorites();
    }
  }

  Future<void> loadAiRecommendations() async {
    final response = await _service.getAiRecommendations();
    if (response.isSuccess) {
      _aiInvestors = response.data ?? [];
    }
  }

  Future<void> loadInvestorDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.getInvestorById(id);
    if (response.isSuccess && response.data != null) {
      var investor = response.data!;
      if (_localFavoriteIds.contains(investor.id)) {
        investor = investor.copyWith(isFavorite: true);
      }
      _currentDetailedInvestor = investor;
      _investorCache[investor.id] = investor;
    } else {
      _errorMessage = response.message;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadInvestors().then((_) => notifyListeners());
  }

  void toggleStage(String stage) {
    if (_selectedStages.contains(stage)) {
      _selectedStages.remove(stage);
    } else {
      _selectedStages.add(stage);
    }
    loadInvestors().then((_) => notifyListeners());
  }

  void toggleIndustry(String industry) {
    if (_selectedIndustries.contains(industry)) {
      _selectedIndustries.remove(industry);
    } else {
      _selectedIndustries.add(industry);
    }
    loadInvestors().then((_) => notifyListeners());
  }

  void setSelectedDealSize(String? size) {
    _selectedDealSize = size;
    notifyListeners();
  }

  void resetFilters() {
    _selectedStages.clear();
    _selectedIndustries.clear();
    _selectedDealSize = null;
    loadInvestors().then((_) => notifyListeners());
  }

  // Public API for connection loading
  Future<void> loadReceivedConnections() => _loadReceived();
  Future<void> loadSentConnections() => _loadSent();

  // 2. Connection Lifecycle
  Future<void> _loadReceived() async {
    final response = await _service.getReceivedConnections();
    if (response.isSuccess) {
      final all = response.data ?? [];
      // Include all states to ensure Detail View can reflect status changes (Accepted, Rejected, Withdrawn, etc.)
      _receivedConnections = all.map((c) => c.copyWith(isReceived: true)).toList();
      
      // Proactively initialize chats for accepted connections
      _initAcceptedConversations(_receivedConnections);
    }
  }

  Future<void> _loadSent() async {
    final response = await _service.getSentConnections();
    if (response.isSuccess) {
      final all = response.data ?? [];
      // Include all states to ensure Detail View can reflect status changes (Accepted, Rejected, Withdrawn, etc.)
      _sentConnections = all.map((c) => c.copyWith(isReceived: false)).toList();

      // Proactively initialize chats for accepted connections
      _initAcceptedConversations(_sentConnections);
    }
  }

  Future<void> _initAcceptedConversations(List<ConnectionModel> connections) async {
    final acceptedWithoutChat = connections.where((c) => 
      c.status == ConnectionStatus.accepted && (c.conversationId == null || c.conversationId == 0)
    ).toList();

    if (acceptedWithoutChat.isEmpty) {
      log('ConnectionViewModel: No accepted stable connections without chats found.');
      return;
    }

    log('ConnectionViewModel: Found ${acceptedWithoutChat.length} connections needing chat initialization.');

    for (var conn in acceptedWithoutChat) {
      // Run in background without await for each to avoid blocking
      _messageService.createConversation(connectionId: conn.id).then((response) {
        if (response.isSuccess && response.data != null) {
          final newConvId = response.data!.id;
          
          // Update the ID in local lists so the UI reflects that chat is initialized
          bool updated = false;
          
          final sentIdx = _sentConnections.indexWhere((c) => c.id == conn.id);
          if (sentIdx != -1) {
            _sentConnections[sentIdx] = _sentConnections[sentIdx].copyWith(conversationId: newConvId);
            updated = true;
          }
          
          final receivedIdx = _receivedConnections.indexWhere((c) => c.id == conn.id);
          if (receivedIdx != -1) {
            _receivedConnections[receivedIdx] = _receivedConnections[receivedIdx].copyWith(conversationId: newConvId);
            updated = true;
          }
          
          if (updated) {
            notifyListeners();
          }
          
          log('ConnectionViewModel: Successfully auto-initialized conversation for connection ${conn.id} with ID $newConvId');
        } else {
          log('ConnectionViewModel: Failed to auto-initialize conversation for connection ${conn.id}: ${response.error}');
        }
      });
    }
  }

  void _updateHistory(List<ConnectionModel> items) {
    // Tạm thời xóa logic mapping cũ, chờ API mới từ người dùng
    _history = [];
    notifyListeners();
  }

  // Legacy Method Names for UI Compatibility
  Future<bool> acceptRequest(dynamic id) => acceptConnection(int.tryParse(id.toString()) ?? 0);
  Future<bool> rejectRequest(dynamic id, [String reason = '']) => rejectConnection(int.tryParse(id.toString()) ?? 0, reason);
  Future<void> cancelRequest(dynamic id) => withdrawConnection(int.tryParse(id.toString()) ?? 0);
  Future<bool> updateRequest(dynamic id, String message) async {
    final int connectionId = int.tryParse(id.toString()) ?? 0;
    if (connectionId == 0) return false;

    _isLoading = true;
    notifyListeners();

    final response = await _service.updateConnectionMessage(connectionId, message);
    
    _isLoading = false;
    if (response.isSuccess) {
      await _loadSent();
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }
  Future<void> sendRequest(int investorId, String message) => inviteConnection(investorId, message);
  
  void toggleFavorite(int investorId) {
    toggleWatchlist(investorId);
  }

  Future<bool> toggleWatchlist(int investorId) async {
    // Optimistic UI update
    final index = _investors.indexWhere((i) => i.id == investorId);
    if (index != -1) {
      final isNowFavorite = !_investors[index].isFavorite;
      _investors[index] = _investors[index].copyWith(isFavorite: isNowFavorite);
      
      // Update local storage
      if (isNowFavorite) {
        _localFavoriteIds.add(investorId);
      } else {
        _localFavoriteIds.remove(investorId);
      }
      await _saveLocalFavorites();
      
      // Also update detailed view if applicable
      if (_currentDetailedInvestor?.id == investorId) {
        _currentDetailedInvestor = _currentDetailedInvestor!.copyWith(isFavorite: isNowFavorite);
      }
      
      notifyListeners();
      
      final response = await _service.addToWatchlist(investorId);
      if (!response.isSuccess) {
        // Rollback on failure is usually skipped for favorites to keep UX smooth,
        // but since we want to be correct:
        log('ConnectionViewModel: Server toggle failed, but kept local state for UX.');
        // We keep local state even if server fails because server endpoint is missing
      }
      return true;
    }
    return false;
  }

  // --- Local Persistence Helpers ---
  
  Future<void> _loadLocalFavorites() async {
    try {
      final data = await _storage.read(key: _favoritesKey);
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        _localFavoriteIds = decoded.cast<int>().toSet();
      }
    } catch (e) {
      log('ConnectionViewModel: Error loading local favorites: $e');
    }
  }

  Future<void> _saveLocalFavorites() async {
    try {
      await _storage.write(key: _favoritesKey, value: jsonEncode(_localFavoriteIds.toList()));
    } catch (e) {
      log('ConnectionViewModel: Error saving local favorites: $e');
    }
  }

  void _applyLocalFavorites() {
    for (int i = 0; i < _investors.length; i++) {
      if (_localFavoriteIds.contains(_investors[i].id)) {
        _investors[i] = _investors[i].copyWith(isFavorite: true);
      }
    }
    if (_currentDetailedInvestor != null && _localFavoriteIds.contains(_currentDetailedInvestor!.id)) {
      _currentDetailedInvestor = _currentDetailedInvestor!.copyWith(isFavorite: true);
    }
  }

  Future<bool> inviteConnection(int investorId, String message) async {
    _isLoading = true;
    notifyListeners();

    final response = await _service.inviteConnection(investorId, message);
    
    _isLoading = false;
    if (response.isSuccess) {
      await _loadSent();
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> acceptConnection(int id) async {
    final response = await _service.acceptConnection(id);
    if (response.isSuccess) {
      await refreshAll();
      return true;
    }
    return false;
  }

  Future<bool> rejectConnection(int id, String reason) async {
    final response = await _service.rejectConnection(id, reason);
    if (response.isSuccess) {
      await refreshAll();
      return true;
    }
    return false;
  }

  Future<bool> withdrawConnection(int id) async {
    final response = await _service.withdrawConnection(id);
    if (response.isSuccess) {
      await _loadSent();
      notifyListeners();
      return true;
    }
    return false;
  }

  // 3. Information Requests
  Future<void> loadInfoRequests(int connectionId) async {
    final response = await _service.getInfoRequests(connectionId);
    if (response.isSuccess) {
      _infoRequests = response.data ?? [];
    }
    notifyListeners();
  }

  Future<bool> fulfillRequest(int requestId, String content, List<String> attachments) async {
    final response = await _service.fulfillInfoRequest(requestId, content, attachments);
    return response.isSuccess;
  }
}
