import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../models/vault_file.dart';
import '../models/account_entry.dart';
import '../models/safe_website.dart';
import '../models/payment_card.dart';
import '../models/identity_card.dart';
import '../models/trash_item.dart';
import '../services/firestore_service.dart';
import '../services/drive_api_service.dart';
import '../config/constants.dart';

class VaultProvider extends ChangeNotifier {
  FirestoreService? _firestoreService;
  DriveApiService? _driveService;
  final _uuid = const Uuid();

  List<Note> _notes = [];
  List<VaultFile> _photos = [];
  List<VaultFile> _videos = [];
  List<VaultFile> _documents = [];
  List<AccountEntry> _accounts = [];
  List<SafeWebsite> _safeWebsites = [];
  List<PaymentCard> _cards = [];
  List<IdentityCard> _identities = [];
  List<TrashItem> _trashItems = [];
  Map<String, int> _itemCounts = {};

  final bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _error;
  String? _currentUid;

  // Getters
  List<Note> get notes => _notes;
  List<VaultFile> get photos => _photos;
  List<VaultFile> get videos => _videos;
  List<VaultFile> get documents => _documents;
  List<VaultFile> get gallery =>
      [..._photos, ..._videos]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  List<AccountEntry> get accounts => _accounts;
  List<SafeWebsite> get safeWebsites => _safeWebsites;
  List<PaymentCard> get cards => _cards;
  List<IdentityCard> get identities => _identities;
  List<TrashItem> get trashItems => _trashItems;
  Map<String, int> get itemCounts => _itemCounts;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get error => _error;
  bool get isDriveConnected => _driveService?.isConnected ?? false;
  String? get driveUserEmail => _driveService?.userEmail;
  String? get driveUserName => _driveService?.userName;

  /// Initialize with user ID
  void initialize(String uid) {
    if (_currentUid == uid) return;
    _currentUid = uid;

    _firestoreService = FirestoreService(uid: uid);
    _driveService = DriveApiService();
    _driveService!.signInSilently().then((_) {
      notifyListeners();
    }).catchError((e) {
      debugPrint('DriveApiService signInSilently error: $e');
    });

    _setupStreams();

    if (FirestoreService.usePolling) {
      // On Windows, counts are computed from local data in _fetchAllData()
      // and purgeExpiredTrash is skipped to avoid subcollection queries
    } else {
      _loadItemCounts();
      _purgeExpiredTrash();
    }
  }

  /// Connect Google Drive OAuth
  Future<bool> connectDrive({void Function(String url)? onLaunchUrl}) async {
    _driveService ??= DriveApiService();
    final success = await _driveService!.connect(onLaunchUrl: onLaunchUrl);
    notifyListeners();
    return success;
  }

  /// Disconnect Google Drive
  Future<void> disconnectDrive() async {
    if (_driveService != null) {
      await _driveService!.disconnect();
      notifyListeners();
    }
  }

  /// Clear all data on sign out
  void clear() {
    _currentUid = null;
    _notes = [];
    _photos = [];
    _videos = [];
    _documents = [];
    _accounts = [];
    _safeWebsites = [];
    _cards = [];
    _identities = [];
    _trashItems = [];
    _firestoreService = null;
    _driveService?.signOut();
    _driveService = null;
    notifyListeners();
  }

