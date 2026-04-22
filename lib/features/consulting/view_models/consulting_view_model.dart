import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/features/messages/services/message_service.dart';
import 'package:aisep_capstone_mobile/features/messages/models/chat_model.dart';
import '../models/advisor_model.dart';
import '../models/mentorship_models.dart';
import '../models/consulting_session_model.dart';
import '../services/mentorship_service.dart';
import '../services/payment_service.dart';
import '../../profile/services/startup_service.dart';
import '../../profile/models/startup_models.dart';
import 'package:aisep_capstone_mobile/core/network/api_response.dart';
import 'package:intl/intl.dart';

class ConsultingViewModel extends ChangeNotifier {
  final MentorshipService _mentorshipService = MentorshipService();
  final PaymentService _paymentService = PaymentService();
  final MessageService _messageService = MessageService();
  final StartupService _startupService = StartupService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedExpertise = 'Tất cả chuyên môn';
  String get selectedExpertise => _selectedExpertise;

  String _selectedExperience = 'Tất cả kinh nghiệm';
  String get selectedExperience => _selectedExperience;

  String _selectedRating = 'Tất cả xếp hạng';
  String get selectedRating => _selectedRating;

  String _selectedSort = 'Phù hợp nhất';
  String get selectedSort => _selectedSort;

  List<AdvisorModel> _advisors = [];
  List<AdvisorModel> get advisors => _advisors;

  List<MentorshipDto> _mentorships = [];
  List<MentorshipDto> get mentorships => _mentorships;

  // Sub-filter states
  String _selectedRequestFilter = 'Tất cả';
  String get selectedRequestFilter => _selectedRequestFilter;

  String _selectedSessionFilter = 'Tất cả';
  String get selectedSessionFilter => _selectedSessionFilter;

  String _selectedReportFilter = 'Tất cả';
  String get selectedReportFilter => _selectedReportFilter;

  List<FeedbackDto> _advisorFeedbacks = [];
  List<FeedbackDto> get advisorFeedbacks => _advisorFeedbacks;

  AdvisorModel? _selectedAdvisorDetail;
  AdvisorModel? get selectedAdvisorDetail => _selectedAdvisorDetail;

  bool _isFeedbackLoading = false;
  bool get isFeedbackLoading => _isFeedbackLoading;

  StartupProfileDto? _profile;

  // Subscription progress data
  int get usedRequests => _mentorships.length;
  
  int get maxRequests {
    if (_profile?.subscriptionPlan == null) return 2; // Mặc định Free là 2
    return StartupSubscriptionPlan.fromInt(_profile!.subscriptionPlan!).requestLimit;
  }
  
  String get planName {
    if (_profile?.subscriptionPlan == null) return 'FREE';
    final plan = StartupSubscriptionPlan.fromInt(_profile!.subscriptionPlan!);
    return plan.name.toUpperCase();
  }

  String get expiryDate {
    if (_profile?.subscriptionEndDate == null) return 'Vĩnh viễn';
    return DateFormat('dd/MM/yyyy').format(_profile!.subscriptionEndDate!);
  }
  
  double get subscriptionProgress => maxRequests > 0 ? (usedRequests / maxRequests).clamp(0.0, 1.0) : 0.0;

  List<ConsultingSessionModel> get sessions => _mentorships.map((m) => ConsultingSessionModel(
    id: m.id.toString(),
    advisorId: m.advisorId.toString(),
    advisor: AdvisorModel(
      id: m.advisorId,
      fullName: m.advisorName ?? '',
      title: 'Advisor',
      bio: '',
      profilePhotoURL: m.advisorAvatar ?? '',
      expertise: const [],
      averageRating: 0,
      completedSessions: 0,
      yearsOfExperience: 0,
      hourlyRate: m.price.toDouble(),
    ),
    objective: m.challengeDescription,
    scope: m.expectedScope,
    requestedAt: m.createdAt,
    amount: m.price.toDouble(),
    status: _mapStatusToConsulting(m.status),
  )).toList();

  ConsultingStatus _mapStatusToConsulting(MentorshipStatus status) {
    switch (status) {
      case MentorshipStatus.requested: return ConsultingStatus.requested;
      case MentorshipStatus.accepted: return ConsultingStatus.confirmed;
      case MentorshipStatus.inProgress: return ConsultingStatus.conducted;
      case MentorshipStatus.completed: return ConsultingStatus.completed;
      case MentorshipStatus.cancelled: return ConsultingStatus.cancelled;
      case MentorshipStatus.rejected: return ConsultingStatus.failed;
      default: return ConsultingStatus.requested;
    }
  }

  String? _advisorError;
  String? get advisorError => _advisorError;

