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

  bool get isAnyEvaluationInProgress => _history.any((e) => 
    e.status == EvaluationStatus.queued || 
    e.status == EvaluationStatus.processing || 
    e.status == EvaluationStatus.retry
  );

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  EvaluationReportResult? _currentReport;
  EvaluationReportResult? get currentReport => _currentReport;

  Timer? _pollingTimer;

  Future<void> loadHistory(int? startupId) async {
    if (startupId == null) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.getHistory(startupId.toString());
      if (response.success && response.data != null) {
        _history = response.data!;
      } else {
        _errorMessage = response.error ?? 'Lỗi tải lịch sử đánh giá';
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

      final response = await _service.submitEvaluation(request);
      
      if (!response.success) {
        throw Exception(response.error ?? 'Gửi yêu cầu thất bại');
      }

      final submitResult = response.data!;
      
      // Load history to refresh list with new item
      await loadHistory(startupId);
      
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
        final response = await _service.getEvaluationStatus(runId);
        
        if (!response.success || response.data == null) {
          throw Exception(response.error ?? 'Lỗi lấy trạng thái');
        }

        final statusItem = response.data!;
        
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

        if (statusItem.status == EvaluationStatus.completed || 
            statusItem.status == EvaluationStatus.failed || 
            statusItem.status == EvaluationStatus.partial_completed) {
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
      final response = await _service.getEvaluationReport(runId);
      if (response.success) {
        _currentReport = response.data;
      } else {
        _errorMessage = response.error ?? 'Lỗi tải báo cáo';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSourceReport(int runId, DocumentSourceType sourceType) async {
    _isLoading = true;
    _errorMessage = null;
    _currentReport = null;
    notifyListeners();

    try {
      final response = await _service.getEvaluationSourceReport(runId, sourceType.apiKey);
      if (response.success) {
        _currentReport = response.data;
      } else {
        _errorMessage = response.error ?? 'Lỗi tải báo cáo nguồn';
      }
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

