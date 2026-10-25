import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String securityMethod;
  final DateTime createdAt;
  final DateTime lastLogin;
  final int autoLockMinutes;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.securityMethod = 'none',
    required this.createdAt,
    required this.lastLogin,
    this.autoLockMinutes = 5,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      securityMethod: map['securityMethod'] ?? 'none',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      autoLockMinutes: map['autoLockMinutes'] ?? 5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'securityMethod': securityMethod,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'autoLockMinutes': autoLockMinutes,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    String? securityMethod,
    DateTime? lastLogin,
    int? autoLockMinutes,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      securityMethod: securityMethod ?? this.securityMethod,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
    );
  }
}
