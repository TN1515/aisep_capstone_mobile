import 'package:flutter/material.dart';
import '../models/advisor_model.dart';
import '../models/consulting_session_model.dart';

class ConsultingViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedExpertise = 'Tất cả';
  String get selectedExpertise => _selectedExpertise;

  List<AdvisorModel> _advisors = [];
  List<AdvisorModel> get advisors {
    return _advisors.where((a) {
      final matchesSearch = a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.expertise.any((e) => e.toLowerCase().contains(_searchQuery.toLowerCase()));
      
      final matchesExpertise = _selectedExpertise == 'Tất cả' || 
          a.expertise.map((e) => e.toLowerCase()).contains(_selectedExpertise.toLowerCase());
          
      return matchesSearch && matchesExpertise;
    }).toList();
  }

  List<ConsultingSessionModel> _sessions = [];
  List<ConsultingSessionModel> get sessions => _sessions;

  ConsultingViewModel() {
    _initializeMockData();
  }

  void _initializeMockData() {
    _advisors = [
      AdvisorModel(
        id: 'adv1',
        name: 'Trần Văn A',
        title: 'Chuyên gia Tài chính & Gọi vốn',
        bio: 'Hơn 15 năm kinh nghiệm trong lĩnh vực ngân hàng và đầu tư mạo hiểm.',
        avatarUrl: 'https://i.pravatar.cc/150?u=adv1',
        expertise: ['Fintech', 'Fundraising', 'Tài chính'],
        rating: 4.9,
        totalSessions: 125,
        yearsExperience: 15,
        hourlyRate: 2000000,
        isBookmarked: true,
        ratingDistribution: {5: 100, 4: 20, 3: 5, 2: 0, 1: 0},
        certifications: ['CFA Level 3', 'MBA Harvard'],
      ),
        AdvisorModel(
          id: 'adv2',
          name: 'Nguyễn Thị B',
          title: 'Chuyên gia Marketing & Growth',
          bio: 'Đã hỗ trợ hơn 50 startup scale-up thành công tại thị trường SEA.',
          avatarUrl: 'https://i.pravatar.cc/150?u=adv2',
          expertise: ['Marketing', 'Growth Hacking', 'SaaS'],
          rating: 4.8,
        totalSessions: 89,
        yearsExperience: 10,
        hourlyRate: 1500000,
        ratingDistribution: {5: 65, 4: 15, 3: 5, 2: 3, 1: 1},
        certifications: ['Certified Growth Hacker', 'Google Marketing Professional'],
      ),
      AdvisorModel(
        id: 'adv3',
        name: 'Phạm Minh C',
        title: 'AI Architect & Data Scientist',
        bio: 'Chuyên gia xây dựng hệ thống AI quy mô lớn và phân tích dữ liệu người dùng.',
        avatarUrl: 'https://i.pravatar.cc/150?u=adv3',
        expertise: ['AI & Data', 'Machine Learning', 'Python'],
        rating: 4.95,
        totalSessions: 210,
        yearsExperience: 12,
        hourlyRate: 3000000,
        ratingDistribution: {5: 180, 4: 25, 3: 5, 2: 0, 1: 0},
        certifications: ['AWS Certified Machine Learning', 'NVIDIA AI Tech Partner'],
      ),
      AdvisorModel(
        id: 'adv4',
        name: 'Lê Hoàng D',
        title: 'Venture Capitalist & Fundraising Advisor',
        bio: 'Đã từng làm việc tại các quỹ đầu tư lớn, giúp startup gọi vốn vòng Series A, B.',
        avatarUrl: 'https://i.pravatar.cc/150?u=adv4',
        expertise: ['Fundraising', 'Fintech', 'Strategy'],
        rating: 4.7,
        totalSessions: 64,
        yearsExperience: 8,
        hourlyRate: 2500000,
        ratingDistribution: {5: 45, 4: 12, 3: 4, 2: 2, 1: 1},
        certifications: ['Chartered Financial Analyst (CFA)', 'Stanford Venture Capital Program'],
      ),
    ];

    _sessions = [
      ConsultingSessionModel(
        id: 'sess1',
        advisorId: 'adv1',
        advisor: _advisors[0],
        objective: 'Tư vấn Pitch Deck',
        scope: 'Rà soát lại toàn bộ slide và thông số tài chính.',
        requestedAt: DateTime.now().subtract(const Duration(days: 5)),
        amount: 2000000,
        status: ConsultingStatus.completed,
        scheduledAt: DateTime.now().subtract(const Duration(days: 2)),
        reportCards: [
          'Phân tích: Pitch Deck hiện tại thiếu sự nhất quán giữa mô hình kinh doanh và dự báo tài chính.',
          'Giải pháp: Cần chuẩn hóa lại cấu trúc slide theo template của các quỹ Series A quốc tế.',
          'Hành động: Cập nhật Slide số 4, 7 và 12 trước ngày 15/04.',
        ],
        feedbackRating: 5,
        feedbackComment: 'Advisor rất nhiệt tình và tập trung vào các vấn đề cốt lõi.',
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ConsultingSessionModel(
        id: 'sess2',
        advisorId: 'adv3',
        advisor: _advisors[2],
        objective: 'Tối ưu Pipeline dữ liệu',
        scope: 'Thiết kế kiến trúc hệ thống xử lý stream real-time cho 1 triệu user.',
        requestedAt: DateTime.now().subtract(const Duration(days: 1)),
        amount: 3000000,
        status: ConsultingStatus.payable,
        scheduledAt: DateTime.now().add(const Duration(days: 2)),
      ),
      ConsultingSessionModel(
        id: 'sess3',
        advisorId: 'adv2',
        advisor: _advisors[1],
        objective: 'Chiến lược GTM SaaS',
        scope: 'Xây dựng phễu chuyển đổi cho thị trường Singapore.',
        requestedAt: DateTime.now().subtract(const Duration(hours: 4)),
        amount: 1500000,
        status: ConsultingStatus.requested,
      ),
      ConsultingSessionModel(
        id: 'sess4',
        advisorId: 'adv4',
        advisor: _advisors[3],
        objective: 'Gọi vốn vòng Seed',
        scope: 'Review deck và tìm kiếm nhà đầu tư thiên thần.',
        requestedAt: DateTime.now().subtract(const Duration(days: 10)),
        amount: 2500000,
        status: ConsultingStatus.completed,
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        feedbackRating: null, // Session needing feedback
      ),
    ];
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedExpertise(String expertise) {
    _selectedExpertise = expertise;
    notifyListeners();
  }

  void toggleBookmark(String advisorId) {
    final index = _advisors.indexWhere((a) => a.id == advisorId);
    if (index != -1) {
      _advisors[index] = _advisors[index].copyWith(
        isBookmarked: !_advisors[index].isBookmarked,
      );
      notifyListeners();
    }
  }

  Future<void> createRequest(ConsultingSessionModel request) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    _sessions.insert(0, request);
    
    _isLoading = false;
    notifyListeners();
  }

  void updateSessionStatus(String sessionId, ConsultingStatus status) {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      _sessions[index] = _sessions[index].copyWith(status: status);
      notifyListeners();
    }
  }

  Future<void> processPayment(String sessionId, String txHash) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      _sessions[index] = _sessions[index].copyWith(
        status: ConsultingStatus.paid,
        txHash: txHash,
      );
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> submitFeedback(String sessionId, double rating, String comment) async {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      _sessions[index] = _sessions[index].copyWith(
        feedbackRating: rating,
        feedbackComment: comment,
        status: ConsultingStatus.completed,
        completedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }
}
