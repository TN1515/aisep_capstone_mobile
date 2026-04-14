import 'dart:async';
import 'package:flutter/material.dart';
import '../models/evaluation_models.dart';
import '../services/evaluation_service.dart';
import '../../../core/services/token_service.dart';

class EvaluationViewModel extends ChangeNotifier {
  final EvaluationService _service = EvaluationService();
  
  List<EvaluationStatusResult> _history = [];
  List<EvaluationStatusResult> get history => _history;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  EvaluationReportResult? _currentReport;
  EvaluationReportResult? get currentReport => _currentReport;

  Timer? _pollingTimer;

  Future<void> loadHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final startupId = await TokenService.getUserId();
      if (startupId != null) {
        _history = await _service.getHistory(startupId);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitForEvaluation(int? startupId, List<int> documentIds) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (startupId == null) throw Exception('User not logged in');

      final request = SubmitEvaluationRequest(
        startupId: startupId,
        documentIds: documentIds,
      );

      final submitResult = await _service.submitEvaluation(request);
      
      // Load history to refresh list with new item
      await loadHistory();
      
      if (submitResult.status == EvaluationStatus.processing || submitResult.status == EvaluationStatus.queued) {
        startPolling(submitResult.runId);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startPolling(int runId) {
    _pollingTimer?.cancel();
    // Polling interval adjusted to 7 seconds as planned
    _pollingTimer = Timer.periodic(const Duration(seconds: 7), (timer) async {
      try {
        final statusItem = await _service.getEvaluationStatus(runId);
        
        // Update history item
        final index = _history.indexWhere((e) => e.runId == runId);
        if (index != -1) {
          _history[index] = statusItem;
          notifyListeners();
        } else {
          // If not in history yet (rare), add it
          _history.insert(0, statusItem);
          notifyListeners();
        }

        if (statusItem.status == EvaluationStatus.completed || statusItem.status == EvaluationStatus.failed) {
          timer.cancel();
        }
      } catch (e) {
        timer.cancel();
        _errorMessage = 'Lỗi cập nhật tiến độ: ${e.toString()}';
        notifyListeners();
      }
    });
  }

  Future<void> loadReport(int runId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentReport = null;
    notifyListeners();

    try {
      _currentReport = await _service.getEvaluationReport(runId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

