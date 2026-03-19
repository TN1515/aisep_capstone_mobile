import 'package:flutter/foundation.dart';
import '../models/counter_model.dart';

class CounterViewModel extends ChangeNotifier {
  final CounterModel _counterModel = CounterModel();

  int get counterValue => _counterModel.value;

  void incrementCounter() {
    _counterModel.value++;
    notifyListeners();
  }
}
