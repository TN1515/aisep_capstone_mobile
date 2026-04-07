import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/kyc/views/kyc_form_view.dart';
import 'package:aisep_capstone_mobile/features/kyc/view_models/kyc_view_model.dart';

/// Một file preview riêng biệt để phát triển UI cho màn hình KYC Form.
/// 
/// Cách chạy:
/// 1. Chuột phải vào file này -> Run 'preview_kyc_form.dart'
/// 2. Hoặc chạy lệnh: flutter run lib/features/kyc/previews/preview_kyc_form.dart
void main() {
  runApp(const KycPreviewApp());
}

class KycPreviewApp extends StatelessWidget {
  const KycPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KYC Form Preview',
      debugShowCheckedModeBanner: false,
      theme: StartupOnboardingTheme.darkTheme,
      
      // MẸO XEM CÁC BƯỚC KHÁC:
      // 1. Nhập đủ thông tin vào các ô (VD: Tên Startup, Mô tả) -> Nút 'Tiếp tục' sẽ sáng lên.
      // 2. Click 'Tiếp tục' để sang bước tiếp theo.
      // 3. Nếu muốn xem ngay một bước cụ thể, bạn có thể truyền dữ liệu mẫu vào ViewModel (xem MockKycViewModel bên dưới).

      home: const KycFormView(isIncorporated: true),
      
      // Mock các route nếu màn hình có yêu cầu điều hướng ra ngoài
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('Navigated to: ${settings.name}')),
          ),
        );
      },
    );
  }
}

/// Nâng cao: Mock ViewModel với dữ liệu mẫu (Stub)
/// Nếu bạn muốn preview màn hình ở một trạng thái cụ thể (với dữ liệu đã điền sẵn)
class MockKycViewModel extends KycViewModel {
  MockKycViewModel({required super.isIncorporated}) {
    // Stub dữ liệu mẫu
    nameController.text = "Công ty TNHH AISEP Global";
    taxOrDescriptionController.text = "0313456789";
    repNameController.text = "Nguyễn Văn AI";
    selectRole("Founder/CEO");
  }

  // Bạn có thể override các phương thức API để không gọi lên server
  @override
  Future<void> submitKyc(BuildContext context) async {
    print("Mock: Submitting KYC...");
    await Future.delayed(const Duration(seconds: 1));
    print("Mock: Submitted successfully!");
  }
}
