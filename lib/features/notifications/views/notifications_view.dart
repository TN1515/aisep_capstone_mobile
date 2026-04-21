import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../view_models/notification_view_model.dart';
import '../models/notification_model.dart';
import '../widgets/notification_tile.dart';
import '../../evaluation/views/evaluation_report_view.dart';
import '../../evaluation/views/evaluation_history_view.dart';
import '../../connections/views/connections_view.dart';
import '../../kyc/views/kyc_form_view.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleNotificationClick(BuildContext context, NotificationViewModel viewModel, NotificationModel notification) {
    // Mark as read
    viewModel.markAsRead(notification.id);

    // Navigation logic based on relatedEntityType and type
    if (notification.type == NotificationType.AI_EVALUATION && notification.relatedEntityId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EvaluationReportView(runId: notification.relatedEntityId!)),
      );
    } else if (notification.type == NotificationType.CONNECTION_REQUEST || notification.type == NotificationType.CONNECTION_ACCEPTED) {
       // Navigate to Connections tab or detail
       Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectionsView()));
    } else if (notification.type == NotificationType.KYC_STATUS) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KycFormView(
            isIncorporated: true,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
    } else if (notification.type == NotificationType.MENTORSHIP) {
       // Placeholder for mentorship navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<NotificationViewModel>();

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
          'Thông báo',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: theme.appBarTheme.titleTextStyle?.color,
          ),
        ),
        actions: [
          if (viewModel.unreadCount > 0)
            FadeIn(
              child: TextButton.icon(
                onPressed: () => viewModel.markAllAsRead(),
                icon: const Icon(LucideIcons.checkCheck, size: 16, color: StartupOnboardingTheme.goldAccent),
                label: Text(
                  'Đọc hết',
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    color: StartupOnboardingTheme.goldAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: StartupOnboardingTheme.goldAccent,
          indicatorWeight: 3,
          labelColor: StartupOnboardingTheme.goldAccent,
          unselectedLabelColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
          labelStyle: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Chưa đọc'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(context, viewModel, viewModel.notifications),
          _buildNotificationList(context, viewModel, viewModel.unreadNotifications),
        ],
      ),
    );
  }

  Widget _buildNotificationList(BuildContext context, NotificationViewModel viewModel, List<NotificationModel> notifications) {
    if (viewModel.isLoading && notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: StartupOnboardingTheme.goldAccent));
    }

    if (notifications.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      color: StartupOnboardingTheme.goldAccent,
      backgroundColor: Theme.of(context).cardColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return FadeInUp(
            duration: const Duration(milliseconds: 400),
            delay: Duration(milliseconds: index * 50),
            child: NotificationTile(
              notification: notification,
              onTap: () => _handleNotificationClick(context, viewModel, notification),
              onLongPress: () => _showActionSheet(context, viewModel, notification.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: StartupOnboardingTheme.goldAccent.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.bellOff, size: 48, color: StartupOnboardingTheme.goldAccent.withOpacity(0.2)),
          ),
          const SizedBox(height: 24),
          Text(
            'Hộp thư trống',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.displayLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn chưa có thông báo mới nào.\nHãy quay lại sau nhé!',
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showActionSheet(BuildContext context, NotificationViewModel viewModel, int id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.trash2, color: Colors.redAccent),
              title: Text('Xóa thông báo này', 
                style: GoogleFonts.workSans(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () {
                viewModel.deleteNotification(id);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