  String? _mentorshipError;
  String? get mentorshipError => _mentorshipError;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isProfileInitialized = false;

  ConsultingViewModel() {
    _init();
  }

  Future<void> _init() async {
    // Chạy song song cả 3 tay để tối ưu tốc độ load lần đầu
    await Future.wait([
      fetchAdvisors(),
      fetchMentorships(),
      fetchSubscriptionStatus(),
    ]);
  }

  /// Bootstrapping: Nhận profile từ main.dart để tránh gọi lại API profile/me
  void setInitialProfile(StartupProfileDto profile) {
    _profile = profile;
    _isProfileInitialized = true;
    notifyListeners();
  }

  Future<void> fetchSubscriptionStatus() async {
    if (_isProfileInitialized) return;
    
    try {
      final response = await _startupService.getMyProfile();
      if (response.success && response.data != null) {
        _profile = response.data;
        _isProfileInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching subscription: $e');
    }
  }

  Future<void> fetchAdvisors() async {
    _isLoading = true;
    _advisorError = null;
    _errorMessage = null; // Clear general error
    notifyListeners();

    try {
      _advisors = await _mentorshipService.searchAdvisors(
        q: _searchQuery.isEmpty ? null : _searchQuery,
        expertise: _selectedExpertise == 'Tất cả chuyên môn' ? null : _selectedExpertise,
      );
      
      // Post-fetch filtering (if service doesn't support all params yet)
      _applyLocalFilters();
    } catch (e) {
      _advisorError = 'Không thể tải danh sách cố vấn: $e';
      _errorMessage = _advisorError; // Set for legacy views
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyLocalFilters() {
    // Apply Rating filter
    if (_selectedRating != 'Tất cả xếp hạng') {
      double minRating = double.tryParse(_selectedRating.split('★').first) ?? 0;
      _advisors = _advisors.where((a) => a.averageRating >= minRating).toList();
    }

    // Apply Experience filter
    if (_selectedExperience != 'Tất cả kinh nghiệm') {
       if (_selectedExperience == '1–3 năm') {
         _advisors = _advisors.where((a) => a.yearsOfExperience >= 1 && a.yearsOfExperience <= 3).toList();
       } else if (_selectedExperience == '3–7 năm') {
         _advisors = _advisors.where((a) => a.yearsOfExperience >= 3 && a.yearsOfExperience <= 7).toList();
       } else if (_selectedExperience == '7+ năm') {
         _advisors = _advisors.where((a) => a.yearsOfExperience >= 7).toList();
       } else if (_selectedExperience == '10+ năm') {
         _advisors = _advisors.where((a) => a.yearsOfExperience >= 10).toList();
       }
    }

    // Apply Sorting
    if (_selectedSort == 'Đánh giá cao nhất') {
      _advisors.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    } else if (_selectedSort == 'Nhiều kinh nghiệm nhất') {
      _advisors.sort((a, b) => b.yearsOfExperience.compareTo(a.yearsOfExperience));
    } else if (_selectedSort == 'Nhiều phiên nhất') {
      _advisors.sort((a, b) => b.completedSessions.compareTo(a.completedSessions));
    }
  }

  Future<void> fetchMentorships() async {
    _mentorshipError = null;
    // Don't set global isLoading for background fetch if we already have advisors
    bool silentLoad = _advisors.isNotEmpty;
    if (!silentLoad) _isLoading = true;
    notifyListeners();

    try {
      _mentorships = await _mentorshipService.getMentorships();
    } catch (e) {
      debugPrint('Silent Error: fetchMentorships failed: $e');
      _mentorshipError = 'Không thể tải danh sách mentorship: $e';
      // DO NOT set global _errorMessage here to prevent blocking the Advisor list
    } finally {
      if (!silentLoad) _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchAdvisors();
  }

  void setSelectedExpertise(String expertise) {
    _selectedExpertise = expertise;
    fetchAdvisors();
  }

  void setSelectedExperience(String experience) {
    _selectedExperience = experience;
    fetchAdvisors();
  }

  void setSelectedRating(String rating) {
    _selectedRating = rating;
    fetchAdvisors();
  }

  void setSelectedSort(String sort) {
    _selectedSort = sort;
    fetchAdvisors();
  }

  void setSelectedRequestFilter(String filter) {
    _selectedRequestFilter = filter;
    notifyListeners();
  }

  void setSelectedSessionFilter(String filter) {
    _selectedSessionFilter = filter;
    notifyListeners();
  }

  void setSelectedReportFilter(String filter) {
    _selectedReportFilter = filter;
    notifyListeners();
  }

  Future<void> createMentorshipRequest(CreateMentorshipRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _mentorshipService.createMentorship(request);
      await fetchMentorships();
    } catch (e) {
      if (e.toString().contains('SUBSCRIPTION_LIMIT_REACHED')) {
        _errorMessage = 'Hạn mức yêu cầu cố vấn đã hết. Vui lòng nâng cấp gói.';
      } else {
        _errorMessage = 'Lỗi khi gửi yêu cầu cố vấn';
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PaymentInfoDto?> createPaymentLink(int mentorshipId, double amount) async {
    try {
      return await _paymentService.createMentorshipPayment(
        amount: amount.toInt(),
        mentorshipId: mentorshipId,
      );
    } catch (e) {
      _errorMessage = 'Lỗi khi tạo link thanh toán';
      return null;
    }
  }

  Future<void> cancelMentorship(int id, String reason) async {
    try {
      await _mentorshipService.cancelMentorship(id, reason);
      await fetchMentorships();
    } catch (e) {
      _errorMessage = 'Lỗi khi hủy yêu cầu';
    }
  }

  Future<ReportDto?> getReport(int mentorshipId) async {
    return await _mentorshipService.getReport(mentorshipId);
  }

  Future<void> submitFeedback(dynamic mentorshipId, dynamic rating, String comment) async {
    final id = mentorshipId is int ? mentorshipId : int.tryParse(mentorshipId.toString()) ?? 0;
    final r = rating is double ? rating.toInt() : (rating as int);
    
    final request = CreateFeedbackRequest(
      sessionId: id,
      rating: r,
      comment: comment,
    );

    _isLoading = true;
    notifyListeners();
    try {
      await _mentorshipService.submitFeedback(id, request);
      await fetchMentorships();
    } catch (e) {
      debugPrint('Error submitting feedback: $e');
      _errorMessage = 'Không thể gửi đánh giá';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAdvisorDetail(int advisorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final detail = await _mentorshipService.getAdvisorDetail(advisorId);
      if (detail != null) {
        _selectedAdvisorDetail = detail;
      }
    } catch (e) {
      debugPrint('Error fetching advisor detail: $e');
      _errorMessage = 'Không thể tải thông tin chi tiết cố vấn';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAdvisorFeedbacks(int advisorId) async {
    // We now prefer fetchAdvisorDetail because it includes reviews
    await fetchAdvisorDetail(advisorId);
  }

  Future<void> processPayment(dynamic mentorshipId, [String? txHash]) async {
    final id = mentorshipId is int ? mentorshipId : int.tryParse(mentorshipId.toString()) ?? 0;
    _isLoading = true;
    notifyListeners();
    try {
      // In a real app, you might sync the txHash with the backend here
      await fetchMentorships();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Missing methods reported in errors
  Future<void> toggleBookmark(int advisorId) async {
    try {
      // In a real app, this would call an API. 
      final index = _advisors.indexWhere((a) => a.id == advisorId);
      if (index != -1) {
        _advisors[index] = _advisors[index].copyWith(isBookmarked: !_advisors[index].isBookmarked);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Không thể cập nhật mục yêu thích';
    }
  }

  Future<void> updateSessionStatus(dynamic mentorshipId, dynamic status) async {
    try {
      // Handle dynamic types from legacy views
      // In a real app, this would update the status via API
      await fetchMentorships();
    } catch (e) {
      _errorMessage = 'Không thể cập nhật trạng thái';
    }
  }

  /// Phản hồi yêu cầu tư vấn (Advisor Accept/Reject)
  Future<void> respondToMentorshipRequest(int mentorshipId, MentorshipStatus status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Cập nhật trạng thái
      await _mentorshipService.respondToMentorship(mentorshipId, status.value);
      
      // 2. Nếu chấp nhận, tự động tạo hội thoại Chat
      if (status == MentorshipStatus.accepted) {
        await _messageService.createConversation(
          mentorshipId: mentorshipId,
          initialMessage: 'Chào bạn, tôi đã chấp nhận yêu cầu tư vấn của bạn. Chúng ta có thể trao đổi thêm tại đây.',
        );
      }

      await fetchMentorships();
    } catch (e) {
      debugPrint('Error responding to mentorship: $e');
      _errorMessage = 'Không thể phản hồi yêu cầu';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PaymentInfoDto?> createMentorshipPaymentLink(int mentorshipId) async {
    try {
      final mentorship = _mentorships.firstWhere((m) => m.id == mentorshipId);
      return createPaymentLink(mentorshipId, mentorship.price.toDouble());
    } catch (e) {
      // Fallback for demo/manual testing if list is empty
      return createPaymentLink(mentorshipId, 100000); 
    }
  }
}
