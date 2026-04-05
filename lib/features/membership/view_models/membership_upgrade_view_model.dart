import 'package:flutter/material.dart';
import '../models/membership_plan_model.dart';

class MembershipUpgradeViewModel extends ChangeNotifier {
  final List<MembershipPlan> _plans = MembershipPlan.mockPlans;
  
  MembershipPlan _selectedPlan = MembershipPlan.mockPlans[0]; // Default to FREE
  MembershipPlan _currentPlan = MembershipPlan.mockPlans[0]; // Default to FREE
  
  bool _isLoading = false;
  
  List<MembershipPlan> get plans => _plans;
  MembershipPlan get selectedPlan => _selectedPlan;
  MembershipPlan get currentPlan => _currentPlan;
  bool get isLoading => _isLoading;

  void selectPlan(MembershipPlan plan) {
    // Only allow selecting a plan that is higher than the current tier or current tier itself
    if (plan.tier.index < _currentPlan.tier.index) return;
    if (plan.tier == _selectedPlan.tier) return;
    
    _selectedPlan = plan;
    notifyListeners();
  }

  // Called after payment confirmation
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
