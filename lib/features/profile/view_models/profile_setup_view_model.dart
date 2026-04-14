import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/view_models/base_view_model.dart';
import '../models/startup_profile_model.dart';

class ProfileSetupViewModel extends BaseViewModel {
  final StartupProfileModel _profile = StartupProfileModel();
  
  // Navigation State
  int _currentStep = 0;
  int get currentStep => _currentStep;

  // Step 1 Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController taglineController = TextEditingController();
  
  // Step 2 Controllers
  final TextEditingController problemController = TextEditingController();
  final TextEditingController solutionController = TextEditingController();
  final TextEditingController targetCustomersController = TextEditingController();

  // Legacy/Other Controllers (Keep for compatibility if needed)
  final TextEditingController founderController = TextEditingController();

  // Selection Option List
  final List<String> stages = ['Ý tưởng (Idea)', 'Sản phẩm thử nghiệm (MVP)', 'Pre-seed', 'Seed', 'Series A+'];
  final List<String> industries = ['Agri/Foodtech', 'Healthcare', 'Fintech', 'Edtech', 'E-commerce', 'Khác'];
  final List<String> locations = ['Việt Nam', 'Singapore', 'Hoa Kỳ', 'Châu Âu', 'Khác'];

  String _selectedStage = '';
  String _selectedIndustry = '';
  String _selectedLocation = 'Việt Nam';

  String get selectedStage => _selectedStage;
  String get selectedIndustry => _selectedIndustry;
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
    notifyListeners();
  }

  void selectIndustry(String value) {
    _selectedIndustry = value;
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
      // Mock API Save
      await Future.delayed(const Duration(seconds: 1));
      
      _profile.startupName = nameController.text;
      _profile.tagline = taglineController.text;
      _profile.stage = _selectedStage;
      _profile.industry = _selectedIndustry;
      _profile.location = _selectedLocation;
      _profile.problemStatement = problemController.text;
      _profile.solutionSummary = solutionController.text;
      _profile.marketScope = targetCustomersController.text;

      // Reset to success step
      _currentStep = 2; 
      notifyListeners();
      
    } catch (e) {
      // Handle error
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
