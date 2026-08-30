import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Machines the buyer has bookmarked.
///
/// Saved locally: the marketplace has no wishlist endpoint yet, and a
/// bookmark is per-device anyway. Swap the two `SharedPreferences` calls for
/// an API when one exists — nothing else has to change.
class SavedStore extends ChangeNotifier {
  SavedStore._();

  static final SavedStore instance = SavedStore._();

  static const String _key = 'machsetu.saved.machines';

  Set<String> _ids = <String>{};
  bool _loaded = false;

  Set<String> get ids => Set.unmodifiable(_ids);

  int get count => _ids.length;

  bool contains(String id) => _ids.contains(id);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _ids = (prefs.getStringList(_key) ?? const <String>[]).toSet();
    _loaded = true;
    notifyListeners();
  }

  /// Adds or removes [id]. Returns true when the machine is now saved.
  Future<bool> toggle(String id) async {
    if (id.trim().isEmpty) return false;
    await load();

    final nowSaved = !_ids.contains(id);
    if (nowSaved) {
      _ids.add(id);
    } else {
      _ids.remove(id);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _ids.toList());
    notifyListeners();
    return nowSaved;
  }

  Future<void> clear() async {
    _ids = <String>{};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    notifyListeners();
  }
}
