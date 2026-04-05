import 'package:flutter/material.dart';
import '../models/connection_model.dart';
import '../models/investor_model.dart';
import '../models/connection_request_model.dart';

class ConnectionViewModel extends ChangeNotifier {
  // Singleton pattern for easy sharing across the module
  static final ConnectionViewModel instance = ConnectionViewModel._internal();
  factory ConnectionViewModel() => instance;
  ConnectionViewModel._internal() {
    _loadMockData();
  }

  List<ConnectionModel> _receivedRequests = [];
  List<ConnectionModel> _sentRequests = [];
  List<ConnectionModel> _activeConnections = [];
  List<ConnectionModel> _history = [];
  
  // Discovery State
  List<InvestorModel> _interestedInvestors = [];
  List<InvestorModel> _discoveryResults = [];
  
  bool _isLoading = false;
  String _searchQuery = '';
  
  // Advanced Filter States
  final Set<String> _selectedStages = {};
  final Set<String> _selectedIndustries = {};
  String? _selectedDealSize;
  
  // Getters
  List<ConnectionModel> get receivedRequests => _receivedRequests;
  List<ConnectionModel> get sentRequests => _sentRequests;
  List<ConnectionModel> get activeConnections => _activeConnections;
  List<ConnectionModel> get history => _history;
  List<InvestorModel> get interestedInvestors => _interestedInvestors;
  List<InvestorModel> get discoveryResults => _discoveryResults.isEmpty && _searchQuery.isEmpty ? _interestedInvestors : _discoveryResults;
  List<InvestorModel> get favoriteInvestors => _interestedInvestors.where((i) => i.isFavorite).toList();
  
  Set<String> get selectedStages => _selectedStages;
  Set<String> get selectedIndustries => _selectedIndustries;
  String? get selectedDealSize => _selectedDealSize;
  
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  void _loadMockData() {
    _isLoading = true;
    notifyListeners();

    // 1. Mock Discovery / Interested Investors
    _interestedInvestors = [
      InvestorModel(
        id: 'inv_1',
        name: 'Nguyễn Văn A',
        organization: 'VinaCapital',
        position: 'Investment Director',
        isVerified: true,
        isFavorite: true,
        thesis: 'Tập trung vào các startup công nghệ giai đoạn Series A tại Đông Nam Á.',
        preferredIndustries: ['Fintech', 'AI', 'SaaS'],
        preferredStages: ['Series A', 'Late Seed'],
        preferredGeographies: ['Vietnam', 'Singapore'],
        marketScope: 'Regional',
        supportOffered: 'Strategic advice, network access, and follow-on funding.',
        matchScore: 0.95,
      ),
      InvestorModel(
        id: 'inv_2',
        name: 'Trần Thị B',
        organization: 'CyberAgent Capital',
        position: 'Partner',
        isFavorite: false,
        thesis: 'Săn tìm các đơn vị tiên phong trong lĩnh vực chuyển đổi số.',
        preferredIndustries: ['eCommerce', 'Logistics', 'EdTech'],
        preferredStages: ['Seed', 'Pre-Series A'],
        preferredGeographies: ['Vietnam', 'Indonesia'],
        marketScope: 'Global',
        supportOffered: 'Go-to-market strategy and operational support.',
        matchScore: 0.88,
      ),
      InvestorModel(
        id: 'inv_3',
        name: 'Mekong Venture',
        organization: 'Mekong Capital',
        position: 'Investment Team',
        isFavorite: false,
        thesis: 'Đầu tư vào các doanh nghiệp tiêu dùng có tốc độ tăng trưởng cao.',
        preferredIndustries: ['Consumer', 'Retail', 'Healthcare'],
        preferredStages: ['Growth', 'Series B'],
        preferredGeographies: ['Vietnam'],
        marketScope: 'Domestic',
        supportOffered: 'Excellence in Execution and talent acquisition.',
        matchScore: 0.75,
      ),
    ];

    // 2. Mock Received Requests
    _receivedRequests = [
      ConnectionModel(
        id: 'req_r_1',
        name: 'Lê Mai Anh',
        organization: 'Mekong Capital',
        position: 'Investment Officer',
        role: ConnectionRole.investor,
        status: ConnectionStatus.received,
        bio: 'Hỗ trợ các doanh nghiệp trong lĩnh vực tiêu dùng và bán lẻ.',
        tags: ['Consumer', 'Retail'],
        matchScore: 0.91,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 12)),
        requestId: 'cr_1',
      ),
    ];

    // 3. Mock Sent Requests
    _sentRequests = [
      ConnectionModel(
        id: 'req_s_1',
        name: 'Nguyễn Văn A',
        organization: 'IDG Ventures',
        position: 'General Partner',
        role: ConnectionRole.investor,
        status: ConnectionStatus.pending,
        bio: 'Tìm kiếm cơ hội trong lĩnh vực EdTech.',
        tags: ['EdTech', 'Media'],
        matchScore: 0.82,
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
        requestId: 'cr_2',
      ),
    ];

    // 4. Mock History / Active
    _history = [
      ConnectionModel(
        id: 'h_1',
        name: 'Phan Anh Tuấn',
        organization: 'Do Ventures',
        position: 'Associate',
        role: ConnectionRole.investor,
        status: ConnectionStatus.rejected,
        bio: 'Đang theo dõi các dự án EdTech.',
        tags: ['EdTech', 'B2C'],
        matchScore: 0.75,
        lastUpdated: DateTime.now().subtract(const Duration(days: 10)),
      ),
      ConnectionModel(
        id: 'h_2',
        name: 'Elena Gilbert',
        organization: 'Mystic Ventures',
        position: 'Managing Director',
        role: ConnectionRole.investor,
        status: ConnectionStatus.active,
        bio: 'Chuyên gia về Logistics và Chuỗi cung ứng.',
        tags: ['Logistics', 'Supply Chain'],
        matchScore: 0.94,
        lastUpdated: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  // --- ACTIONS ---

  void setSearchQuery(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _discoveryResults = [];
    } else {
      _discoveryResults = _interestedInvestors
          .where((i) => i.name.toLowerCase().contains(query.toLowerCase()) || 
                       (i.organization?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    }
    notifyListeners();
  }

  void toggleFavorite(String investorId) {
    final index = _interestedInvestors.indexWhere((i) => i.id == investorId);
    if (index != -1) {
      _interestedInvestors[index] = _interestedInvestors[index].copyWith(
        isFavorite: !_interestedInvestors[index].isFavorite,
      );
      notifyListeners();
    }
  }

  void toggleStage(String stage) {
    if (_selectedStages.contains(stage)) {
      _selectedStages.remove(stage);
    } else {
      _selectedStages.add(stage);
    }
    notifyListeners();
  }

  void toggleIndustry(String industry) {
    if (_selectedIndustries.contains(industry)) {
      _selectedIndustries.remove(industry);
    } else {
      _selectedIndustries.add(industry);
    }
    notifyListeners();
  }

  void setSelectedDealSize(String? size) {
    _selectedDealSize = size;
    notifyListeners();
  }

  void resetFilters() {
    _selectedStages.clear();
    _selectedIndustries.clear();
    _selectedDealSize = null;
    notifyListeners();
  }

  Future<void> sendRequest(String investorId, String message) async {
    _isLoading = true;
    notifyListeners();
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateRequest(String requestId, String newMessage) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> cancelRequest(String requestId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> acceptRequest(String requestId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> rejectRequest(String requestId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
  }
}
