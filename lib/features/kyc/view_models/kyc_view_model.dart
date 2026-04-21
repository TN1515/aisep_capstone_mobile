import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import '../models/kyc_status_model.dart';
import '../services/kyc_service.dart';

enum KycStatus { none, pending, verified, rejected }

class KycViewModel extends ChangeNotifier {
  final KYCService _kycService = KYCService();

  // --- Form State ---
  bool isIncorporated;
  
  // Bộ 1: Có pháp nhân (Incorporated)
  final TextEditingController nameControllerInc = TextEditingController();
  final TextEditingController taxControllerInc = TextEditingController();
  final TextEditingController repNameControllerInc = TextEditingController();
  final TextEditingController workEmailControllerInc = TextEditingController();
  final TextEditingController linkControllerInc = TextEditingController();
  String selectedRoleInc = '';

  // Bộ 2: Chưa có pháp nhân (Not Incorporated)
  final TextEditingController nameControllerNoInc = TextEditingController();
  final TextEditingController descriptionControllerNoInc = TextEditingController();
  final TextEditingController repNameControllerNoInc = TextEditingController();
  final TextEditingController workEmailControllerNoInc = TextEditingController();
  final TextEditingController linkControllerNoInc = TextEditingController();
  String selectedRoleNoInc = '';

  final List<String> roles = ['Founder/CEO', 'CTO', 'COO', 'CFO', 'Khác'];

  bool isFileUploading = false;
  bool isCommitted = false;

  // --- API & Auto-save State ---
  StartupKYCStatusDto? _kycStatusDto;
  String? _originalApprovedType; 
  bool _isLoading = false;
  bool _isSavingDraft = false;
  String? _errorMessage;
  Timer? _debounceTimer;

  // Tách biệt danh sách file minh chứng
  final List<KYCEvidenceFile> _selectedFilesInc = [];
  final List<KYCEvidenceFile> _selectedFilesNoInc = [];

  KycViewModel({this.isIncorporated = true});

  // --- Getters lấy đúng Controller theo hình thức hiện tại ---
  TextEditingController get nameController => isIncorporated ? nameControllerInc : nameControllerNoInc;
  TextEditingController get taxOrDescriptionController => isIncorporated ? taxControllerInc : descriptionControllerNoInc;
  TextEditingController get repNameController => isIncorporated ? repNameControllerInc : repNameControllerNoInc;
  TextEditingController get workEmailController => isIncorporated ? workEmailControllerInc : workEmailControllerNoInc;
  TextEditingController get linkController => isIncorporated ? linkControllerInc : linkControllerNoInc;
  
  String get selectedRole => isIncorporated ? selectedRoleInc : selectedRoleNoInc;
  List<KYCEvidenceFile> get selectedFiles => isIncorporated ? List.unmodifiable(_selectedFilesInc) : List.unmodifiable(_selectedFilesNoInc);

  String? get uploadedFileName {
    final files = selectedFiles;
    if (files.isEmpty) return null;
    final first = files.first;
    if (first.file != null) {
      return basename(first.file!.path);
    }
    return first.remoteName;
  }

  bool get isLoading => _isLoading;
  bool get isSavingDraft => _isSavingDraft;
  String? get errorMessage => _errorMessage;
  String? get rejectionReason => _kycStatusDto?.rejectionReason;
  
  KycStatus get status {
    if (_kycStatusDto == null) return KycStatus.none;
    switch (_kycStatusDto!.status) {
      case KYCStatus.NOT_SUBMITTED:
        return KycStatus.none;
      case KYCStatus.PENDING:
        return KycStatus.pending;
      case KYCStatus.REJECTED:
        return KycStatus.rejected;
      case KYCStatus.APPROVED:
        return KycStatus.verified;
    }
  }

  // --- Actions ---

  void toggleIncorporated(bool value) {
    if (isIncorporated != value) {
      isIncorporated = value;
      notifyListeners();
    }
  }

  void selectRole(String role) {
    if (isIncorporated) {
      selectedRoleInc = role;
    } else {
      selectedRoleNoInc = role;
    }
    notifyListeners();
    triggerAutoSave();
  }

  void setCommitted(bool? value) {
    isCommitted = value ?? false;
    notifyListeners();
  }

