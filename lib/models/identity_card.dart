import 'package:cloud_firestore/cloud_firestore.dart';

class IdentityCard {
  final String id;
  final String title;
  final String idType; // passport, national_id, driver_license, residency, other
  final String fullName;
  final String idNumber;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? frontImagePath;
  final String? backImagePath;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  IdentityCard({
    required this.id,
    required this.title,
    required this.idType,
    required this.fullName,
    required this.idNumber,
    this.issueDate,
    this.expiryDate,
    this.frontImagePath,
    this.backImagePath,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IdentityCard.fromMap(Map<String, dynamic> map, {String? docId}) {
    return IdentityCard(
      id: docId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      idType: map['idType'] ?? 'other',
      fullName: map['fullName'] ?? '',
      idNumber: map['idNumber'] ?? '',
      issueDate: (map['issueDate'] as Timestamp?)?.toDate(),
      expiryDate: (map['expiryDate'] as Timestamp?)?.toDate(),
      frontImagePath: map['frontImagePath'],
      backImagePath: map['backImagePath'],
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'idType': idType,
      'fullName': fullName,
      'idNumber': idNumber,
      'issueDate': issueDate != null ? Timestamp.fromDate(issueDate!) : null,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'frontImagePath': frontImagePath,
      'backImagePath': backImagePath,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  IdentityCard copyWith({
    String? title,
    String? idType,
    String? fullName,
    String? idNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? frontImagePath,
    String? backImagePath,
    String? notes,
    DateTime? updatedAt,
  }) {
    return IdentityCard(
      id: id,
      title: title ?? this.title,
      idType: idType ?? this.idType,
      fullName: fullName ?? this.fullName,
      idNumber: idNumber ?? this.idNumber,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  bool get isExpiringSoon {
    if (expiryDate == null || isExpired) return false;
    final now = DateTime.now();
    final difference = expiryDate!.difference(now).inDays;
    return difference <= 60 && difference >= 0;
  }
}
