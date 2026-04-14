import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../view_models/document_view_model.dart';
import '../../evaluation/view_models/evaluation_view_model.dart';
import '../widgets/ai_evaluation_tab_view.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/document_model.dart';
import '../widgets/active_document_card.dart';
import '../widgets/blockchain_status_card.dart';
import 'upload_document_view.dart';
import 'document_detail_view.dart';
import 'package:provider/provider.dart';

class DocumentListView extends StatefulWidget {
  const DocumentListView({super.key});

  @override
  State<DocumentListView> createState() => _DocumentListViewState();
}

class _DocumentListViewState extends State<DocumentListView> {
  final DocumentViewModel _viewModel = DocumentViewModel();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EvaluationViewModel>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Tài liệu & Đánh giá'),
            actions: [
              IconButton(
                icon: Icon(LucideIcons.refreshCw, color: theme.primaryColor, size: 20),
                onPressed: () {
                  _viewModel.loadDocuments();
                  context.read<EvaluationViewModel>().loadHistory();
                },
              ),
              const SizedBox(width: 12),
            ],
            bottom: TabBar(
              indicatorColor: theme.primaryColor,
              labelColor: theme.primaryColor,
              unselectedLabelColor: Colors.grey,
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Tài liệu'),
                Tab(text: 'Đánh giá AI'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildDocumentTab(context),
              AiEvaluationTabView(
                viewModel: context.read<EvaluationViewModel>(), 
                documentViewModel: _viewModel
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: theme.primaryColor,
            onPressed: () async {
              final success = await Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => UploadDocumentView(viewModel: _viewModel))
              );
              if (success == true) _viewModel.loadDocuments();
            },
            child: const Icon(LucideIcons.plus, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentTab(BuildContext context) {
    return Consumer<DocumentViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Theme.of(context).primaryColor),
                const SizedBox(height: 16),
                Text('Đang tải tài liệu...', style: GoogleFonts.workSans(color: Theme.of(context).primaryColor)),
              ],
            ),
          );
        }

        if (viewModel.errorMessage != null) {
          return _buildErrorView(context, viewModel);
        }

        return _buildManagementTab(context, viewModel);
      },
    );
  }

  Widget _buildErrorView(BuildContext context, DocumentViewModel viewModel) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertCircle, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Lỗi tải dữ liệu',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? 'Không thể kết nối đến máy chủ',
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.loadDocuments(),
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementTab(BuildContext context, DocumentViewModel viewModel) {
    if (viewModel.documents.isEmpty) {
      return _buildEmptyStateView(
        context,
        LucideIcons.filePlus,
        'Chưa có tài liệu',
        'Tải lên Pitch Deck hoặc báo cáo tài chính để quản lý và bảo vệ ý tưởng.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadDocuments(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        itemCount: viewModel.documents.length,
        itemBuilder: (context, index) {
          final doc = viewModel.documents[index];
          return ActiveDocumentCard(
            document: doc,
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => DocumentDetailView(document: doc, viewModel: viewModel))
              );
            },
          );
        },
      ),
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
}