  void triggerAutoSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      saveKycDraft();
    });
  }

  Future<void> saveKycDraft() async {
    if (_isLoading || status == KycStatus.pending) return;

    // Nếu đã verified, chỉ lưu nháp nếu người dùng đổi sang loại hình khác loại đã duyệt
    if (status == KycStatus.verified) {
      final currentType = isIncorporated ? 'WITH_LEGAL_ENTITY' : 'WITHOUT_LEGAL_ENTITY';
      if (currentType == _originalApprovedType) return;
    }

    _isSavingDraft = true;
    notifyListeners();

    try {
      await _kycService.saveKycDraft(
        evidenceFiles: isIncorporated ? _selectedFilesInc : _selectedFilesNoInc,
        formData: _getFormDataMap(),
      );
    } catch (e) {
      debugPrint('Lỗi Auto-save: $e');
    } finally {
      _isSavingDraft = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _getFormDataMap() {
    return {
      // Form Có pháp nhân
      'LegalFullName': nameControllerInc.text,
      'EnterpriseCode': taxControllerInc.text,
      'RepresentativeFullName': repNameControllerInc.text, // Có thể dùng chung nếu muốn
      'RepresentativeRole': selectedRoleInc,
      'PublicLink': linkControllerInc.text,
      'WorkEmail': workEmailControllerInc.text,

      // Form Chưa có pháp nhân
      'ProjectName': nameControllerNoInc.text,
      'TaxOrDescription': descriptionControllerNoInc.text, // Dùng cho mô tả ngắn gọn
      
      // Trường định danh loại hình hiện tại
      'StartupVerificationType': isIncorporated ? 'WITH_LEGAL_ENTITY' : 'WITHOUT_LEGAL_ENTITY',
    };
  }

  Future<void> pickFiles(EvidenceFileKind kind) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false, 
      );

      if (result != null && result.files.single.path != null) {
        final platformFile = result.files.single;
        final file = File(platformFile.path!);
        final evidence = KYCEvidenceFile(file: file, kind: kind);
        
        final files = isIncorporated ? _selectedFilesInc : _selectedFilesNoInc;
        final index = files.indexWhere((e) => e.kind == kind);
        if (index != -1) {
          files[index] = evidence;
        } else {
          files.add(evidence);
        }

        notifyListeners();
        triggerAutoSave();
      }
    } catch (e) {
      _errorMessage = 'Không thể chọn file: $e';
      notifyListeners();
    }
  }

  String? getFileNameByKind(EvidenceFileKind kind) {
    try {
      final files = isIncorporated ? _selectedFilesInc : _selectedFilesNoInc;
      final evidence = files.firstWhere((e) => e.kind == kind);
      
      if (evidence.file != null) {
        return basename(evidence.file!.path);
      }
      return evidence.remoteName;
    } catch (_) {
      return null;
    }
  }

  void removeFileByKind(EvidenceFileKind kind) {
    final files = isIncorporated ? _selectedFilesInc : _selectedFilesNoInc;
    files.removeWhere((e) => e.kind == kind);
    notifyListeners();
    triggerAutoSave();
  }

  bool canSubmit() {
    return nameController.text.isNotEmpty && 
           repNameController.text.isNotEmpty && 
           isCommitted;
  }

  Future<void> loadStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _kycService.getKycStatus();
    
    if (response.success && response.data != null) {
      _kycStatusDto = response.data;
      _populateFormFromDto(_kycStatusDto!);
    } else {
      String error = response.error ?? 'Lỗi tải trạng thái KYC';
      if (error.contains('startup profile')) {
        error = 'Bạn cần hoàn tất thông tin hồ sơ Startup trước khi thực hiện xác thực KYC.';
      }
      _errorMessage = error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void _populateFormFromDto(StartupKYCStatusDto dto) {
    // Lưu lại loại hình đã được duyệt để so sánh khi auto-save
    if (dto.status == KYCStatus.APPROVED) {
      _originalApprovedType = dto.startupVerificationType;
    }

    // 1. Cập nhật loại hình hiện tại từ Server
    final String? type = dto.startupVerificationType;
    if (type != null) {
      isIncorporated = type == 'WITH_LEGAL_ENTITY';
    }

    // 2. Nạp dữ liệu vào các bộ controllers một cách ĐỘC LẬP
    // Bộ Có pháp nhân (WITH_LEGAL_ENTITY)
    if (dto.legalFullName != null) nameControllerInc.text = dto.legalFullName!;
    if (dto.enterpriseCode != null) taxControllerInc.text = dto.enterpriseCode!;
    if (dto.representativeFullName != null) repNameControllerInc.text = dto.representativeFullName!;
    if (dto.workEmail != null) workEmailControllerInc.text = dto.workEmail!;
    if (dto.representativeRole != null) selectedRoleInc = dto.representativeRole!;
    if (dto.publicLink != null) linkControllerInc.text = dto.publicLink!;

    // Bộ Chưa có pháp nhân (WITHOUT_LEGAL_ENTITY)
    if (dto.projectName != null) nameControllerNoInc.text = dto.projectName!;
    if (dto.taxOrDescription != null) descriptionControllerNoInc.text = dto.taxOrDescription!; 
    if (dto.representativeFullName != null) repNameControllerNoInc.text = dto.representativeFullName!;
    if (dto.workEmail != null) workEmailControllerNoInc.text = dto.workEmail!;
    if (dto.representativeRole != null) selectedRoleNoInc = dto.representativeRole!;
    if (dto.publicLink != null) linkControllerNoInc.text = dto.publicLink!;

    // 3. Nạp thông tin file minh chứng
    if (dto.evidenceFiles != null) {
      _selectedFilesInc.clear();
      _selectedFilesNoInc.clear();
      dto.evidenceFiles!.forEach((kind, name) {
        final kycFile = KYCEvidenceFile(kind: kind, remoteName: name);
        _selectedFilesInc.add(kycFile);
        _selectedFilesNoInc.add(kycFile);
      });
    }

    notifyListeners();
  }

  Future<void> submitKyc(BuildContext context) async {
    if (!canSubmit()) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _kycService.submitKyc(
      evidenceFiles: isIncorporated ? _selectedFilesInc : _selectedFilesNoInc,
      formData: _getFormDataMap(),
    );
    
    _isLoading = false;
    if (response.success) {
      _kycStatusDto = StartupKYCStatusDto(status: KYCStatus.PENDING);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi hồ sơ thành công!')),
      );
      notifyListeners();
    } else {
      String error = response.error ?? 'Đăng ký thất bại';
      if (error.contains('startup profile')) {
        error = 'Bạn cần hoàn tất thông tin hồ sơ Startup trước khi thực hiện xác thực KYC.';
      }
      _errorMessage = error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $error')),
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    nameControllerInc.dispose();
    taxControllerInc.dispose();
    repNameControllerInc.dispose();
    workEmailControllerInc.dispose();
    linkControllerInc.dispose();
    nameControllerNoInc.dispose();
    descriptionControllerNoInc.dispose();
    repNameControllerNoInc.dispose();
    workEmailControllerNoInc.dispose();
    linkControllerNoInc.dispose();
    super.dispose();
  }
}
