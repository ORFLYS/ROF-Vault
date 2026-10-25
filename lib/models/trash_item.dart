import 'package:cloud_firestore/cloud_firestore.dart';

class TrashItem {
  final String id;
  final String originalType; // note, file, account
  final String originalId;
  final Map<String, dynamic> data;
  final DateTime deletedAt;
  final DateTime autoDeleteAt;

  TrashItem({
    required this.id,
    required this.originalType,
    required this.originalId,
    required this.data,
    required this.deletedAt,
    required this.autoDeleteAt,
  });

  factory TrashItem.fromMap(Map<String, dynamic> map, {String? docId}) {
    return TrashItem(
      id: docId ?? map['id'] ?? '',
      originalType: map['originalType'] ?? '',
      originalId: map['originalId'] ?? '',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      deletedAt: (map['deletedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      autoDeleteAt: (map['autoDeleteAt'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 30)),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originalType': originalType,
      'originalId': originalId,
      'data': data,
      'deletedAt': Timestamp.fromDate(deletedAt),
      'autoDeleteAt': Timestamp.fromDate(autoDeleteAt),
    };
  }

  bool get isExpired => DateTime.now().isAfter(autoDeleteAt);

  int get daysRemaining {
    final diff = autoDeleteAt.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  String itemNameLocalized([bool isArabic = false]) {
    switch (originalType) {
      case 'note':
        return data['title'] ?? (isArabic ? 'ملاحظة محذوفة' : 'Deleted note');
      case 'file':
        return data['fileName'] ?? (isArabic ? 'ملف محذوف' : 'Deleted file');
      case 'account':
        return data['serviceName'] ?? (isArabic ? 'حساب محذوف' : 'Deleted account');
      case 'card':
        final holder = data['cardHolderName'];
        final type = data['cardType'] ?? '';
        if (holder != null && holder.toString().isNotEmpty) {
          return '$type - $holder';
        }
        return isArabic ? 'بطاقة مصرفية' : 'Payment Card';
      case 'identity':
        return data['title'] ?? (isArabic ? 'وثيقة رسمية' : 'Identity Document');
      case 'website':
        return data['name'] ?? (isArabic ? 'موقع آمن' : 'Safe Website');
      default:
        return isArabic ? 'عنصر محذوف' : 'Deleted item';
    }
  }

  String typeLabelLocalized([bool isArabic = false]) {
    switch (originalType) {
      case 'note':
        return isArabic ? 'ملاحظة' : 'Note';
      case 'file':
        final fileType = data['fileType'] ?? '';
        if (fileType == 'photo') return isArabic ? 'صورة' : 'Photo';
        if (fileType == 'video') return isArabic ? 'فيديو' : 'Video';
        return isArabic ? 'مستند' : 'Document';
      case 'account':
        return isArabic ? 'حساب' : 'Account';
      case 'card':
        return isArabic ? 'بطاقة مصرفية' : 'Card';
      case 'identity':
        return isArabic ? 'وثيقة رسمية' : 'Identity';
      case 'website':
        return isArabic ? 'موقع آمن' : 'Website';
      default:
        return isArabic ? 'عنصر' : 'Item';
    }
  }

  String get itemName => itemNameLocalized(true);

  String get typeLabel => typeLabelLocalized(true);
}
