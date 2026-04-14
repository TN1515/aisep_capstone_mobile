import 'package:flutter/material.dart';
import '../models/membership_plan_model.dart';
import '../models/payment_models.dart';
import '../services/membership_service.dart';
import '../../../core/network/api_response.dart';

class MembershipUpgradeViewModel extends ChangeNotifier {
  final MembershipService _service = MembershipService();
  final List<MembershipPlan> _plans = MembershipPlan.mockPlans;
  
  MembershipPlan _selectedPlan = MembershipPlan.mockPlans[0]; // Default to FREE
  MembershipPlan _currentPlan = MembershipPlan.mockPlans[0]; // Default to FREE
  
  bool _isLoading = false;
  String? _errorMessage;
  
  List<MembershipPlan> get plans => _plans;
  MembershipPlan get selectedPlan => _selectedPlan;
  MembershipPlan get currentPlan => _currentPlan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void selectPlan(MembershipPlan plan) {
    // Only allow selecting a plan that is higher than the current tier or current tier itself
    if (plan.tier.index < _currentPlan.tier.index) return;
    if (plan.tier == _selectedPlan.tier) return;
    
    _selectedPlan = plan;
    notifyListeners();
  }

  // Initiates the PayOS payment flow
  Future<PaymentInfoDto?> initiateUpgrade() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Map MembershipTier to Backend Enum (1: Pro, 2: Fundraising)
      int targetPlan = _selectedPlan.tier == MembershipTier.pro ? 1 : 2;
      
      // Parse amount from price string (e.g., "99.000" -> 99000)
      int amount = int.parse(_selectedPlan.price.replaceAll('.', ''));

      final request = SubscriptionPaymentRequest(
        targetPlan: targetPlan,
        amount: amount,
      );

      final response = await _service.createPaymentLink(request);
      
      if (response.success && response.data != null) {
        return response.data;
      } else {
        _errorMessage = response.error ?? 'Không thể tạo liên kết thanh toán';
        return null;
      }
    } catch (e) {
      _errorMessage = 'Lỗi kết nối: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Called after payment confirmation (e.g., manual return or webhook polling)
  Future<void> upgradeToSelected() async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate background sync
    await Future.delayed(const Duration(seconds: 2));
    
    _currentPlan = _selectedPlan;
    _isLoading = false;
    notifyListeners();
  }
}
