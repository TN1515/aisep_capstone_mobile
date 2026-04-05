import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../view_models/document_view_model.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/document_model.dart';
import '../widgets/active_document_card.dart';
import '../widgets/blockchain_status_card.dart';
import '../widgets/ai_evaluation_card.dart';
import 'ai_report_detail_view.dart';
import 'upload_document_view.dart';
import 'document_versions_view.dart'; // NEW
import 'edit_metadata_view.dart';    // NEW
import 'package:provider/provider.dart'; // NEW

class DocumentListView extends StatefulWidget {
  const DocumentListView({super.key});

  @override
  State<DocumentListView> createState() => _DocumentListViewState();
}

class _DocumentListViewState extends State<DocumentListView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Removed local _viewModel = DocumentViewModel()

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => DocumentViewModel(),
      child: Consumer<DocumentViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text('Quản lý tài liệu'),
              actions: [
                IconButton(
                  icon: Icon(LucideIcons.plusCircle, color: theme.primaryColor),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UploadDocumentView(viewModel: viewModel))),
                ),
                const SizedBox(width: 12),
              ],
              bottom: TabBar(
                controller: _tabController,
                isScrollable: false,
                indicatorColor: theme.primaryColor,
                labelColor: theme.primaryColor,
                unselectedLabelColor: theme.textTheme.bodyLarge?.color?.withOpacity(0.4),
                labelStyle: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 13),
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  Tab(text: 'Quản lý'),
                  Tab(text: 'Xác thực'),
                  Tab(text: 'Đánh giá AI'),
                ],
              ),
            ),
            body: viewModel.isLoading
                ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildManagementTab(context, viewModel),
                      _buildBlockchainTab(context, viewModel),
                      _buildAiTab(context, viewModel),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildManagementTab(BuildContext context, DocumentViewModel viewModel) {
    if (viewModel.documents.isEmpty) {
      return _buildEmptyStateView(
        context,
        LucideIcons.filePlus,
        'Chưa có tài liệu',
        'Tải lên Pitch Deck hoặc báo cáo tài chính để bắt đầu.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      itemCount: viewModel.documents.length,
      itemBuilder: (context, index) {
        final doc = viewModel.documents[index];
        return ActiveDocumentCard(
          document: doc,
          onTap: () => _showDocumentActions(context, doc, viewModel),
        );
      },
    );
  }

  Widget _buildBlockchainTab(BuildContext context, DocumentViewModel viewModel) {
    if (viewModel.documents.isEmpty) {
      return _buildEmptyStateView(
        context,
        LucideIcons.shieldCheck,
        'Chưa rõ nguồn gốc',
        'Tài liệu tải lên sẽ được băm và lưu trữ on-chain tại đây.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      itemCount: viewModel.documents.length,
      itemBuilder: (context, index) {
        final doc = viewModel.documents[index];
        return BlockchainStatusCard(
          document: doc,
          onVerify: () => viewModel.verifyOnChain(doc.id),
        );
      },
    );
  }

  Widget _buildAiTab(BuildContext context, DocumentViewModel viewModel) {
    if (viewModel.evaluationHistory.isEmpty) {
      return _buildEmptyStateView(
        context,
        LucideIcons.brainCircuit,
        'Chưa có đánh giá AI',
        'Yêu cầu AISEP phân tích tiềm năng từ các tài liệu đã xác thực.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      itemCount: viewModel.evaluationHistory.length,
      itemBuilder: (context, index) {
        final eval = viewModel.evaluationHistory[index];
        return AiEvaluationCard(
          evaluation: eval,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AiReportDetailView(evaluation: eval)),
          ),
        );
      },
    );
  }

  Widget _buildEmptyStateView(BuildContext context, IconData icon, String title, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: theme.primaryColor.withOpacity(0.1)),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.displayLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentActions(BuildContext context, DocumentModel doc, DocumentViewModel viewModel) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionTile(context, LucideIcons.zap, 'Yêu cầu AI đánh giá', () {
              Navigator.pop(context);
              viewModel.requestAiEvaluation(doc.id);
              _tabController.animateTo(2);
            }),
            _buildActionTile(context, LucideIcons.history, 'Xem lịch sử phiên bản', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: viewModel,
                    child: DocumentVersionsView(document: doc),
                  ),
                ),
              );
            }),
            _buildActionTile(context, LucideIcons.edit3, 'Chỉnh sửa metadata', () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ChangeNotifierProvider.value(
                  value: viewModel,
                  child: EditMetadataView(document: doc),
                ),
              );
            }),
            Divider(color: theme.dividerColor),
            _buildActionTile(context, LucideIcons.trash2, 'Xóa tài liệu', () {}, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : theme.primaryColor, size: 20),
      title: Text(
        label,
        style: GoogleFonts.workSans(
          color: isDestructive ? Colors.redAccent : theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
