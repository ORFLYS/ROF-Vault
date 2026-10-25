import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentCard {
  final String id;
  final String cardHolderName;
  final String cardNumber;
  final String expiryDate; // MM/YY
  final String cvv;
  final String? pin;
  final String cardType; // Visa, Mastercard, AMEX, etc.
  final String? bankName;
  final int colorIndex; // 0: Dark Blue, 1: Emerald, 2: Purple, 3: Obsidian Black, 4: Warm Gold
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentCard({
    required this.id,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    this.pin,
    required this.cardType,
    this.bankName,
    this.colorIndex = 0,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentCard.fromMap(Map<String, dynamic> map, {String? docId}) {
    return PaymentCard(
      id: docId ?? map['id'] ?? '',
      cardHolderName: map['cardHolderName'] ?? '',
      cardNumber: map['cardNumber'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      cvv: map['cvv'] ?? '',
      pin: map['pin'],
      cardType: map['cardType'] ?? 'Visa',
      bankName: map['bankName'],
      colorIndex: map['colorIndex'] ?? 0,
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardHolderName': cardHolderName,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'pin': pin,
      'cardType': cardType,
      'bankName': bankName,
      'colorIndex': colorIndex,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  PaymentCard copyWith({
    String? cardHolderName,
    String? cardNumber,
    String? expiryDate,
    String? cvv,
    String? pin,
    String? cardType,
    String? bankName,
    int? colorIndex,
    String? notes,
    DateTime? updatedAt,
  }) {
    return PaymentCard(
      id: id,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      pin: pin ?? this.pin,
      cardType: cardType ?? this.cardType,
      bankName: bankName ?? this.bankName,
      colorIndex: colorIndex ?? this.colorIndex,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Format card number with spaces every 4 digits
  String get formattedCardNumber {
    final clean = cardNumber.replaceAll(RegExp(r'\s+'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(clean[i]);
    }
    return buffer.toString();
  }

  /// Masked card number (e.g. •••• •••• •••• 4242)
  String get maskedCardNumber {
    final clean = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (clean.length < 4) return '•••• •••• •••• $clean';
    final last4 = clean.substring(clean.length - 4);
    return '•••• •••• •••• $last4';
  }

  /// Masked CVV (e.g. •••)
  String get maskedCvv => '•' * (cvv.isNotEmpty ? cvv.length : 3);

  /// Card type detector helper
  static String detectCardType(String number) {
    final clean = number.replaceAll(RegExp(r'\s+'), '');
    if (clean.startsWith('4')) return 'Visa';
    if (clean.startsWith(RegExp(r'5[1-5]|2[2-7]'))) return 'Mastercard';
    if (clean.startsWith(RegExp(r'3[47]'))) return 'AMEX';
    if (clean.startsWith(RegExp(r'6(?:011|5)'))) return 'Discover';
    return 'Card';
  }
}
