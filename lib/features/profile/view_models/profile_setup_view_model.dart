import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/view_models/base_view_model.dart';
import'package:aisep_capstone_mobile/features/profile/services/startup_service.dart';
import'package:aisep_capstone_mobile/features/profile/models/startup_models.dart';
import '../models/startup_profile_model.dart';
import'package:aisep_capstone_mobile/core/services/token_service.dart';

class ProfileSetupViewModel extends BaseViewModel {
  final StartupService _service = StartupService();
  final StartupProfileModel _profile = StartupProfileModel();
  
  List<IndustryDto> _industryList = [];
  List<IndustryDto> get industryList => _industryList;

  // Industry Hierarchy for Premium Selection
  final List<IndustryCategory> industryCategories = [
    IndustryCategory(
      name: 'Agri/Foodtech',
      subIndustries: [
        'Cold Chain & Logistics',
        'Farm Automation & Robotics',
        'Farmer-to-Market Platforms',
        'Precision Agriculture',
        'Traceability & Food Safety',
      ],
    ),
    IndustryCategory(
      name: 'E-commerce',
      subIndustries: [
        'B2B Commerce',
        'B2C Marketplace',
        'Delivery & Logistics',
        'Food/Grocery Delivery',
        'Social Commerce',
      ],
    ),
    IndustryCategory(
      name: 'Edtech',
      subIndustries: [
        'Coding & STEM Education',
        'K-12 Learning Support',
        'MOOC & Skills Courses',
        'Online Language Learning',
        'Tutor Matching Platforms',
      ],
    ),
    IndustryCategory(
      name: 'Fintech',
      subIndustries: [
        'Blockchain & Crypto',
        'Digital Wallets & Payments',
        'Insurtech',
        'Online Lending',
        'Personal Finance & Investing',
      ],
    ),
    IndustryCategory(
      name: 'Health/Medtech',
      subIndustries: [
        'AI in Diagnosis',
        'Appointment & Health Records',
        'Online Pharmacy',
        'Telehealth',
        'Wearables & Health Tracking',
      ],
    ),
  ];
  // Navigation State
  int _currentStep = 0;
  int get currentStep => _currentStep;

  // Step 1 Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController taglineController = TextEditingController();
  String contactEmail = '';
  
  // Step 2 Controllers
  final TextEditingController problemController = TextEditingController();
  final TextEditingController solutionController = TextEditingController();
  final TextEditingController targetCustomersController = TextEditingController();

  // Legacy/Other Controllers (Keep for compatibility if needed)
  final TextEditingController founderController = TextEditingController();

  // Selection Option List
  final List<String> stages = ['Idea', 'Pre-seed', 'Seed', 'Series A', 'Series B', 'Series C', 'Growth'];
  List<String> industries = ['Đang tải...'];
  final List<String> locations = ['Việt Nam', 'Singapore', 'Hoa Kỳ', 'Châu Âu', 'Khác'];

  ProfileSetupViewModel() {
    _initData();
  }

  Future<void> _initData() async {
    contactEmail = await TokenService.getEmail() ?? '';
    await _fetchIndustries();
    notifyListeners();
  }

  Future<void> _fetchIndustries() async {
    try {
      final response = await _service.getIndustries();
      if (response.success && response.data != null) {
        _industryList = response.data!;
        industries = _industryList.map((e) => e.name).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  String _selectedStage = '';
  String _selectedIndustry = '';
  String _selectedSubIndustry = '';
  String _selectedLocation = 'Việt Nam';

  String get selectedStage => _selectedStage;
  String get selectedIndustry => _selectedIndustry;
  String get selectedSubIndustry => _selectedSubIndustry;
  String get selectedLocation => _selectedLocation;

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep(GlobalKey<FormState> formKey) {
    if (formKey.currentState?.validate() ?? false) {
      if (_currentStep < 2) {
        _currentStep++;
        notifyListeners();
      }
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void selectStage(String value) {
    _selectedStage = value;
    FocusManager.instance.primaryFocus?.unfocus();
    notifyListeners();
  }

  void selectIndustry(String value) {
    _selectedIndustry = value;
    _selectedSubIndustry = ''; // Reset sub-industry when changing industry
    notifyListeners();
  }

  void selectIndustryAndSub(String category, String sub) {
    _selectedIndustry = category;
    _selectedSubIndustry = sub;
    FocusManager.instance.primaryFocus?.unfocus();
    notifyListeners();
  }

  void selectLocation(String value) {
    _selectedLocation = value;
    notifyListeners();
  }

  Future<void> saveAndComplete(BuildContext context, GlobalKey<FormState> formKey, Widget dashboardView) async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);
    try {
      // 1. Chuẩn bị thông tin ứng viên từ TokenService
      final String? userEmail = await TokenService.getUserId(); // This is often used as a key, but let's check
      // For now, use placeholders or pull from Auth if we had it. 
      // Actually, createProfile API requires applicant info.
      
      int stageIndex = stages.indexOf(_selectedStage);
      if (stageIndex == -1) stageIndex = 0;

      int? industryId;
      final industryMatch = _industryList.where((i) => i.name == _selectedIndustry);
      if (industryMatch.isNotEmpty) {
        industryId = industryMatch.first.id;
      }

      final request = CreateStartupProfileRequest(
        companyName: nameController.text.trim(),
        oneLiner: taglineController.text.trim(),
        stage: stageIndex,
        industryId: industryId,
        subIndustry: _selectedSubIndustry.isNotEmpty ? _selectedSubIndustry : null,
        problemStatement: problemController.text.trim(),
        solutionSummary: solutionController.text.trim(),
        marketScope: targetCustomersController.text.trim(),
        location: _selectedLocation,
        country: 'Việt Nam',
        fullNameOfApplicant: 'Founder', // Default since field removed
        roleOfApplicant: 'CEO/Founder', // Default since field removed
        contactEmail: contactEmail.isNotEmpty ? contactEmail : 'startup@aisep.vn',
      );

      // 2. Gọi API thực tế
      final response = await _service.createProfile(request);
      
      if (response.success) {
        // Đánh dấu thành công cục bộ
        _profile.startupName = nameController.text;
        _profile.tagline = taglineController.text;

        _currentStep = 2; 
        notifyListeners();
        
        // 3. Tự động chuyển sang màn hình Dashboard (Home) sau khi hoàn tất
        if (context.mounted) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => dashboardView),
              (route) => false,
            );
          });
        }
      } else {
        // Hiển thị lỗi thông qua base view model mechanism hoặc snackbar
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể lưu hồ sơ: ${response.error}')),
          );
        }
      }
    } catch (e) {
       if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi kết nối: $e')),
          );
        }
    } finally {
      setLoading(false);
    }
  }


  @override
  void dispose() {
    nameController.dispose();
    taglineController.dispose();
    problemController.dispose();
    solutionController.dispose();
    targetCustomersController.dispose();
    founderController.dispose();
    super.dispose();
  }
}
