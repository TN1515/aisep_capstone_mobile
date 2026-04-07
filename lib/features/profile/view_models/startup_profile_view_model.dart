import 'dart:io';
import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/features/startup_profile/services/startup_service.dart';
import 'package:aisep_capstone_mobile/features/startup_profile/models/startup_models.dart';
import 'package:aisep_capstone_mobile/features/profile/models/startup_profile_model.dart';

class StartupProfileViewModel extends ChangeNotifier {
  final StartupService _service = StartupService();
  
  StartupProfileDto? _profileDto;
  bool _isEditMode = false;
  bool _isLoading = false;
  String? _errorMessage;
  File? _newLogoFile;

  StartupProfileDto? get profileDto => _profileDto;
  bool get isEditMode => _isEditMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  File? get newLogoFile => _newLogoFile;

  // Controllers for Edit Mode
  late TextEditingController nameController;
  late TextEditingController taglineController;
  late TextEditingController websiteController;
  late TextEditingController productController;
  late TextEditingController demoController;
  late TextEditingController problemController;
  late TextEditingController solutionController;
  late TextEditingController needsController;
  late TextEditingController founderNamesController;
  late TextEditingController founderRolesController;
  late TextEditingController teamSizeController;
  late TextEditingController metricController;

  // Controllers for Onboarding/Create MVP
  late TextEditingController roleController;
  late TextEditingController emailController;

  String? selectedStage;
  int? selectedIndustryId;
  String? selectedIndustryName;
  String? selectedLocation;

  List<String> stages = ['Idea', 'PreSeed', 'Seed', 'SeriesA', 'SeriesB', 'SeriesC', 'Growth'];
  List<IndustryDto> industryList = [
    IndustryDto(id: 1, name: 'Công nghệ & Phần mềm'),
    IndustryDto(id: 2, name: 'Thương mại điện tử'),
    IndustryDto(id: 3, name: 'Công nghệ tài chính (Fintech)'),
    IndustryDto(id: 4, name: 'Công nghệ giáo dục (Edtech)'),
    IndustryDto(id: 5, name: 'Y tế & Chăm sóc sức khỏe'),
    IndustryDto(id: 6, name: 'Nông nghiệp cao'),
    IndustryDto(id: 7, name: 'Năng lượng xanh'),
    IndustryDto(id: 8, name: 'Khác'),
  ];
  List<TeamMemberDto> teamMembers = [];
  final List<String> locations = ['Hà Nội', 'TP. Hồ Chí Minh', 'Đà Nẵng', 'Singapore', 'Khác'];
  
  // Quick mapping for backward compatibility with UI model
  late StartupProfileModel profile;

  StartupProfileViewModel() {
    _initEmptyProfile();
    _initControllers();
    loadProfile();
  }

