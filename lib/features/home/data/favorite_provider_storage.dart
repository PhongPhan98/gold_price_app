import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProviderStorage {
  static const _favoriteProvidersKey = 'favorite_providers';

  Future<Set<String>> loadFavorites() async {
    final preferences = await SharedPreferences.getInstance();
    final favorites = preferences.getStringList(_favoriteProvidersKey) ?? const [];
    return favorites.toSet();
  }

  Future<void> saveFavorites(Set<String> favorites) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_favoriteProvidersKey, favorites.toList()..sort());
  }
}
