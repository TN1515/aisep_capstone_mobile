import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../view_models/notification_view_model.dart';
import '../widgets/notification_tile.dart';
import 'package:aisep_capstone_mobile/core/utils/toast_utils.dart';

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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationViewModel(),
      child: Consumer<NotificationViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(LucideIcons.arrowLeft, color: Theme.of(context).iconTheme.color),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Thông báo',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              actions: [
                if (viewModel.unreadCount > 0)
                  TextButton(
                    onPressed: () {
                      viewModel.markAllAsRead();
                      ToastUtils.showTopToast(context, 'Đã đánh dấu tất cả là đã đọc.');
                    },
                    child: Text(
                      'Đọc tất cả',
                      style: GoogleFonts.workSans(
                        fontSize: 13,
                        color: StartupOnboardingTheme.goldAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: StartupOnboardingTheme.goldAccent,
                labelColor: StartupOnboardingTheme.goldAccent,
                unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
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
        },
      ),
    );
  }

  Widget _buildNotificationList(BuildContext context, NotificationViewModel viewModel, List notifications) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator(color: StartupOnboardingTheme.goldAccent));
    }

    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      color: StartupOnboardingTheme.goldAccent,
      backgroundColor: Theme.of(context).cardColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationTile(
            notification: notification,
            onTap: () => viewModel.markAsRead(notification.id),
            onLongPress: () => _showActionSheet(context, viewModel, notification.id),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.bellOff, size: 64, color: StartupOnboardingTheme.goldAccent.withOpacity(0.1)),
          const SizedBox(height: 24),
          Text(
            'Hộp thư trống',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.displayLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn chưa có thông báo nào vào lúc này.',
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

  void _showActionSheet(BuildContext context, NotificationViewModel viewModel, String id) {
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
              leading: const Icon(LucideIcons.checkCheck, color: StartupOnboardingTheme.goldAccent),
              title: Text('Đánh dấu là đã đọc', style: GoogleFonts.workSans(color: Theme.of(context).textTheme.bodyLarge?.color)),
              onTap: () {
                viewModel.markAsRead(id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.trash2, color: Colors.redAccent),
              title: Text('Xóa thông báo', style: GoogleFonts.workSans(color: Colors.redAccent)),
              onTap: () {
                viewModel.deleteNotification(id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
