import 'package:equatable/equatable.dart';

/// Represents a user in the BillSnap application
class AppUser extends Equatable {
  final String uid;
  final String email;
  final String displayName;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  /// Creates an empty user (for unauthenticated state)
  static const empty = AppUser(uid: '', email: '', displayName: '');

  /// Check if this is an empty user
  bool get isEmpty => this == AppUser.empty;
  bool get isNotEmpty => !isEmpty;

  /// Create from Firebase User
  factory AppUser.fromFirebaseUser(dynamic firebaseUser) {
    return AppUser(
      uid: firebaseUser.uid ?? '',
      email: firebaseUser.email ?? '',
      displayName:
          firebaseUser.displayName ??
          firebaseUser.email?.split('@').first ??
          'User',
    );
  }

  /// Create from Firestore document
  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {'email': email, 'displayName': displayName};
  }

  /// Copy with new values
  AppUser copyWith({String? uid, String? email, String? displayName}) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName];
}
