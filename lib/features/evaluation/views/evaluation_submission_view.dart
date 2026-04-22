import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../view_models/evaluation_view_model.dart';
import '../../documents/view_models/document_view_model.dart';
import '../../documents/models/document_model.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../../profile/view_models/startup_profile_view_model.dart';
import '../../../core/theme/startup_onboarding_theme.dart';

class EvaluationSubmissionView extends StatefulWidget {
  const EvaluationSubmissionView({Key? key}) : super(key: key);

  @override
  State<EvaluationSubmissionView> createState() => _EvaluationSubmissionViewState();
}

class _EvaluationSubmissionViewState extends State<EvaluationSubmissionView> {
  final Set<int> _selectedDocumentIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentViewModel>().loadDocuments();
      
      final startupId = context.read<StartupProfileViewModel>().startupId;
      context.read<EvaluationViewModel>().loadHistory(startupId);
    });
  }

  void _onToggleDocument(int id) {
    setState(() {
      if (_selectedDocumentIds.contains(id)) {
        _selectedDocumentIds.remove(id);
      } else {
        _selectedDocumentIds.add(id);
      }
    });
  }

  Future<void> _submit() async {
    if (_selectedDocumentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một tài liệu để phân tích')),
      );
      return;
    }

    final profileVm = context.read<StartupProfileViewModel>();
    final evalVm = context.read<EvaluationViewModel>();
    
    final startupId = profileVm.startupId;
    
    await evalVm.submitForEvaluation(
      startupId, 
      _selectedDocumentIds.toList(),
    );

    if (evalVm.errorMessage == null) {
      if (!mounted) return;
      Navigator.pop(context); // Go back to History
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Đã gửi yêu cầu phân tích thành công!'),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Lỗi: ${evalVm.errorMessage}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final docViewModel = context.watch<DocumentViewModel>();
    final evalViewModel = context.watch<EvaluationViewModel>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: theme.appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Gửi Tài liệu Đánh giá',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: theme.appBarTheme.titleTextStyle?.color,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildInfoBanner(),
          Expanded(
            child: docViewModel.isLoading 
                ? const Center(child: CircularProgressIndicator(color: StartupOnboardingTheme.goldAccent))
                : _buildDocumentList(docViewModel.documents),
          ),
          _buildBottomAction(evalViewModel),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.info, color: StartupOnboardingTheme.goldAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chọn các tài liệu quan trọng nhất (Pitch Deck, Business Plan) để AI có cái nhìn chính xác nhất về startup của bạn.',
              style: GoogleFonts.workSans(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentList(List<DocumentModel> documents) {
    final theme = Theme.of(context);
    
    // Filter documents by requirements: Pitch Deck (0) or Business Plan (1)
    final filteredDocuments = documents.where((doc) => 
      doc.documentType == DocumentType.pitchDeck || 
      doc.documentType == DocumentType.businessPlan
    ).toList();

    if (filteredDocuments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.fileX, size: 64, color: theme.disabledColor.withOpacity(0.1)),
              const SizedBox(height: 24),
              Text(
                'Chưa có tài liệu phù hợp',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'AI chỉ đánh giá tài liệu loại Pitch Deck hoặc Business Plan đã được xác thực trên Blockchain.',
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: filteredDocuments.length,
      itemBuilder: (context, index) {
        final doc = filteredDocuments[index];
        final isSelected = _selectedDocumentIds.contains(doc.id);
        final isAnchored = doc.proofStatus == ProofStatus.anchored;

        return FadeInLeft(
          delay: Duration(milliseconds: index * 50),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? StartupOnboardingTheme.goldAccent.withOpacity(0.05) 
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                    ? StartupOnboardingTheme.goldAccent 
                    : isAnchored ? theme.dividerColor : Colors.red.withOpacity(0.2),
              ),
            ),
            child: CheckboxListTile(
              value: isSelected,
              enabled: isAnchored,
              onChanged: isAnchored ? (_) => _onToggleDocument(doc.id) : null,
              activeColor: StartupOnboardingTheme.goldAccent,
              checkColor: Colors.white,
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      doc.displayTitle,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        color: isAnchored ? theme.textTheme.titleMedium?.color : theme.disabledColor,
                      ),
                    ),
                  ),
                  _buildProofBadge(doc.proofStatus),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${doc.documentType.label} • ${_formatFileSize(doc.sizeInBytes)}',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                  if (!isAnchored)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Cần được Anchored để đánh giá',
                        style: GoogleFonts.workSans(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
              secondary: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isSelected ? StartupOnboardingTheme.goldAccent : theme.primaryColor).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForType(doc.documentType),
                  size: 20,
                  color: isSelected ? StartupOnboardingTheme.goldAccent : isAnchored ? theme.primaryColor : theme.disabledColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProofBadge(ProofStatus status) {
    bool isAnchored = status == ProofStatus.anchored;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isAnchored ? 'Đã xác thực' : 'Chưa xác thực',
        style: GoogleFonts.workSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: status.color,
        ),
      ),
    );
  }

  Widget _buildBottomAction(EvaluationViewModel evalViewModel) {
    final theme = Theme.of(context);
    final isLoading = evalViewModel.isLoading;
    final isAnyInProgress = evalViewModel.isAnyEvaluationInProgress;
    final isBtnDisabled = isLoading || isAnyInProgress || _selectedDocumentIds.isEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isBtnDisabled ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: StartupOnboardingTheme.goldAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              disabledBackgroundColor: isAnyInProgress 
                  ? Colors.blue.withOpacity(0.1) 
                  : StartupOnboardingTheme.goldAccent.withOpacity(0.3),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    isAnyInProgress 
                        ? 'Đang có tài liệu phân tích...' 
                        : 'Bắt đầu Phân tích AI (${_selectedDocumentIds.length})',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isAnyInProgress ? Colors.blue : Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(DocumentType type) {
    switch (type) {
      case DocumentType.pitchDeck: return LucideIcons.presentation;
      case DocumentType.businessPlan: return LucideIcons.fileText;
      case DocumentType.financials: return LucideIcons.pieChart;
      case DocumentType.legal: return LucideIcons.fileCheck;
      default: return LucideIcons.file;
    }
  }

  String _formatFileSize(double bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
