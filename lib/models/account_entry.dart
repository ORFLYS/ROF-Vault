import 'package:cloud_firestore/cloud_firestore.dart';

class AccountEntry {
  final String id;
  final String serviceName;
  final String username;
  final String password;
  final String? notes;
  final String? iconName;
  final String? websiteUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  AccountEntry({
    required this.id,
    required this.serviceName,
    required this.username,
    required this.password,
    this.notes,
    this.iconName,
    this.websiteUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccountEntry.fromMap(Map<String, dynamic> map, {String? docId}) {
    return AccountEntry(
      id: docId ?? map['id'] ?? '',
      serviceName: map['serviceName'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      notes: map['notes'],
      iconName: map['iconName'],
      websiteUrl: map['websiteUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceName': serviceName,
      'username': username,
      'password': password,
      'notes': notes,
      'iconName': iconName,
      'websiteUrl': websiteUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AccountEntry copyWith({
    String? serviceName,
    String? username,
    String? password,
    String? notes,
    String? iconName,
    String? websiteUrl,
    DateTime? updatedAt,
  }) {
    return AccountEntry(
      id: id,
      serviceName: serviceName ?? this.serviceName,
      username: username ?? this.username,
      password: password ?? this.password,
      notes: notes ?? this.notes,
      iconName: iconName ?? this.iconName,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Common service icons mapping
  static const Map<String, String> serviceIcons = {
    'google': 'G',
    'gmail': 'G',
    'facebook': 'f',
    'instagram': 'I',
    'twitter': 'X',
    'x': 'X',
    'snapchat': 'S',
    'tiktok': 'T',
    'youtube': 'Y',
    'linkedin': 'in',
    'github': 'GH',
    'apple': 'A',
    'microsoft': 'M',
    'amazon': 'a',
    'netflix': 'N',
    'spotify': 'S',
    'discord': 'D',
    'telegram': 'T',
    'whatsapp': 'W',
  };

  String get serviceInitial {
    final lower = serviceName.toLowerCase();
    for (final entry in serviceIcons.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return serviceName.isNotEmpty ? serviceName[0].toUpperCase() : '?';
  }
}
