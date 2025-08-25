import 'package:flutter/material.dart';

class CombinedChangeNotifier extends ChangeNotifier {
  final ChangeNotifier one;
  final ChangeNotifier two;

  late final VoidCallback _oneListener;
  late final VoidCallback _twoListener;

  CombinedChangeNotifier(this.one, this.two) {
    _oneListener = () => notifyListeners();
    _twoListener = () => notifyListeners();
    one.addListener(_oneListener);
    two.addListener(_twoListener);
  }

  @override
  void dispose() {
    one.removeListener(_oneListener);
    two.removeListener(_twoListener);
    super.dispose();
  }
}
