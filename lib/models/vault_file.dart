import 'package:cloud_firestore/cloud_firestore.dart';

class VaultFile {
  final String id;
  final String fileName;
  final String fileType; // photo, video, document
  final String mimeType;
  final int fileSize;
  final String storagePath;
  final String downloadUrl;
  final String? thumbnailUrl;
  final DateTime createdAt;

  VaultFile({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.mimeType,
    required this.fileSize,
    required this.storagePath,
    required this.downloadUrl,
    this.thumbnailUrl,
    required this.createdAt,
  });

  factory VaultFile.fromMap(Map<String, dynamic> map, {String? docId}) {
    return VaultFile(
      id: docId ?? map['id'] ?? '',
      fileName: map['fileName'] ?? '',
      fileType: map['fileType'] ?? 'document',
      mimeType: map['mimeType'] ?? 'application/octet-stream',
      fileSize: map['fileSize'] ?? 0,
      storagePath: map['storagePath'] ?? '',
      downloadUrl: map['downloadUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'fileType': fileType,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'storagePath': storagePath,
      'downloadUrl': downloadUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  bool get isPhoto => fileType == 'photo';
  bool get isVideo => fileType == 'video';
  bool get isDocument => fileType == 'document';

  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }
}
