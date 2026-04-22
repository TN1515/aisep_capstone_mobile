import 'dart:io';
import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/features/profile/services/startup_service.dart';
import 'package:aisep_capstone_mobile/features/profile/models/startup_models.dart';
import 'package:aisep_capstone_mobile/features/profile/models/startup_profile_model.dart';
import 'package:aisep_capstone_mobile/core/network/api_response.dart';
import 'package:intl/intl.dart';

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
  int? get startupId => _profileDto?.startupId;

  // 1. Core Info Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController taglineController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  // 2. Industry & Stage
  String? selectedStage;
  int? selectedIndustryId;
  String? selectedIndustryName;
  final TextEditingController subIndustryController = TextEditingController();
  DateTime? foundedDate;
  final TextEditingController locationController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  // 3. Financials
  final TextEditingController fundingSoughtController = TextEditingController();
  final TextEditingController fundingRaisedController = TextEditingController();
  DateTime? lastFundingDate;
  final TextEditingController revenueController = TextEditingController();
  final TextEditingController valuationController = TextEditingController();

  // 4. Contact Info
  final TextEditingController applicantNameController = TextEditingController();
  final TextEditingController applicantRoleController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController linkedinController = TextEditingController();

  // 5. Additional Detailed Info
  final TextEditingController problemController = TextEditingController();
  final TextEditingController solutionController = TextEditingController();
  final TextEditingController marketScopeController = TextEditingController();
  final TextEditingController productStatusController = TextEditingController();
  final TextEditingController tractionIndexController = TextEditingController();
  final TextEditingController teamSizeController = TextEditingController();
  final TextEditingController businessCodeController = TextEditingController();
  final TextEditingController metricSummaryController = TextEditingController();

  List<String> stages = ['Idea', 'Pre-seed', 'Seed', 'Series A', 'Series B', 'Series C', 'Growth'];
  List<IndustryDto> industryList = [];
  List<IndustryDto> subIndustryList = [];
  IndustryDto? selectedParentIndustry;

  // 6. Team Member Form Controllers
  final TextEditingController teamMemberNameController = TextEditingController();
  final TextEditingController teamMemberRoleController = TextEditingController();
  final TextEditingController teamMemberTitleController = TextEditingController();
  final TextEditingController teamMemberBioController = TextEditingController();
  final TextEditingController teamMemberLinkedInController = TextEditingController();
  final TextEditingController teamMemberExpController = TextEditingController();
  final TextEditingController teamMemberParticipationController = TextEditingController();
  
  bool isFounderMember = false;
  File? memberPhotoFile;

  final List<String> marketScopeOptions = [
    'Chọn loại hình',
    'B2B (Business to Business)',
    'B2C (Business to Consumer)',
    'B2B2C',
    'B2G (Business to Government)',
  ];

  final List<String> productStatusOptions = [
    'Chọn trạng thái',
    'Đang phát triển',
    'Bản mẫu (MVP)',
    'Thử nghiệm (Beta)',
    'Đã ra mắt (Launched)',
  ];

  List<TeamMemberDto> teamMembers = [];
  
  late StartupProfileModel profile;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  StartupProfileViewModel() {
    _initEmptyProfile();
    _initControllers();
    // loadProfile() removed to avoid double-fetching during startup
  }

  void _initEmptyProfile() {
    profile = StartupProfileModel(
       startupName: 'Chưa cập nhật',
       tagline: 'Chưa có thông tin giới thiệu',
       logoUrl: 'https://api.dicebear.com/7.x/identicon/svg?seed=new',
    );
  }

  /// Hook để main.dart đẩy dữ liệu vào ngay lập tức khi khởi động
  void setInitialData({StartupProfileDto? profileDto, List<IndustryDto>? industries}) {
    if (industries != null) {
      industryList = industries;
    }
    
    if (profileDto != null) {
      _profileDto = profileDto;
      _mapDtoToModel();
      _isInitialized = true;
      notifyListeners();
      // Load thêm đội ngũ ngầm
      loadTeamMembers();
    }
  }

  Future<void> loadProfile({bool force = false}) async {
    if (_isLoading) return;
    if (_isInitialized && !force) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      // Chạy song song các request độc lập để tăng tốc độ load
      final results = await Future.wait([
        _service.getIndustries(mode: 'tree'),
        _service.getMyProfile(),
      ]);

      final indResponse = results[0] as ApiResponse<List<IndustryDto>>;
      final profileResponse = results[1] as ApiResponse<StartupProfileDto?>;

      if (indResponse.success && indResponse.data != null) {
        industryList = indResponse.data!;
      }

      if (profileResponse.success && profileResponse.data != null) {
        _profileDto = profileResponse.data;
        _mapDtoToModel();
        _isInitialized = true;
        await loadTeamMembers();
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _mapDtoToModel() {
    if (_profileDto == null) return;
    
    String stageName = 'Idea';
    if (_profileDto!.stage != null) {
      if (_profileDto!.stage is int) {
        int idx = _profileDto!.stage as int;
        if (idx >= 0 && idx < stages.length) stageName = stages[idx];
      } else {
        stageName = _profileDto!.stage.toString();
      }
    }

    profile = StartupProfileModel(
      startupName: _profileDto!.companyName,
      tagline: _profileDto!.oneLiner,
      description: _profileDto!.description ?? '',
      logoUrl: _profileDto!.logoUrl ?? 'https://api.dicebear.com/7.x/identicon/svg?seed=${_profileDto!.companyName}',
      websiteLink: _profileDto!.website ?? '',
      industryId: _profileDto!.industryId,
      industry: _profileDto!.industryName ?? 'Chưa xác định',
      subIndustry: _profileDto!.subIndustry ?? '',
      stage: stageName,
      foundedDate: _profileDto!.foundedDate,
      location: _profileDto!.location ?? 'Chưa cập nhật',
      country: _profileDto!.country ?? 'Việt Nam',
      fundingAmountSought: _profileDto!.fundingAmountSought ?? 0,
      currentFundingRaised: _profileDto!.currentFundingRaised ?? 0,
      lastFundingDate: _profileDto!.lastFundingDate,
      revenue: _profileDto!.revenue ?? 0,
      valuation: _profileDto!.valuation ?? 0,
      fullNameOfApplicant: _profileDto!.fullNameOfApplicant ?? '',
      roleOfApplicant: _profileDto!.roleOfApplicant ?? '',
      contactEmail: _profileDto!.contactEmail ?? '',
      phoneNumber: _profileDto!.phoneNumber ?? '',
      linkedInUrl: _profileDto!.linkedInUrl ?? '',
      profileStatus: _profileDto!.profileStatus,
      isVisible: _profileDto!.isVisible,
      profileScore: _profileDto!.profileScore,
      createdAt: _profileDto!.createdAt,
      updatedAt: _profileDto!.updatedAt,
      kycStatus: _profileDto!.kycStatus ?? 'Chưa xác thực',
      productStatus: _profileDto!.productStatus ?? '',
      teamSize: _profileDto!.teamSize ?? '',
      problemStatement: _profileDto!.problemStatement ?? '',
      solutionSummary: _profileDto!.solutionSummary ?? '',
      metricSummary: _profileDto!.metricSummary ?? '',
      businessCode: _profileDto!.businessCode ?? '',
      currentNeeds: _profileDto!.currentNeeds ?? [],
      tractionIndex: (_profileDto!.metricSummary != null && _profileDto!.metricSummary!.isNotEmpty) 
          ? _profileDto!.metricSummary! 
          : (_profileDto!.tractionIndex ?? ''),
      approvedAt: _profileDto!.approvedAt,
      marketScope: _profileDto!.marketScope ?? '',
    );

    selectedStage = stages.contains(profile.stage) ? profile.stage : (stages.isNotEmpty ? stages.first : null);
    selectedIndustryId = profile.industryId;
    
    // Auto-detect parent and sub-industry lists from saved ID
    if (selectedIndustryId != null) {
      for (var parent in industryList) {
        final foundSub = parent.subIndustries.any((s) => s.id == selectedIndustryId);
        if (foundSub || parent.id == selectedIndustryId) {
          selectedParentIndustry = parent;
          subIndustryList = parent.subIndustries;
          selectedIndustryName = foundSub 
              ? parent.subIndustries.firstWhere((s) => s.id == selectedIndustryId).name 
              : parent.name;
          break;
        }
      }
    }
    
    foundedDate = profile.foundedDate;
    lastFundingDate = profile.lastFundingDate;
    
    _initControllers();
  }

  void _initControllers() {
    nameController.text = profile.startupName;
    taglineController.text = profile.tagline;
    descriptionController.text = profile.description;
    websiteController.text = profile.websiteLink;
    subIndustryController.text = profile.subIndustry;
    locationController.text = profile.location;
    countryController.text = profile.country;
    fundingSoughtController.text = profile.fundingAmountSought.toString();
    fundingRaisedController.text = profile.currentFundingRaised.toString();
    revenueController.text = profile.revenue.toString();
    valuationController.text = profile.valuation.toString();
    applicantNameController.text = profile.fullNameOfApplicant;
    applicantRoleController.text = profile.roleOfApplicant;
    emailController.text = profile.contactEmail;
    phoneController.text = profile.phoneNumber;
    linkedinController.text = profile.linkedInUrl;
    problemController.text = profile.problemStatement;
    solutionController.text = profile.solutionSummary;
    marketScopeController.text = profile.marketScope;
    productStatusController.text = profile.productStatus;
    tractionIndexController.text = profile.tractionIndex;
    teamSizeController.text = profile.teamSize;
    businessCodeController.text = profile.businessCode;
    metricSummaryController.text = profile.metricSummary;
  }

  void resetMode() {
    _isEditMode = false;
    _newLogoFile = null;
    notifyListeners();
  }

  Future<void> loadTeamMembers() async {
    final response = await _service.getTeamMembers();
    if (response.success) {
      teamMembers = response.data ?? [];
      notifyListeners();
    }
  }

  void toggleEditMode() {
    if (_isEditMode) {
      _mapDtoToModel();
      _newLogoFile = null;
    }
    _isEditMode = !_isEditMode;
    notifyListeners();
  }

  // --- Team Member Operations ---

  void clearMemberForm() {
    teamMemberNameController.clear();
    teamMemberRoleController.clear();
    teamMemberTitleController.clear();
    teamMemberBioController.clear();
    teamMemberLinkedInController.clear();
    teamMemberExpController.clear();
    teamMemberParticipationController.clear();
    isFounderMember = false;
    memberPhotoFile = null;
    notifyListeners();
  }

  void setMemberForm(TeamMemberDto m) {
    teamMemberNameController.text = m.fullName;
    teamMemberRoleController.text = m.role;
    teamMemberTitleController.text = m.title ?? '';
    teamMemberBioController.text = m.bio ?? '';
    teamMemberLinkedInController.text = m.linkedInUrl ?? '';
    teamMemberExpController.text = m.experienceYears?.toString() ?? '';
    teamMemberParticipationController.text = m.participationType ?? '';
    isFounderMember = m.isFounder;
    memberPhotoFile = null;
    notifyListeners();
  }

  Future<void> pickMemberPhoto() async {
    // This usually uses ImagePicker. For now, since I'm just an AI, 
    // I'll assume it's called from the UI which handles the picking 
    // and calls a setter, or I'll just provide the setter.
  }

  void setMemberPhoto(File file) {
    memberPhotoFile = file;
    notifyListeners();
  }

  Future<bool> addMember() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _service.addTeamMember(
        fullName: teamMemberNameController.text,
        role: teamMemberRoleController.text,
        title: teamMemberTitleController.text,
        bio: teamMemberBioController.text,
        experienceYears: int.tryParse(teamMemberExpController.text),
        linkedInUrl: teamMemberLinkedInController.text,
        isFounder: isFounderMember,
        photo: memberPhotoFile,
      );

      if (response.success) {
        await loadTeamMembers();
        clearMemberForm();
        return true;
      } else {
        _errorMessage = response.error;
        return false;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMember(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _service.updateTeamMember(
        id,
        fullName: teamMemberNameController.text,
        role: teamMemberRoleController.text,
        title: teamMemberTitleController.text,
        bio: teamMemberBioController.text,
        experienceYears: int.tryParse(teamMemberExpController.text),
        linkedInUrl: teamMemberLinkedInController.text,
        isFounder: isFounderMember,
        photo: memberPhotoFile,
      );

      if (response.success) {
        await loadTeamMembers();
        clearMemberForm();
        return true;
      } else {
        _errorMessage = response.error;
        return false;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMember(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _service.deleteTeamMember(id);
      if (response.success) {
        await loadTeamMembers();
        return true;
      } else {
        _errorMessage = response.error;
        return false;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setLogo(File file) {
    _newLogoFile = file;
    notifyListeners();
  }

  void removeLogo() {
    _newLogoFile = null;
    profile.logoUrl = ''; // Signal visual deletion
    notifyListeners();
  }

  void addNeed(String need) {
    if (need.trim().isEmpty) return;
    if (!profile.currentNeeds.contains(need.trim())) {
      profile.currentNeeds.add(need.trim());
      notifyListeners();
    }
  }

  void removeNeed(int index) {
    if (index >= 0 && index < profile.currentNeeds.length) {
      profile.currentNeeds.removeAt(index);
      notifyListeners();
    }
  }

  void onParentIndustryChanged(IndustryDto? parent) {
    selectedParentIndustry = parent;
    subIndustryList = parent?.subIndustries ?? [];
    selectedIndustryId = null; // Reset sub-selection
    selectedIndustryName = null;
    notifyListeners();
  }

  void onSubIndustryChanged(int? id, String? name) {
    selectedIndustryId = id;
    selectedIndustryName = name;
    notifyListeners();
  }

  Future<bool> toggleVisibility(bool isVisible) async {
    _isLoading = true;
    notifyListeners();

    final response = await _service.toggleVisibility(isVisible);
    
    if (response.success) {
      profile.isVisible = isVisible;
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

  Future<bool> createProfile(CreateStartupProfileRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.createProfile(request);

      if (response.success) {
        await loadProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.error;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> saveProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      int stageIndex = stages.indexOf(selectedStage ?? 'Idea');
      if (stageIndex == -1) stageIndex = 0;

      final request = CreateStartupProfileRequest(
        companyName: nameController.text,
        oneLiner: taglineController.text,
        description: descriptionController.text,
        website: websiteController.text,
        stage: stageIndex,
        industryId: selectedIndustryId,
        subIndustry: subIndustryController.text,
        foundedDate: foundedDate,
        location: locationController.text,
        country: countryController.text,
        fundingAmountSought: double.tryParse(fundingSoughtController.text),
        currentFundingRaised: double.tryParse(fundingRaisedController.text),
        lastFundingDate: lastFundingDate,
        revenue: double.tryParse(revenueController.text),
        valuation: double.tryParse(valuationController.text),
        fullNameOfApplicant: applicantNameController.text,
        roleOfApplicant: applicantRoleController.text,
        contactEmail: emailController.text,
        phoneNumber: phoneController.text,
        linkedInUrl: linkedinController.text,
        logoFile: _newLogoFile,
        problemStatement: problemController.text,
        solutionSummary: solutionController.text,
        marketScope: marketScopeController.text,
        productStatus: productStatusController.text,
        tractionIndex: tractionIndexController.text,
        teamSize: teamSizeController.text,
        businessCode: businessCodeController.text,
        metricSummary: tractionIndexController.text, // Mapped from Traction Index controller
        currentNeeds: profile.currentNeeds, // Keep existing needs or add controller if needed
      );

      final response = await _service.updateProfile(request);
      
      if (response.success) {
        await loadProfile();
        _isEditMode = false;
        _newLogoFile = null;
      } else {
        _errorMessage = response.error;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    taglineController.dispose();
    descriptionController.dispose();
    websiteController.dispose();
    subIndustryController.dispose();
    locationController.dispose();
    countryController.dispose();
    fundingSoughtController.dispose();
    fundingRaisedController.dispose();
    revenueController.dispose();
    valuationController.dispose();
    applicantNameController.dispose();
    applicantRoleController.dispose();
    emailController.dispose();
    phoneController.dispose();
    linkedinController.dispose();
    problemController.dispose();
    solutionController.dispose();
    marketScopeController.dispose();
    productStatusController.dispose();
    tractionIndexController.dispose();
    teamSizeController.dispose();
    businessCodeController.dispose();
    metricSummaryController.dispose();
    
    teamMemberNameController.dispose();
    teamMemberRoleController.dispose();
    teamMemberBioController.dispose();
    teamMemberLinkedInController.dispose();
    teamMemberExpController.dispose();
    teamMemberParticipationController.dispose();
    super.dispose();
  }
}
