import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/advisor_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/consulting_session_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/core/utils/toast_utils.dart';
import 'package:uuid/uuid.dart';

class CreateConsultingRequestView extends StatefulWidget {
  final AdvisorModel advisor;

  const CreateConsultingRequestView({Key? key, required this.advisor}) : super(key: key);

  @override
  State<CreateConsultingRequestView> createState() => _CreateConsultingRequestViewState();
}

class _CreateConsultingRequestViewState extends State<CreateConsultingRequestView> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  
  final _objectiveController = TextEditingController();
  final _scopeController = TextEditingController();
  final _notesController = TextEditingController();
  ConsultingMode _mode = ConsultingMode.online;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StartupOnboardingTheme.navyBg,
      appBar: AppBar(
        backgroundColor: StartupOnboardingTheme.navyBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Yêu cầu Tư vấn',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: StartupOnboardingTheme.softIvory,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            _buildAdvisorSummary(),
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: _currentStep == 0 ? _buildStep1() : _buildStep2(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildAdvisorSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(widget.advisor.avatarUrl),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.advisor.name,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: StartupOnboardingTheme.softIvory,
                ),
              ),
              Text(
                widget.advisor.title,
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  color: StartupOnboardingTheme.goldAccent.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepCircle(0, 'Nội dung'),
          Container(width: 48, height: 2, color: _currentStep == 1 ? StartupOnboardingTheme.goldAccent : Colors.white.withOpacity(0.1)),
          _buildStepCircle(1, 'Hình thức'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    bool isCurrent = _currentStep == step;
    bool isDone = _currentStep > step;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isCurrent || isDone ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.navySurface,
            shape: BoxShape.circle,
            border: Border.all(color: isCurrent ? Colors.white : Colors.transparent, width: 2),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: StartupOnboardingTheme.navyBg)
                : Text(
                    '${step + 1}',
                    style: GoogleFonts.outfit(
                      color: isCurrent ? StartupOnboardingTheme.navyBg : StartupOnboardingTheme.softIvory.withOpacity(0.3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 10,
            color: isCurrent || isDone ? StartupOnboardingTheme.softIvory : StartupOnboardingTheme.softIvory.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Mục tiêu tư vấn'),
        const SizedBox(height: 12),
        TextFormField(
          controller: _objectiveController,
          maxLines: 3,
          style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory),
          decoration: _buildInputDecoration('Mô tả mục tiêu của buổi tư vấn...'),
          validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập mục tiêu' : null,
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Phạm vi nội dung'),
        const SizedBox(height: 12),
        TextFormField(
          controller: _scopeController,
          maxLines: 5,
          style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory),
          decoration: _buildInputDecoration('Ví dụ: Review pitch deck, tư vấn mô hình doanh thu...'),
          validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập phạm vi' : null,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Hình thức tư vấn'),
        const SizedBox(height: 12),
        _buildModeOption(ConsultingMode.online, 'Trực tuyến (Google Meet/Zoom)', LucideIcons.video),
        const SizedBox(height: 12),
        _buildModeOption(ConsultingMode.offline, 'Trực tiếp (Tại văn phòng)', LucideIcons.mapPin),
        const SizedBox(height: 32),
        _buildSectionTitle('Ghi chú thêm (Không bắt buộc)'),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory),
          decoration: _buildInputDecoration('Bạn có lưu ý gì thêm cho Cố vấn không?'),
        ),
      ],
    );
  }

  Widget _buildModeOption(ConsultingMode mode, String label, IconData icon) {
    bool isSelected = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() => _mode = mode),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? StartupOnboardingTheme.goldAccent.withOpacity(0.1) : StartupOnboardingTheme.navySurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? StartupOnboardingTheme.goldAccent : Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.softIvory.withOpacity(0.3)),
            const SizedBox(width: 16),
            Text(label, style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: StartupOnboardingTheme.goldAccent, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.goldAccent),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory.withOpacity(0.2), fontSize: 13),
      filled: true,
      fillColor: StartupOnboardingTheme.navySurface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: StartupOnboardingTheme.goldAccent)),
    );
  }

  Widget _buildBottomButtons() {
    bool isLoading = context.watch<ConsultingViewModel>().isLoading;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          if (_currentStep == 1) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 0),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: StartupOnboardingTheme.goldAccent),
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Quay lại', style: GoogleFonts.outfit(color: StartupOnboardingTheme.goldAccent, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: StartupOnboardingTheme.goldAccent,
                foregroundColor: StartupOnboardingTheme.navyBg,
                minimumSize: const Size(0, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: StartupOnboardingTheme.navyBg, strokeWidth: 2))
                : Text(_currentStep == 0 ? 'Tiếp tục' : 'Gửi yêu cầu', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep = 1);
      }
    } else {
      _handleSubmit();
    }
  }

  Future<void> _handleSubmit() async {
    final viewModel = context.read<ConsultingViewModel>();
    final request = ConsultingSessionModel(
      id: Uuid().v4(),
      advisorId: widget.advisor.id,
      advisor: widget.advisor,
      objective: _objectiveController.text,
      scope: _scopeController.text,
      mode: _mode,
      requestedAt: DateTime.now(),
      amount: widget.advisor.hourlyRate,
      status: ConsultingStatus.requested,
    );

    await viewModel.createRequest(request);
    
    if (mounted) {
      ToastUtils.showTopToast(context, 'Yêu cầu của bạn đã được gửi thành công!');
      Navigator.pop(context); // Back to profile
      Navigator.pop(context); // Back to discovery
    }
  }
}
