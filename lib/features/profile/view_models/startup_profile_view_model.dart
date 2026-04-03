import 'package:flutter/material.dart';
import '../models/startup_profile_model.dart';

class StartupProfileViewModel extends ChangeNotifier {
  late StartupProfileModel _profile;
  bool _isEditMode = false;
  bool _isLoading = false;

  StartupProfileModel get profile => _profile;
  bool get isEditMode => _isEditMode;
  bool get isLoading => _isLoading;

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

  String? selectedStage;
  String? selectedIndustry;
  String? selectedLocation;
  String? selectedMarketScope;
  String? selectedValidationStatus;

  final List<String> stages = ['Ideation', 'MVP', 'Early Traction', 'Scaling'];
  final List<String> industries = ['Fintech', 'Edtech', 'Healthtech', 'AI/ML', 'E-commerce', 'SaaS'];
  final List<String> locations = ['Hà Nội', 'TP. Hồ Chí Minh', 'Đà Nẵng', 'Singapore', 'Khác'];
  final List<String> marketScopes = ['B2B', 'B2C', 'B2G', 'B2B2C'];
  final List<String> validationStatuses = [
    'Chưa có xác thực',
    'Phỏng vấn khách hàng',
    'Thử nghiệm Pilot/POC',
    'Đã có người dùng',
    'Đã có doanh thu'
  ];

  StartupProfileViewModel() {
    _loadMockData();
    _initControllers();
  }

  void _loadMockData() {
    _profile = StartupProfileModel(
      startupName: 'EcoTrack AI',
      tagline: 'Giải pháp tối ưu hóa dấu chân carbon cho doanh nghiệp',
      stage: 'Early Traction',
      industry: 'AI/ML',
      location: 'TP. Hồ Chí Minh',
      websiteLink: 'https://ecotrack.ai',
      productLink: 'https://app.ecotrack.ai',
      logoUrl: 'https://api.dicebear.com/7.x/identicon/svg?seed=EcoTrack',
      problemStatement: 'Các doanh nghiệp đang gặp khó khăn trong việc đo lường và báo cáo phát thải carbon một cách chính xác và thời gian thực.',
      solutionSummary: 'Nền tảng AI tự động thu thập dữ liệu từ các nguồn năng lượng và chuỗi cung ứng để tính toán dấu chân carbon.',
      marketScope: 'B2B',
      productStatus: 'Đã có MVP và 5 khách hàng trả phí',
      currentNeeds: 'Tìm kiếm vòng gọi vốn Seed 500k USD và đối tác chiến lược tại thị trường Singapore.',
      founderNames: 'Nguyễn Văn A\nTrần Thị B',
      founderRoles: 'CEO & Co-founder\nCTO & Co-founder',
      teamSize: '12 thành viên',
      validationStatus: 'Đã có doanh thu',
      metricSummary: 'MRR \$5,000, tốc độ tăng trưởng 15%/tháng.',
    );
    
    selectedStage = _profile.stage;
    selectedIndustry = _profile.industry;
    selectedLocation = _profile.location;
    selectedMarketScope = _profile.marketScope;
    selectedValidationStatus = _profile.validationStatus;
  }

  void _initControllers() {
    nameController = TextEditingController(text: _profile.startupName);
    taglineController = TextEditingController(text: _profile.tagline);
    websiteController = TextEditingController(text: _profile.websiteLink);
    productController = TextEditingController(text: _profile.productLink);
    demoController = TextEditingController(text: _profile.demoLink);
    problemController = TextEditingController(text: _profile.problemStatement);
    solutionController = TextEditingController(text: _profile.solutionSummary);
    needsController = TextEditingController(text: _profile.currentNeeds);
    founderNamesController = TextEditingController(text: _profile.founderNames);
    founderRolesController = TextEditingController(text: _profile.founderRoles);
    teamSizeController = TextEditingController(text: _profile.teamSize);
    metricController = TextEditingController(text: _profile.metricSummary);
  }

  void toggleEditMode() {
    if (_isEditMode) {
      // If canceling, reset controllers
      _initControllers();
      selectedStage = _profile.stage;
      selectedIndustry = _profile.industry;
      selectedLocation = _profile.location;
      selectedMarketScope = _profile.marketScope;
      selectedValidationStatus = _profile.validationStatus;
    }
    _isEditMode = !_isEditMode;
    notifyListeners();
  }

  Future<void> saveProfile() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    _profile = _profile.copyWith(
      startupName: nameController.text,
      tagline: taglineController.text,
      websiteLink: websiteController.text,
      productLink: productController.text,
      demoLink: demoController.text,
      problemStatement: problemController.text,
      solutionSummary: solutionController.text,
      currentNeeds: needsController.text,
      founderNames: founderNamesController.text,
      founderRoles: founderRolesController.text,
      teamSize: teamSizeController.text,
      metricSummary: metricController.text,
      stage: selectedStage,
      industry: selectedIndustry,
      location: selectedLocation,
      marketScope: selectedMarketScope,
      validationStatus: selectedValidationStatus,
    );

    _isEditMode = false;
    _isLoading = false;
    notifyListeners();
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
    super.dispose();
  }
}
