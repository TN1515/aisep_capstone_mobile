import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/view_models/base_view_model.dart';
import 'package:aisep_capstone_mobile/features/kyc/views/kyc_status_view.dart';

enum KycStatus { none, pending, verified, rejected, infoRequired }

class KycViewModel extends BaseViewModel {
  bool isIncorporated;
  KycStatus status = KycStatus.none;
  String? rejectionReason;
  
  // Form Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController taxOrDescriptionController = TextEditingController();
  final TextEditingController repNameController = TextEditingController();
  final TextEditingController workEmailController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  
  String selectedRole = '';
  String? uploadedFileName;
  bool isFileUploading = false;
  bool isCommitted = false;

  final List<String> roles = [
    'Founder', 
    'Co-founder', 
    'Người đại diện pháp luật', 
    'Người được ủy quyền'
  ];

  KycViewModel({required this.isIncorporated, this.status = KycStatus.none}) {
    // Add listeners to notify UI when user types
    nameController.addListener(notifyListeners);
    taxOrDescriptionController.addListener(notifyListeners);
    repNameController.addListener(notifyListeners);
    workEmailController.addListener(notifyListeners);
    linkController.addListener(notifyListeners);
  }

  void toggleIncorporated(bool value) {
    if (isIncorporated != value) {
      isIncorporated = value;
      // Clear relevant fields when switching types for a fresh start
      nameController.clear();
      taxOrDescriptionController.clear();
      uploadedFileName = null;
      notifyListeners();
    }
  }

  Future<void> handleUpload() async {
    isFileUploading = true;
    notifyListeners();

    // Mock upload delay
    await Future.delayed(const Duration(seconds: 2));

    uploadedFileName = isIncorporated ? 'Giay_Phep_Kinh_Doanh.pdf' : 'Pitch_Deck_Minh_Chung.pdf';
    isFileUploading = false;
    notifyListeners();
  }

  void removeFile() {
    uploadedFileName = null;
    notifyListeners();
  }

  void selectRole(String role) {
    selectedRole = role;
    notifyListeners();
  }

  void setCommitted(bool? value) {
    isCommitted = value ?? false;
    notifyListeners();
  }

  bool canSubmit() {
    bool baseInfoValid = nameController.text.isNotEmpty && 
                         taxOrDescriptionController.text.isNotEmpty && 
                         repNameController.text.isNotEmpty &&
                         workEmailController.text.contains('@') &&
                         selectedRole.isNotEmpty;
    
    return baseInfoValid && uploadedFileName != null && isCommitted;
  }

  Future<void> submitKyc(BuildContext context) async {
    if (!canSubmit()) return;

    setLoading(true);
    clearError();

    try {
      // Mock API Submission
      await Future.delayed(const Duration(seconds: 2));

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const KycStatusView()),
          (route) => false,
        );
      }
    } catch (e) {
      setError('Gửi hồ sơ thất bại. Vui lòng kiểm tra lại kết nối.');
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    taxOrDescriptionController.dispose();
    repNameController.dispose();
    workEmailController.dispose();
    linkController.dispose();
    super.dispose();
  }
}
