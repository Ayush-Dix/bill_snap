import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'auth_state.dart';

/// Cubit for managing authentication state
class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  StreamSubscription<AppUser>? _authSubscription;

  AuthCubit({
    required AuthService authService,
    required FirestoreService firestoreService,
  }) : _authService = authService,
       _firestoreService = firestoreService,
       super(const AuthInitial()) {
    _init();
  }

  /// Initialize and listen to auth state changes
  void _init() {
    _authSubscription = _authService.authStateChanges.listen((user) {
      if (user.isEmpty) {
        emit(const AuthUnauthenticated());
      } else {
        emit(AuthAuthenticated(user));
      }
    });
  }

  /// Get current user
  AppUser get currentUser {
    final state = this.state;
    if (state is AuthAuthenticated) {
      return state.user;
    }
    return AppUser.empty;
  }

  /// Get current user ID
  String? get currentUserId => currentUser.isNotEmpty ? currentUser.uid : null;

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Save user profile to Firestore
      await _firestoreService.saveUserProfile(user);

      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Sign up failed: $e'));
      emit(const AuthUnauthenticated());
    }
  }

  /// Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Sign in failed: $e'));
      emit(const AuthUnauthenticated());
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Sign out failed: $e'));
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } on AuthException catch (e) {
      emit(AuthError(e.message));
      return false;
    } catch (e) {
      emit(AuthError('Failed to send reset email: $e'));
      return false;
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
