import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/startup_input_field.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/startup_dropdown_field.dart';
import 'package:aisep_capstone_mobile/features/profile/view_models/startup_profile_view_model.dart';
import 'package:aisep_capstone_mobile/features/profile/models/startup_models.dart';
import 'package:aisep_capstone_mobile/features/dashboard/views/dashboard_view.dart';
import 'package:aisep_capstone_mobile/core/services/token_service.dart';
import 'package:aisep_capstone_mobile/features/onboarding/views/startup_onboarding_screen.dart';

class CreateStartupProfileView extends StatefulWidget {
  const CreateStartupProfileView({super.key});

  @override
  State<CreateStartupProfileView> createState() => _CreateStartupProfileViewState();
}

class _CreateStartupProfileViewState extends State<CreateStartupProfileView> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _oneLinerController = TextEditingController();
  final _applicantNameController = TextEditingController();
  final _roleController = TextEditingController();
  final _emailController = TextEditingController();
  
  String? _selectedStage;
  int _selectedStageIndex = 0;
  File? _logoFile;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các giá trị mặc định nếu cần
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _logoFile = File(pickedFile.path);
      });
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn Giai đoạn phát triển')),
      );
      return;
    }

    final viewModel = context.read<StartupProfileViewModel>();

    // Mapping Stage name to Index (0-6)
    _selectedStageIndex = viewModel.stages.indexOf(_selectedStage!);

    final request = CreateStartupProfileRequest(
      companyName: _nameController.text,
      oneLiner: _oneLinerController.text,
      stage: _selectedStageIndex,
      fullNameOfApplicant: _applicantNameController.text,
      roleOfApplicant: _roleController.text,
      contactEmail: _emailController.text,
      logoFile: _logoFile,
    );

    final success = await viewModel.createProfile(request);
    
    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: StartupOnboardingTheme.navyBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: StartupOnboardingTheme.goldAccent, size: 64),
              const SizedBox(height: 16),
              Text(
                'Tạo hồ sơ thành công!',
                style: GoogleFonts.outfit(
                  color: StartupOnboardingTheme.goldAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Chào mừng bạn gia nhập hệ sinh thái AISEP Startup.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const DashboardView()),
                  );
                },
                child: const Text('Bắt đầu ngay'),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StartupProfileViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Thiết lập hồ sơ Startup'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await TokenService.clearAuthData();
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const StartupOnboardingScreen()),
                (route) => false,
              );
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeInDown(
                child: Text(
                  'Chào mừng bạn đến với AISEP!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: StartupOnboardingTheme.goldAccent,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Hoàn thành 6 bước khởi tạo để bắt đầu hành trình gọi vốn.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Center(
                child: GestureDetector(
                  onTap: _pickLogo,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: StartupOnboardingTheme.goldAccent, width: 2),
                      gradient: const LinearGradient(
                        colors: [StartupOnboardingTheme.navyBg, Color(0xFF1A2A4A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: StartupOnboardingTheme.goldAccent.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: _logoFile != null
                        ? ClipOval(
                            child: Image.file(_logoFile!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo, color: StartupOnboardingTheme.goldAccent),
                              const SizedBox(height: 4),
                              Text(
                                'Logo',
                                style: GoogleFonts.workSans(
                                  color: StartupOnboardingTheme.goldAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              StartupInputField(
                label: 'Tên Công ty / Startup (Bắt buộc)',
                hint: 'VD: AISEP.Inc',
                controller: _nameController,
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập tên công ty' : null,
              ),
              const SizedBox(height: 20),

              StartupInputField(
                label: 'Câu giới thiệu ngắn / Slogan (Bắt buộc)',
                hint: 'VD: Nền tảng kết nối nhân tài ứng dụng AI',
                controller: _oneLinerController,
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập khẩu hiệu' : null,
              ),
              const SizedBox(height: 20),

              StartupDropdownField(
                label: 'Giai đoạn phát triển (Bắt buộc)',
                hint: 'Hãy chọn giai đoạn hiện tại',
                items: viewModel.stages,
                onChanged: (val) => setState(() => _selectedStage = val),
              ),
              const SizedBox(height: 20),

              StartupInputField(
                label: 'Họ tên người đăng ký (Bắt buộc)',
                hint: 'VD: Nguyễn Văn A',
                controller: _applicantNameController,
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập họ tên' : null,
              ),
              const SizedBox(height: 20),

              StartupInputField(
                label: 'Chức vụ tại Startup (Bắt buộc)',
                hint: 'VD: Founder, CEO...',
                controller: _roleController,
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập chức vụ' : null,
              ),
              const SizedBox(height: 20),

              StartupInputField(
                label: 'Email liên hệ (Bắt buộc)',
                hint: 'startup@aisep.vn',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập email';
                  if (!v.contains('@')) return 'Email không hợp lệ';
                  return null;
                },
              ),
              
              const SizedBox(height: 48),

              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    viewModel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _handleSubmit,
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Hoàn tất thiết lập hồ sơ'),
                ),
              ),
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () async {
                  await TokenService.clearAuthData();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const StartupOnboardingScreen()),
                      (route) => false,
                    );
                  }
                },
                child: Text(
                  'Đăng xuất và thử lại',
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _oneLinerController.dispose();
    _applicantNameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