  void _initEmptyProfile() {
    profile = StartupProfileModel(
       startupName: 'Đang tải...',
       tagline: 'Vui lòng đợi...',
       logoUrl: 'https://api.dicebear.com/7.x/identicon/svg?seed=loading',
    );
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Tải danh sách ngành nghề - Cập nhật thông minh
      final indResponse = await _service.getIndustries();
      if (indResponse.success && indResponse.data != null && indResponse.data!.isNotEmpty) {
        industryList = indResponse.data!;
      }

      // 2. Tải thông tin Profile cá nhân
      final response = await _service.getMyProfile();
      if (response.success && response.data != null) {
        _profileDto = response.data;
        _mapDtoToModel();
        await loadTeamMembers(); // Tải team ngay sau khi có profile
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _mapDtoToModel() {
    if (_profileDto == null) return;
    
    // Mapping Stage from int to String if necessary
    String stageName = 'Idea';
    if (_profileDto!.stage != null) {
      if (_profileDto!.stage is int) {
        int idx = _profileDto!.stage as int;
        if (idx >= 0 && idx < stages.length) {
          stageName = stages[idx];
        }
      } else {
        stageName = _profileDto!.stage.toString();
      }
    }

    profile = StartupProfileModel(
      startupName: _profileDto!.companyName,
      tagline: _profileDto!.oneLiner,
      stage: stageName,
      industry: _profileDto!.industryName ?? 'Chưa xác định',
      location: _profileDto!.location ?? 'Chưa cập nhật',
      websiteLink: _profileDto!.website ?? '',
      logoUrl: _profileDto!.logoUrl ?? 'https://api.dicebear.com/7.x/identicon/svg?seed=${_profileDto!.companyName}',
      problemStatement: _profileDto!.description ?? '',
    );

    selectedStage = _profileDto!.stage;
    selectedIndustryId = _profileDto!.industryId;
    selectedIndustryName = _profileDto!.industryName;
    selectedLocation = _profileDto!.location;
    
    _initControllers();
  }

  // MAPPING API: Tạo hồ sơ mới (POST)
  Future<bool> createProfile(CreateStartupProfileRequest request) async {
    _isLoading = true;
    notifyListeners();
    final response = await _service.createProfile(request);
    
    if (response.success) {
      _profileDto = response.data;
      _mapDtoToModel();
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.error;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- Team Members Logic ---
  Future<void> loadTeamMembers() async {
    final response = await _service.getTeamMembers();
    if (response.success) {
      teamMembers = response.data ?? [];
      notifyListeners();
    }
  }

  Future<bool> addMember({
    required String fullName,
    required String role,
    String? bio,
    File? photo,
  }) async {
    _isLoading = true;
    notifyListeners();
    final response = await _service.addTeamMember(
      fullName: fullName,
      role: role,
      bio: bio,
      photo: photo,
    );
    
    if (response.success && response.data != null) {
      teamMembers.add(response.data!);
      _isLoading = false;
      return true;
    } else {
      _isLoading = false;
      return false;
    }
  }

  void _initControllers() {
    nameController = TextEditingController(text: profile.startupName);
    taglineController = TextEditingController(text: profile.tagline);
    websiteController = TextEditingController(text: profile.websiteLink);
    productController = TextEditingController(text: profile.productLink);
    demoController = TextEditingController(text: profile.demoLink);
    problemController = TextEditingController(text: profile.problemStatement);
    solutionController = TextEditingController(text: profile.solutionSummary);
    needsController = TextEditingController(text: profile.currentNeeds);
    founderNamesController = TextEditingController(text: profile.founderNames);
    founderRolesController = TextEditingController(text: profile.founderRoles);
    teamSizeController = TextEditingController(text: profile.teamSize);
    metricController = TextEditingController(text: profile.metricSummary);
    
    // MVP Controllers
    roleController = TextEditingController(text: profileDto?.roleOfApplicant ?? '');
    emailController = TextEditingController(text: profileDto?.contactEmail ?? '');
  }

  void toggleEditMode() {
    if (_isEditMode) {
      _mapDtoToModel(); // Reset to original data
      _newLogoFile = null;
    }
    _isEditMode = !_isEditMode;
    notifyListeners();
  }

  void setLogo(File file) {
    _newLogoFile = file;
    notifyListeners();
  }

  Future<void> saveProfile() async {
    if (_profileDto == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Ánh xạ Stage từ chuỗi sang Index (0-6)
      int stageIndex = stages.indexOf(selectedStage ?? (profile.stage));
      if (stageIndex == -1) stageIndex = 0;

      final request = CreateStartupProfileRequest(
        companyName: nameController.text,
        oneLiner: taglineController.text,
        stage: stageIndex,
        fullNameOfApplicant: _profileDto?.companyName ?? nameController.text, // Tạm thời dùng CompanyName nếu null
        roleOfApplicant: roleController.text,
        contactEmail: emailController.text,
        industryId: selectedIndustryId ?? (_profileDto?.industryId ?? 1),
        website: websiteController.text,
        description: problemController.text,
        location: selectedLocation,
        businessCode: _profileDto!.businessCode,
        logoFile: _newLogoFile,
      );

      // MAPPING API: Gọi API Update (PUT)
      final response = await _service.updateProfile(request);
      
      if (response.success) {
        await loadProfile(); // Load lại dữ liệu mới sau khi lưu
        _isEditMode = false;
        _newLogoFile = null;
      }
    } catch (_) {
      // Xử lý lỗi
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    taglineController.dispose();
    websiteController.dispose();
    productController.dispose();
    demoController.dispose();
    problemController.dispose();
    solutionController.dispose();
    needsController.dispose();
    founderNamesController.dispose();
    founderRolesController.dispose();
    teamSizeController.dispose();
    metricController.dispose();
    roleController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
