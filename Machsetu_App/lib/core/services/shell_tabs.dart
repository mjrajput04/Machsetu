import 'package:flutter/foundation.dart';

/// Lets pushed routes drive the bottom-navigation selection.
///
/// A product page sits on top of the shell, so "View Cart" has to pop back to
/// the shell and tell it which tab to show — this notifier is that channel.
class ShellTabs {
  ShellTabs._();

  static const int home = 0;
  static const int search = 1;
  static const int cart = 2;
  static const int orders = 3;
  static const int profile = 4;

  static final ValueNotifier<int> selected = ValueNotifier<int>(home);

  static void go(int index) => selected.value = index;
}
