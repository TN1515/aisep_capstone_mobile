import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/view_models/base_view_model.dart';
import '../models/startup_profile_model.dart';

class ProfileSetupViewModel extends BaseViewModel {
  final StartupProfileModel _profile = StartupProfileModel();
  
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController founderController = TextEditingController();
  final TextEditingController taglineController = TextEditingController();

  // Selection Option List
  final List<String> stages = ['Ý tưởng', 'Sản phẩm thử nghiệm (MVP)', 'Pre-seed', 'Seed', 'Series A+'];
  final List<String> industries = ['Chẩn đoán & Trị liệu', 'Công nghệ tế bào', 'Sản xuất thuốc', 'Cơ sở hạ tầng y tế', 'Khác'];
  final List<String> locations = ['Việt Nam', 'Singapore', 'Hoa Kỳ', 'Châu Âu', 'Khác'];

  String _selectedStage = '';
  String _selectedIndustry = '';
  String _selectedLocation = '';

  String get selectedStage => _selectedStage;
  String get selectedIndustry => _selectedIndustry;
  String get selectedLocation => _selectedLocation;

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

  Future<void> saveAndContinue(BuildContext context, GlobalKey<FormState> formKey, Widget dashboardView) async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);
    try {
      // Mock API Save
      await Future.delayed(const Duration(seconds: 1));
      
      _profile.startupName = nameController.text;
      _profile.founderNames = founderController.text;
      _profile.tagline = taglineController.text;
      _profile.stage = _selectedStage;
      _profile.industry = _selectedIndustry;
      _profile.location = _selectedLocation;

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => dashboardView),
          (route) => false,
        );
      }
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  void skipToDashboard(BuildContext context, Widget dashboardView) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => dashboardView),
      (route) => false,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    founderController.dispose();
    taglineController.dispose();
    super.dispose();
  }
}