  void _setupStreams() {
    // On Windows, subcollection .snapshots() crashes the native C++ Firebase SDK
    // (FlutterFire issue #18248). Use one-time .get() fetch instead.
    if (FirestoreService.usePolling) {
      _fetchAllData();
      return;
    }

    // --- Real-time streams for mobile platforms ---

    // Notes stream
    _firestoreService?.notesStream().listen(
      (notes) {
        _notes = notes;
        notifyListeners();
      },
      onError: (e) => debugPrint('Notes stream error: $e'),
    );

    // Photos stream
    _firestoreService?.filesStream(fileType: 'photo').listen(
      (files) {
        _photos = files;
        notifyListeners();
      },
      onError: (e) => debugPrint('Photos stream error: $e'),
    );

    // Videos stream
    _firestoreService?.filesStream(fileType: 'video').listen(
      (files) {
        _videos = files;
        notifyListeners();
      },
      onError: (e) => debugPrint('Videos stream error: $e'),
    );

    // Documents stream
    _firestoreService?.filesStream(fileType: 'document').listen(
      (files) {
        _documents = files;
        notifyListeners();
      },
      onError: (e) => debugPrint('Documents stream error: $e'),
    );

    // Accounts stream
    _firestoreService?.accountsStream().listen(
      (accounts) {
        _accounts = accounts;
        notifyListeners();
      },
      onError: (e) => debugPrint('Accounts stream error: $e'),
    );

    // Safe Websites stream
    _firestoreService?.safeWebsitesStream().listen(
      (websites) {
        _safeWebsites = websites;
        notifyListeners();
      },
      onError: (e) => debugPrint('Safe websites stream error: $e'),
    );

    // Payment Cards stream
    _firestoreService?.cardsStream().listen(
      (cards) {
        _cards = cards;
        notifyListeners();
      },
      onError: (e) => debugPrint('Cards stream error: $e'),
    );

    // Identities stream
    _firestoreService?.identitiesStream().listen(
      (identities) {
        _identities = identities;
        notifyListeners();
      },
      onError: (e) => debugPrint('Identities stream error: $e'),
    );

    // Trash stream
    _firestoreService?.trashStream().listen(
      (items) {
        _trashItems = items;
        notifyListeners();
      },
      onError: (e) => debugPrint('Trash stream error: $e'),
    );
  }

  /// Windows-safe: fetch all data using one-time .get() calls
  Future<void> _fetchAllData() async {
    if (_firestoreService == null) return;
    try {
      _notes = await _firestoreService!.fetchNotes();
      _photos = await _firestoreService!.fetchFiles(fileType: 'photo');
      _videos = await _firestoreService!.fetchFiles(fileType: 'video');
      _documents = await _firestoreService!.fetchFiles(fileType: 'document');
      _accounts = await _firestoreService!.fetchAccounts();
      _safeWebsites = await _firestoreService!.fetchSafeWebsites();
      _cards = await _firestoreService!.fetchCards();
      _identities = await _firestoreService!.fetchIdentities();
      _trashItems = await _firestoreService!.fetchTrash();

      _updateCountsLocally();
    } catch (e) {
      debugPrint('_fetchAllData error: $e');
    }
  }

  /// Manually refresh data (useful on Windows where real-time streams are disabled)
  Future<void> refreshData() async {
    if (FirestoreService.usePolling) {
      await _fetchAllData();
    } else {
      await _loadItemCounts();
    }
  }

  void _updateCountsLocally() {
    _itemCounts = {
      'notes': _notes.length,
      'photos': _photos.length,
      'videos': _videos.length,
      'gallery': _photos.length + _videos.length,
      'documents': _documents.length,
      'accounts': _accounts.length,
      'websites': _safeWebsites.length,
      'cards': _cards.length,
      'identities': _identities.length,
      'trash': _trashItems.length,
    };
    notifyListeners();
  }

  Future<void> _loadItemCounts() async {
    if (FirestoreService.usePolling) {
      _updateCountsLocally();
      return;
    }
    try {
      _itemCounts = await _firestoreService?.getItemCounts() ?? {};
      notifyListeners();
    } catch (e) {
      debugPrint('Load item counts error: $e');
    }
  }

  Future<void> _purgeExpiredTrash() async {
    try {
      await _firestoreService?.purgeExpiredTrash();
    } catch (e) {
      debugPrint('Purge expired trash error: $e');
    }
  }

  // ==================== NOTES ====================

  Future<void> addNote({required String title, required String content, int? color}) async {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(),
      title: title,
      content: content,
      color: color ?? Note.availableColors[0],
      createdAt: now,
      updatedAt: now,
    );
    
    // Optimistic Update
    _notes.insert(0, note);
    notifyListeners();

