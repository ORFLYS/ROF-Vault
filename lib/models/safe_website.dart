import 'package:cloud_firestore/cloud_firestore.dart';

class SafeWebsite {
  final String id;
  final String name;
  final String url;
  final String username;
  final String password;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  SafeWebsite({
    required this.id,
    required this.name,
    required this.url,
    required this.username,
    required this.password,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SafeWebsite.fromMap(Map<String, dynamic> map, {String? docId}) {
    return SafeWebsite(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'username': username,
      'password': password,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  SafeWebsite copyWith({
    String? name,
    String? url,
    String? username,
    String? password,
    String? notes,
    DateTime? updatedAt,
  }) {
    return SafeWebsite(
      id: id,
      name: name ?? this.name,
      url: url ?? this.url,
      username: username ?? this.username,
      password: password ?? this.password,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
