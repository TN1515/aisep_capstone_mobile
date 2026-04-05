import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/startup_input_field.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/chip_selector.dart';
import 'package:aisep_capstone_mobile/core/theme/app_colors.dart';

class OnboardingIdentityFormView extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingIdentityFormView({super.key, required this.onComplete});

  @override
  State<OnboardingIdentityFormView> createState() => _OnboardingIdentityFormViewState();
}

class _OnboardingIdentityFormViewState extends State<OnboardingIdentityFormView> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _taglineController = TextEditingController();
  String _selectedStage = '';
  String _selectedIndustry = '';
  String _selectedLocation = '';

  final List<String> _stages = ['Ý tưởng', 'Sản phẩm thử nghiệm (MVP)', 'Pre-seed', 'Seed', 'Series A+'];
  final List<String> _industries = ['Phát triển thuốc', 'Chẩn đoán', 'Trị liệu', 'Genomics', 'Tin sinh học (Bio-Informatics)'];
  final List<String> _locations = ['Việt Nam', 'Singapore', 'Hoa Kỳ', 'Châu Âu', 'Khác'];

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep(
                      'Tên startup của bạn là gì?',
                      'Nhập tên chính thức hoặc tên dự án.',
                      StartupInputField(
                        label: 'Tên Startup',
                        hint: 'VD: BioCore AI',
                        controller: _nameController,
                        autofocus: true,
                      ),
                    ),
                    _buildStep(
                      'Câu pitch ngắn gọn',
                      'Mô tả sứ mệnh của bạn trong một câu.',
                      StartupInputField(
                        label: 'Slogan / Pitch',
                        hint: 'VD: Chẩn đoán ung thư bằng AI',
                        controller: _taglineController,
                        autofocus: true,
                      ),
                    ),
                    _buildStep(
                      'Giai đoạn hiện tại của bạn?',
                      'Chọn giai đoạn phù hợp nhất.',
                      ChipSelector(
                        options: _stages,
                        selectedOption: _selectedStage,
                        onSelected: (val) => setState(() => _selectedStage = val),
                      ),
                    ),
                    _buildStep(
                      'Lĩnh vực tập trung?',
                      'Chọn lĩnh vực công nghệ sinh học chính.',
                      ChipSelector(
                        options: _industries,
                        selectedOption: _selectedIndustry,
                        onSelected: (val) => setState(() => _selectedIndustry = val),
                      ),
                    ),
                    _buildStep(
                      'Bạn đang ở đâu?',
                      'Chọn nơi đặt trụ sở chính của bạn.',
                      ChipSelector(
                        options: _locations,
                        selectedOption: _selectedLocation,
                        onSelected: (val) => setState(() => _selectedLocation = val),
                      ),
                    ),
                  ],
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
    );
  }

  Widget _buildStep(String title, String sub, Widget child) {
    return Padding(
      padding: const EdgeInsets.all(AppColors.spaceXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: Text(
              title,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 100),
            child: Text(
              sub,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 48),
          FadeIn(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 300),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    double progress = (_currentStep + 1) / 5;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _currentStep > 0 ? () {
                  setState(() => _currentStep--);
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                } : null,
                icon: Icon(
                  Icons.arrow_back,
                  color: _currentStep > 0 ? Theme.of(context).iconTheme.color : Colors.transparent,
                ),
              ),
              Text(
                'Bước ${_currentStep + 1} / 5',
                style: GoogleFonts.workSans(
                  fontWeight: FontWeight.bold,
                  color: StartupOnboardingTheme.goldAccent.withOpacity(0.3),
                ),
              ),
              const SizedBox(width: 48), // Spacer for balance
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: StartupOnboardingTheme.goldAccent.withOpacity(0.05),
              valueColor: const AlwaysStoppedAnimation(StartupOnboardingTheme.goldAccent),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    bool canProceed = false;
    if (_currentStep == 0) canProceed = _nameController.text.isNotEmpty;
    if (_currentStep == 1) canProceed = _taglineController.text.isNotEmpty;
    if (_currentStep == 2) canProceed = _selectedStage.isNotEmpty;
    if (_currentStep == 3) canProceed = _selectedIndustry.isNotEmpty;
    if (_currentStep == 4) canProceed = _selectedLocation.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(AppColors.spaceXL),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canProceed ? _nextStep : null,
          child: const Text('Tiếp tục'),
        ),
      ),
    );
  }
}
