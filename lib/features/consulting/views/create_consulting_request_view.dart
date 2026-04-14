import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/advisor_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/mentorship_models.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/core/utils/toast_utils.dart';
import 'package:intl/intl.dart';

class CreateConsultingRequestView extends StatefulWidget {
  final AdvisorModel advisor;

  const CreateConsultingRequestView({Key? key, required this.advisor}) : super(key: key);

  @override
  State<CreateConsultingRequestView> createState() => _CreateConsultingRequestViewState();
}

class _CreateConsultingRequestViewState extends State<CreateConsultingRequestView> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  
  final _goalController = TextEditingController();
  final _challengeController = TextEditingController();
  final _questionsController = TextEditingController();
  
  List<String> _selectedScopes = [];
  String _selectedPlatform = 'Google Meet';
  int _selectedDuration = 60; // Minutes
  
  final List<RequestedSlot> _selectedSlots = [];

  final List<String> _scopeOptions = [
    'Marketing',
    'Tài chính',
    'Công nghệ',
    'Go-to-market',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
        centerTitle: true,
        title: Text(
          'Đăng ký Cố vấn',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            _buildStepIndicator(isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Form(
                  key: _formKey,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentStep(isDark),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(isDark),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepNode(0, 'Vấn đề'),
          _buildStepLine(0),
          _buildStepNode(1, 'Chi tiết'),
          _buildStepLine(1),
          _buildStepNode(2, 'Lịch hẹn'),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step) {
    bool isActive = _currentStep > step;
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildStepNode(int step, String label) {
    bool isCurrent = _currentStep == step;
    bool isDone = _currentStep > step;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDone 
                ? Theme.of(context).primaryColor 
                : (isCurrent ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone || isCurrent ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '${step + 1}',
                    style: GoogleFonts.outfit(
                      color: isCurrent ? Theme.of(context).primaryColor : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCurrent ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep(bool isDark) {
    switch (_currentStep) {
      case 0: return _buildStep1(isDark);
      case 1: return _buildStep2(isDark);
      case 2: return _buildStep3(isDark);
      default: return const SizedBox();
    }
  }

  Widget _buildStep1(bool isDark) {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Bối cảnh & Mục tiêu', 'Hãy chia sẻ bối cảnh và mục tiêu bạn muốn đạt được.'),
        const SizedBox(height: 24),
        _buildLabel('Mục tiêu buổi tư vấn *'),
        _buildTextArea(
          controller: _goalController,
          hint: 'Ví dụ: Tôi muốn được góp ý để hoàn thiện pitch deck trước khi gặp nhà đầu tư.',
          maxLines: 4,
          limit: 200,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập mục tiêu' : null,
        ),
        const SizedBox(height: 24),
        _buildLabel('Mô tả vấn đề - thách thức bạn đang gặp *'),
        _buildTextArea(
          controller: _challengeController,
          hint: 'Mô tả bối cảnh hiện tại, những gì bạn đã thử và khó khăn chính...',
          maxLines: 8,
          limit: 500,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Trường này là bắt buộc';
            if (v.trim().length < 20) return 'Vui lòng mô tả chi tiết hơn (tối thiểu 20 ký tự)';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStep2(bool isDark) {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Chi tiết yêu cầu', 'Cung cấp thêm thông tin để cố vấn chuẩn bị tốt nhất.'),
        const SizedBox(height: 20),
        _buildLabel('Câu hỏi / Ghi chú thêm'),
        _buildTextArea(
          controller: _questionsController,
          hint: 'Các câu hỏi cụ thể hoặc thông tin bổ sung cho cố vấn...',
          maxLines: 4,
          limit: 300,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel('Phạm vi hỗ trợ *'),
            Text('Chọn một hoặc nhiều', style: GoogleFonts.workSans(fontSize: 10, color: Colors.grey)),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _scopeOptions.map((scope) {
            bool isSelected = _selectedScopes.contains(scope);
            return FilterChip(
              label: Text(scope, style: GoogleFonts.workSans(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) _selectedScopes.add(scope);
                  else _selectedScopes.remove(scope);
                });
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _buildLabel('Nền tảng'),
        Row(
          children: [
            _buildSelectionCard(
              label: 'Google Meet',
              icon: LucideIcons.video,
              isSelected: _selectedPlatform == 'Google Meet',
              onTap: () => setState(() => _selectedPlatform = 'Google Meet'),
            ),
            const SizedBox(width: 12),
            _buildSelectionCard(
              label: 'Microsoft Teams',
              icon: LucideIcons.users,
              isSelected: _selectedPlatform == 'Microsoft Teams',
              onTap: () => setState(() => _selectedPlatform = 'Microsoft Teams'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildLabel('Thời lượng'),
        Row(
          children: [30, 60, 120].map((min) {
            bool isSelected = _selectedDuration == min;
            return Expanded(
              child: _buildSelectionCard(
                label: '$min phút',
                icon: LucideIcons.clock,
                isSelected: isSelected,
                center: true,
                onTap: () => setState(() => _selectedDuration = min),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildPriceCard(isDark),
      ],
    );
  }

  Widget _buildSelectionCard({required String label, required IconData icon, required bool isSelected, required VoidCallback onTap, bool center = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceCard(bool isDark) {
    double hourlyRate = widget.advisor.hourlyRate ?? 2000; // Example rate from image fallback
    double totalPrice = (hourlyRate * _selectedDuration) / 60;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GIÁ PHIÊN TƯ VẤN', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.brown)),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${NumberFormat('#,###').format(totalPrice)}đ',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.brown.shade800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$_selectedDuration phút', style: GoogleFonts.workSans(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  'Chỉ thanh toán sau khi lịch được xác nhận',
                  textAlign: TextAlign.end,
                  style: GoogleFonts.workSans(
                    fontSize: 10,
                    color: Colors.brown.shade600,
                    fontStyle: FontStyle.italic,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(bool isDark) {
    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Thời gian đề xuất', 'Chọn tối đa 3 khung giờ bạn có thể tham gia.'),
        const SizedBox(height: 24),
        _buildLabel('Múi giờ'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : StartupOnboardingTheme.navyBg.withOpacity(0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.globe, size: 18, color: Colors.blue),
              const SizedBox(width: 12),
              Text('GMT+7 - Hà Nội / TP. Hồ Chí Minh', style: GoogleFonts.workSans(fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildLabel('Khung giờ ưu tiên *'),
        _buildSlotPicker(isDark),
        const SizedBox(height: 24),
        if (_selectedSlots.isNotEmpty) ...[
          _buildLabel('Khung giờ đã chọn'),
          const SizedBox(height: 8),
          ..._selectedSlots.map((slot) => _buildSelectedSlotTile(slot, isDark)),
        ],
      ],
    );
  }

  Widget _buildSlotPicker(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(LucideIcons.calendar, size: 20, color: Colors.blue),
              const SizedBox(width: 12),
              Text(
                'Thêm khung giờ mới',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const Spacer(),
              IconButton(
                onPressed: _showDateTimePicker,
                icon: const Icon(LucideIcons.plusCircle, color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedSlotTile(RequestedSlot slot, bool isDark) {
    final dateFormat = DateFormat('dd/MM, HH:mm');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.clock, size: 16, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            '${dateFormat.format(slot.startAt)} - ${DateFormat('HH:mm').format(slot.endAt)}',
            style: GoogleFonts.workSans(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => setState(() => _selectedSlots.remove(slot)),
            icon: const Icon(LucideIcons.x, size: 16, color: Colors.red),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Future<void> _showDateTimePicker() async {
    if (_selectedSlots.length >= 3) {
      ToastUtils.showTopToast(context, 'Chỉ được chọn tối đa 3 khung giờ');
      return;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final startAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        setState(() {
          _selectedSlots.add(RequestedSlot(
            startAt: startAt,
            endAt: startAt.add(const Duration(hours: 1)),
          ));
        });
      }
    }
  }

  Widget _buildSectionHeader(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        const SizedBox(height: 6),
        Text(
          sub,
          style: GoogleFonts.workSans(fontSize: 13, color: Colors.grey, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    bool isMandatory = label.contains('*');
    String cleanLabel = label.replaceAll('*', '').trim();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: cleanLabel,
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7)),
            ),
            if (isMandatory)
              TextSpan(
                text: ' *',
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.redAccent),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextArea({required TextEditingController controller, required String hint, int maxLines = 4, int? limit, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: limit,
          style: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: _inputDecoration(hint).copyWith(
            counterText: '',
          ),
          validator: validator,
          onChanged: (v) => setState(() {}),
        ),
        if (limit != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${controller.text.length}/$limit',
              style: GoogleFonts.workSans(fontSize: 10, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: _inputDecoration(hint),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.workSans(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.4), fontSize: 13),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : StartupOnboardingTheme.navyBg.withOpacity(0.03),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.all(16),
    );
  }

  Widget _buildBottomButtons(bool isDark) {
    final viewModel = context.watch<ConsultingViewModel>();
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
                child: Text('Quay lại', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor)),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: viewModel.isLoading ? null : _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: const Size(0, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: viewModel.isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_currentStep == 2 ? 'Gửi yêu cầu' : 'Tiếp tục', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    if (_currentStep == 1 && _selectedScopes.isEmpty) {
      ToastUtils.showTopToast(context, 'Vui lòng chọn ít nhất một phạm vi hỗ trợ');
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      if (_currentStep < 2) {
        setState(() => _currentStep++);
      } else {
        _submitRequest();
      }
    }
  }

  Future<void> _submitRequest() async {
    if (_selectedSlots.isEmpty) {
      ToastUtils.showTopToast(context, 'Vui lòng đề xuất ít nhất 1 khung giờ');
      return;
    }

    final viewModel = context.read<ConsultingViewModel>();
    final fullChallengeDescription = 'Mục tiêu: ${_goalController.text}\n\nThách thức: ${_challengeController.text}';
    
    final request = CreateMentorshipRequest(
      advisorId: widget.advisor.id,
      challengeDescription: fullChallengeDescription,
      specificQuestions: _questionsController.text,
      preferredFormat: _selectedPlatform,
      expectedDuration: '${_selectedDuration} phút',
      expectedScope: _selectedScopes.join(', '),
      requestedSlots: _selectedSlots,
    );

    try {
      await viewModel.createMentorshipRequest(request);
      if (mounted) {
        ToastUtils.showTopToast(context, 'Gửi yêu cầu thành công!');
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      ToastUtils.showTopToast(context, viewModel.errorMessage ?? 'Có lỗi xảy ra');
    }
  }
}
