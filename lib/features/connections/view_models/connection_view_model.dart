import 'package:flutter/material.dart';
import '../models/connection_model.dart';
import '../models/investor_model.dart';
import '../models/information_request_model.dart';
import '../services/connection_service.dart';

class ConnectionViewModel extends ChangeNotifier {
  final ConnectionService _service = ConnectionService();

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
  List<InvestorModel> get discoveryResults => _investors;
  List<InvestorModel> get aiRecommendations => _aiInvestors;
  List<InvestorModel> get favoriteInvestors => _investors.where((i) => i.isFavorite).toList();
  List<InfoRequestModel> get infoRequests => _infoRequests;
  InvestorModel? get currentDetailedInvestor => _currentDetailedInvestor;
  
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

    await Future.wait([
      loadInvestors(),
      loadAiRecommendations(),
      _loadReceived(),
      _loadSent(),
    ]);

    _isLoading = false;
    notifyListeners();
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
      _currentDetailedInvestor = response.data;
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

  // 2. Connection Lifecycle
  Future<void> _loadReceived() async {
    final response = await _service.getReceivedConnections();
    if (response.isSuccess) {
      final all = response.data ?? [];
      // Include all states to ensure Detail View can reflect status changes (Accepted, Rejected, Withdrawn, etc.)
      _receivedConnections = all.map((c) => c.copyWith(isReceived: true)).toList();
    }
  }

  Future<void> _loadSent() async {
    final response = await _service.getSentConnections();
    if (response.isSuccess) {
      final all = response.data ?? [];
      // Include all states to ensure Detail View can reflect status changes (Accepted, Rejected, Withdrawn, etc.)
      _sentConnections = all.map((c) => c.copyWith(isReceived: false)).toList();
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
  Future<void> updateRequest(dynamic id, String message) async {} 
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
      notifyListeners();
      
      final response = await _service.addToWatchlist(investorId);
      if (!response.isSuccess) {
        // Rollback on failure
        _investors[index] = _investors[index].copyWith(isFavorite: !isNowFavorite);
        notifyListeners();
        return false;
      }
      return true;
    }
    return false;
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
