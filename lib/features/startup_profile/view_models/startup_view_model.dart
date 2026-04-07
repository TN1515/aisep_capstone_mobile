import 'dart:io';
import 'package:flutter/material.dart';
import '../models/startup_models.dart';
import '../services/startup_service.dart';

class StartupViewModel extends ChangeNotifier {
  final StartupService _startupService = StartupService();

  StartupProfileDto? _profile;
  List<IndustryDto> _industries = [];
  List<TeamMemberDto> _teamMembers = [];
  bool _isLoading = false;
  String? _errorMessage;

  // --- Getters ---
  StartupProfileDto? get profile => _profile;
  List<IndustryDto> get industries => _industries;
  List<TeamMemberDto> get teamMembers => _teamMembers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasProfile => _profile != null;

  // --- Actions ---

  /// Tải thông tin hồ sơ của tôi
  Future<void> loadMyProfile() async {
    _setLoading(true);
    final response = await _startupService.getMyProfile();
    
    if (response.success) {
      _profile = response.data;
      if (_profile != null) {
        await loadTeamMembers();
      }
    } else {
      _errorMessage = response.error;
    }
    _setLoading(false);
  }

  /// Tải danh sách ngành nghề (Master Data)
  Future<void> loadIndustries() async {
    final response = await _startupService.getIndustries();
    if (response.success) {
      _industries = response.data ?? [];
      notifyListeners();
    }
  }

  /// Tạo hồ sơ mới
  Future<bool> createProfile(CreateStartupProfileRequest request) async {
    _setLoading(true);
    final response = await _startupService.createProfile(request);
    
    if (response.success && response.data != null) {
      _profile = response.data;
      _setLoading(false);
      return true;
    } else {
      _errorMessage = response.error;
      _setLoading(false);
      return false;
    }
  }

  /// Cập nhật hồ sơ
  Future<bool> updateProfile(CreateStartupProfileRequest request) async {
    _setLoading(true);
    final response = await _startupService.updateProfile(request);
    
    if (response.success && response.data != null) {
      _profile = response.data;
      _setLoading(false);
      return true;
    } else {
      _errorMessage = response.error;
      _setLoading(false);
      return false;
    }
  }

  /// Quản lý Team Members
  Future<void> loadTeamMembers() async {
    final response = await _startupService.getTeamMembers();
    if (response.success) {
      _teamMembers = response.data ?? [];
      notifyListeners();
    }
  }

  Future<bool> addMember({
    required String fullName,
    required String role,
    String? bio,
    File? photo,
  }) async {
    _setLoading(true);
    final response = await _startupService.addTeamMember(
      fullName: fullName,
      role: role,
      bio: bio,
      photo: photo,
    );
    
    if (response.success && response.data != null) {
      _teamMembers.add(response.data!);
      _setLoading(false);
      return true;
    } else {
      _errorMessage = response.error;
      _setLoading(false);
      return false;
    }
  }

  // --- Helpers ---

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
