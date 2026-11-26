import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db.dart';
import 'models.dart';

/// Holds the signed-in user and remembers them between app launches.
class Session extends ChangeNotifier {
  AppUser? user;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    if (id != null) {
      user = await AppDatabase.instance.getUser(id);
    }
  }

  Future<void> signIn(AppUser u) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', u.id);
    user = u;
    notifyListeners();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    user = null;
    notifyListeners();
  }
}

final Session session = Session();