    await _firestoreService?.addNote(note);
    await _loadItemCounts();
  }

  Future<void> updateNote(Note note) async {
    // Optimistic Update
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      notifyListeners();
    }
    
    await _firestoreService?.updateNote(note);
  }

  Future<void> deleteNote(String noteId) async {
    // Optimistic Update
    _notes.removeWhere((n) => n.id == noteId);
    notifyListeners();

    await _firestoreService?.deleteNote(noteId);
    await _loadItemCounts();
  }

  Future<void> togglePinNote(Note note) async {
    final updated = note.copyWith(isPinned: !note.isPinned);
    
    // Optimistic Update
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = updated;
      _notes.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      notifyListeners();
    }

    await _firestoreService?.updateNote(updated);
  }

  // ==================== FILES ====================

  Future<void> uploadFile(File file, String fileType) async {
    if (_firestoreService == null) return;
    _driveService ??= DriveApiService();

    if (!_driveService!.isConnected) {
      await _driveService!.signInSilently();
    }

    if (!_driveService!.isConnected) {
      _error = 'Google Drive غير متصل. يرجى ربط حسابك أولاً.';
      notifyListeners();
      throw Exception('Google Drive غير متصل. يرجى ربط حسابك أولاً.');
    }

    _isUploading = true;
    _uploadProgress = 0.0;
    _error = null;
    notifyListeners();

    try {
      final fileName = file.path.split('/').last.split('\\').last;
      final fileId = _uuid.v4();
      final backupName = '${fileId}_$fileName';

      final result = await _driveService!.backupFile(file, backupName);
      if (result == null || result.id == null) {
        throw Exception('فشل الرفع لمساحة التخزين المشفرة');
      }

      final vaultFile = VaultFile(
        id: fileId,
        fileName: fileName,
        fileType: fileType,
        mimeType: _getMimeType(file.path),
        fileSize: await file.length(),
        storagePath: result.id!,
        downloadUrl: 'drive',
        createdAt: DateTime.now(),
      );

      // Optimistic Update
      if (vaultFile.isPhoto) _photos.insert(0, vaultFile);
      if (vaultFile.isVideo) _videos.insert(0, vaultFile);
      if (vaultFile.isDocument) _documents.insert(0, vaultFile);
      notifyListeners();

      await _firestoreService!.addFile(vaultFile);
      await _loadItemCounts();
    } catch (e) {
      _error = 'فشل في رفع الملف: ${e.toString()}';
      rethrow;
    } finally {
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }

  Future<void> deleteFile(VaultFile file) async {
    // Optimistic Update
    if (file.isPhoto) _photos.removeWhere((f) => f.id == file.id);
    if (file.isVideo) _videos.removeWhere((f) => f.id == file.id);
    if (file.isDocument) _documents.removeWhere((f) => f.id == file.id);
    notifyListeners();

    await _firestoreService?.deleteFile(file.id);
    // Keep storage file for trash restoration
    await _loadItemCounts();
  }

  Future<void> permanentDeleteFile(VaultFile file) async {
    // Optimistic Update
    if (file.isPhoto) _photos.removeWhere((f) => f.id == file.id);
    if (file.isVideo) _videos.removeWhere((f) => f.id == file.id);
    if (file.isDocument) _documents.removeWhere((f) => f.id == file.id);
    notifyListeners();

    await _driveService?.deleteBackedUpFile(file.storagePath);
    await _firestoreService?.deleteFile(file.id);
    await _loadItemCounts();
  }

  /// Get locally cached, decrypted file for UI viewing
  Future<File?> getMediaFile(VaultFile file) async {
    if (_driveService == null || _currentUid == null) return null;
    return await _driveService!.getDecryptedFile(file.storagePath, file.fileName, _currentUid!);
  }

  /// Expose Drive Service to get decrypted files in UI
  DriveApiService? get driveService => _driveService;

  // ==================== ACCOUNTS ====================

  Future<void> addAccount({
    required String serviceName,
    required String username,
    required String password,
    String? notes,
    String? websiteUrl,
  }) async {
    final now = DateTime.now();
    final account = AccountEntry(
      id: _uuid.v4(),
      serviceName: serviceName,
      username: username,
      password: password,
      notes: notes,
      websiteUrl: websiteUrl,
      createdAt: now,
      updatedAt: now,
    );
    
    // Optimistic Update
    _accounts.insert(0, account);
    notifyListeners();

    await _firestoreService?.addAccount(account);
    await _loadItemCounts();
  }

  Future<void> updateAccount(AccountEntry account) async {
    // Optimistic Update
    final index = _accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      _accounts[index] = account;
      notifyListeners();
    }

    await _firestoreService?.updateAccount(account);
  }

  Future<void> deleteAccount(String accountId) async {
    // Optimistic Update
    _accounts.removeWhere((a) => a.id == accountId);
    notifyListeners();

    await _firestoreService?.deleteAccount(accountId);
    await _loadItemCounts();
  }

  // ==================== SAFE WEBSITES ====================

  Future<void> addSafeWebsite({
    required String name,
    required String url,
    required String username,
    required String password,
    String? notes,
  }) async {
    final now = DateTime.now();
    final website = SafeWebsite(
      id: _uuid.v4(),
      name: name,
      url: url,
      username: username,
      password: password,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    // Optimistic Update
    _safeWebsites.insert(0, website);
    notifyListeners();

    await _firestoreService?.addSafeWebsite(website);
    await _loadItemCounts();
  }

  Future<void> updateSafeWebsite(SafeWebsite website) async {
    // Optimistic Update
    final index = _safeWebsites.indexWhere((w) => w.id == website.id);
    if (index != -1) {
      _safeWebsites[index] = website;
      notifyListeners();
    }

    await _firestoreService?.updateSafeWebsite(website);
  }

  Future<void> deleteSafeWebsite(String websiteId) async {
    // Optimistic Update
    _safeWebsites.removeWhere((w) => w.id == websiteId);
    notifyListeners();

    await _firestoreService?.deleteSafeWebsite(websiteId);
    await _loadItemCounts();
  }

  // ==================== PAYMENT CARDS ====================

  Future<void> addCard(PaymentCard card) async {
    // Optimistic Update
    _cards.insert(0, card);
    notifyListeners();

    await _firestoreService?.addCard(card);
    await _loadItemCounts();
  }

  Future<void> updateCard(PaymentCard card) async {
    // Optimistic Update
    final index = _cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      _cards[index] = card;
      notifyListeners();
    }

    await _firestoreService?.updateCard(card);
  }

  Future<void> deleteCard(String cardId) async {
    // Optimistic Update
    _cards.removeWhere((c) => c.id == cardId);
    notifyListeners();

    await _firestoreService?.deleteCard(cardId);
    await _loadItemCounts();
  }

  // ==================== IDENTITIES ====================

  Future<void> addIdentity(IdentityCard identity) async {
    // Optimistic Update
    _identities.insert(0, identity);
    notifyListeners();

    await _firestoreService?.addIdentity(identity);
    await _loadItemCounts();
  }

  Future<void> updateIdentity(IdentityCard identity) async {
    // Optimistic Update
    final index = _identities.indexWhere((i) => i.id == identity.id);
    if (index != -1) {
      _identities[index] = identity;
      notifyListeners();
    }

    await _firestoreService?.updateIdentity(identity);
  }

  Future<void> deleteIdentity(String identityId) async {
    // Optimistic Update
    _identities.removeWhere((i) => i.id == identityId);
    notifyListeners();

    await _firestoreService?.deleteIdentity(identityId);
    await _loadItemCounts();
  }

  // ==================== TRASH ====================

  Future<void> restoreFromTrash(TrashItem item) async {
    _trashItems.removeWhere((t) => t.id == item.id);
    notifyListeners();

    await _firestoreService?.restoreFromTrash(item);
    await _loadItemCounts();
  }

  Future<void> permanentDeleteFromTrash(String trashId) async {
    _trashItems.removeWhere((t) => t.id == trashId);
    notifyListeners();

    await _firestoreService?.permanentDeleteFromTrash(trashId);
    await _loadItemCounts();
  }

  Future<void> emptyTrash() async {
    _trashItems.clear();
    notifyListeners();

    await _firestoreService?.emptyTrash();
    await _loadItemCounts();
  }

  // ==================== SEARCH ====================

  Future<Map<String, List<dynamic>>> searchAll(String query) async {
    return await _firestoreService?.searchAll(query) ?? {};
  }

  // ==================== HELPERS ====================

  String _getMimeType(String filePath) {
    final parts = filePath.split('.');
    final ext = parts.length > 1 ? parts.last.toLowerCase() : '';
    if (AppConstants.imageExtensions.contains(ext)) return 'image/$ext';
    if (AppConstants.videoExtensions.contains(ext)) return 'video/$ext';
    return 'application/$ext';
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
