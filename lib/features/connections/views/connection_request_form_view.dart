import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/investor_model.dart';
import '../view_models/connection_view_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class ConnectionRequestFormView extends StatefulWidget {
  final InvestorModel investor;
  final String? initialMessage;
  final String? requestId;

  const ConnectionRequestFormView({
    Key? key,
    required this.investor,
    this.initialMessage,
    this.requestId,
  }) : super(key: key);

  @override
  State<ConnectionRequestFormView> createState() => _ConnectionRequestFormViewState();
}

class _ConnectionRequestFormViewState extends State<ConnectionRequestFormView> {
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: widget.initialMessage);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ConnectionViewModel>(context);
    final isUpdating = widget.requestId != null;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(LucideIcons.x, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              isUpdating ? 'Cập nhật yêu cầu' : 'Gửi yêu cầu kết nối',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInvestorHeader(context),
                const SizedBox(height: 32),
                Text(
                  'GỬI LỜI CHÀO/LÝ DO KẾT NỐI',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: TextFormField(
                    controller: _messageController,
                    maxLines: 6,
                    style: GoogleFonts.workSans(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Nhập nội dung tin nhắn gửi đến ${widget.investor.name}...',
                      hintStyle: GoogleFonts.workSans(
                        color: textColor.withOpacity(0.3),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Gợi ý: Hãy nêu ngắn gọn cách Startup của bạn giải quyết vấn đề và tại sao bạn nghĩ ${widget.investor.organization ?? 'họ'} là đối tác phù hợp.',
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: textColor.withOpacity(0.4),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading ? null : () => _submitRequest(viewModel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: theme.brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: viewModel.isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isUpdating ? 'Cập nhật ngay' : 'Xác nhận gửi',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvestorHeader(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          child: Icon(LucideIcons.user, color: theme.primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.investor.name,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              widget.investor.organization ?? 'Quỹ đầu tư',
              style: GoogleFonts.workSans(
                fontSize: 12,
                color: textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitRequest(ConnectionViewModel vm) async {
    bool success = false;
    if (widget.requestId != null) {
      // updateRequest logic if needed
      success = true; 
    } else {
      success = await vm.inviteConnection(widget.investor.id, _messageController.text);
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.requestId != null ? 'Đã cập nhật yêu cầu!' : 'Đã gửi yêu cầu kết nối!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (vm.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${vm.errorMessage}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
