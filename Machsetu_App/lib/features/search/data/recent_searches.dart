import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The buyer's own recent searches.
///
/// Kept on the device rather than the server: a search history is personal,
/// it is only useful on the phone that typed it, and it must survive with no
/// network. Newest first, de-duplicated, capped at [limit].
class RecentSearchStore extends ChangeNotifier {
  RecentSearchStore._();

  static final RecentSearchStore instance = RecentSearchStore._();

  static const String _key = 'machsetu.recent.searches';

  /// Four is what the panel can show without pushing results off screen.
  static const int limit = 4;

  List<String> _terms = const [];
  bool _loaded = false;

  List<String> get terms => List.unmodifiable(_terms);

  bool get isEmpty => _terms.isEmpty;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _terms = (prefs.getStringList(_key) ?? const <String>[])
        .take(limit)
        .toList();
    _loaded = true;
    notifyListeners();
  }

  /// Records [term] as the most recent search.
  ///
  /// A repeat of something already in the list moves it to the top rather
  /// than adding a duplicate.
  Future<void> record(String term) async {
    final value = term.trim();
    // One or two characters is a keystroke, not a search worth remembering.
    if (value.length < 3) return;

    await load();

    final next = [
      value,
      ..._terms.where((t) => t.toLowerCase() != value.toLowerCase()),
    ].take(limit).toList();

    if (listEquals(next, _terms)) return;

    _terms = next;
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String term) async {
    await load();
    final next = _terms.where((t) => t != term).toList();
    if (next.length == _terms.length) return;
    _terms = next;
    await _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    if (_terms.isEmpty) return;
    _terms = const [];
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _terms);
  }

  /// Drops everything, including the "loaded" flag. Tests only.
  @visibleForTesting
  void resetForTest() {
    _terms = const [];
    _loaded = false;
  }
}
