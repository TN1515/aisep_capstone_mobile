import 'dart:io';
import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/features/profile/services/startup_service.dart';
import 'package:aisep_capstone_mobile/features/profile/models/startup_models.dart';
import 'package:aisep_capstone_mobile/features/profile/models/startup_profile_model.dart';
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

  List<String> stages = ['Idea', 'PreSeed', 'Seed', 'SeriesA', 'SeriesB', 'SeriesC', 'Growth'];
  List<IndustryDto> industryList = [
    IndustryDto(id: 1, name: 'Công nghệ & Phần mềm'),
    IndustryDto(id: 2, name: 'Thương mại điện tử'),
    IndustryDto(id: 3, name: 'Công nghệ tài chính (Fintech)'),
    IndustryDto(id: 4, name: 'Công nghệ giáo dục (Edtech)'),
    IndustryDto(id: 5, name: 'Y tế & Chăm sóc sức khỏe'),
    IndustryDto(id: 6, name: 'Nông nghiệp (Agri/Foodtech)'),
    IndustryDto(id: 7, name: 'Năng lượng xanh'),
    IndustryDto(id: 8, name: 'Khác'),
  ];
  List<TeamMemberDto> teamMembers = [];
  
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
      final indResponse = await _service.getIndustries();
      if (indResponse.success && indResponse.data != null) {
        industryList = indResponse.data!;
      }

      final response = await _service.getMyProfile();
      if (response.success && response.data != null) {
        _profileDto = response.data;
        _mapDtoToModel();
        await loadTeamMembers();
      }
    } catch (_) {
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
    );

    selectedStage = profile.stage;
    selectedIndustryId = profile.industryId;
    selectedIndustryName = profile.industry;
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

  void setLogo(File file) {
    _newLogoFile = file;
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
    super.dispose();
  }
}
