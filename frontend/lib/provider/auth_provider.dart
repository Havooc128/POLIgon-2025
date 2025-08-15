import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:poligon/model/crew.dart';
import 'package:poligon/service/crew_service.dart';
import '../service/dio_service.dart';

/// Author: Łukasz Piętka (FUT 2025)
class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  String? idToken;
  Crew? me;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? newUser) async {
    user = newUser;
    if (user != null) {
      idToken = await user!.getIdToken(true);
      DioService().setIdToken(idToken!);
      me = await reloadMe();
      if (me == null) {
        idToken = null;
        DioService().clearIdToken();
        await newUser?.delete();
        print('Invalid user, deleting...');
      }
    } else {
      idToken = null;
      me = null;
      DioService().clearIdToken();
    }
    notifyListeners();
  }

  Future<Crew?> reloadMe() {
    return CrewService().getMe(forceRefresh: true);
  }

  Future<void> refreshToken() async {
    if (user != null) {
      idToken = await user!.getIdToken(true);
      DioService().setIdToken(idToken!);
      notifyListeners();
    }
  }
}
