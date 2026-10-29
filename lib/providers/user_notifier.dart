import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserNotifier extends ChangeNotifier {
  User _user = User(name: '', email: '');
  bool _isLoading = true;
  bool _isDarkMode = false;
  int _visitCount = 0;
  List<String> _favorites = [];

  User get user => _user;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  int get visitCount => _visitCount;
  List<String> get favorites => List.unmodifiable(_favorites);

  UserNotifier() {
    _loadData();
  }

  // Latihan 1 & 2: Memuat data awal, preferensi tema, dan menghitung kunjungan
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString('user_name') ?? '';
    final email = prefs.getString('user_email') ?? '';
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    _favorites = prefs.getStringList('favorites') ?? [];

    // Latihan 2: Increment visit counter
    _visitCount = (prefs.getInt('visit_count') ?? 0) + 1;
    await prefs.setInt('visit_count', _visitCount);

    _user = User(name: name, email: email, isLoggedIn: isLoggedIn);
    _isLoading = false;
    notifyListeners();
  }

  // Latihan 1: Mengubah dan menyimpan preferensi tema (Dark/Light Mode)
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
    notifyListeners();
  }

  // Latihan 3: Menambah item favorit ke SharedPreferences
  Future<void> addFavorite(String item) async {
    if (item.isEmpty || _favorites.contains(item)) return;
    _favorites.add(item);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
    notifyListeners();
  }

  // Latihan 3: Menghapus item favorit
  Future<void> removeFavorite(String item) async {
    _favorites.remove(item);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
    notifyListeners();
  }

  // Simpan/Update Profil User
  Future<void> updateUser(User newUser) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newUser.name);
    await prefs.setString('user_email', newUser.email);
    await prefs.setBool('is_logged_in', newUser.isLoggedIn);

    _user = newUser;
    _isLoading = false;
    notifyListeners();
  }

  // Fitur Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.setBool('is_logged_in', false);

    _user = _user.copyWith(name: '', isLoggedIn: false);
    notifyListeners();
  }
}
