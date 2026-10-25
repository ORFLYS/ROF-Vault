import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';
import '../models/note.dart';
import '../models/vault_file.dart';
import '../models/account_entry.dart';
import '../models/safe_website.dart';
import '../models/payment_card.dart';
import '../models/identity_card.dart';
import '../models/trash_item.dart';

/// Whether to use one-time .get() instead of real-time .snapshots()
/// Windows C++ Firebase SDK crashes on subcollection snapshot listeners
bool get _usePolling => Platform.isWindows;

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String uid;

  FirestoreService({required this.uid});

  // === References ===
  CollectionReference get _notesRef =>
      _firestore.collection('users').doc(uid).collection(AppConstants.notesSubcollection);

  CollectionReference get _filesRef =>
      _firestore.collection('users').doc(uid).collection(AppConstants.filesSubcollection);

  CollectionReference get _accountsRef =>
      _firestore.collection('users').doc(uid).collection(AppConstants.accountsSubcollection);

  CollectionReference get _websitesRef =>
      _firestore.collection('users').doc(uid).collection(AppConstants.websitesSubcollection);

  CollectionReference get _cardsRef =>
      _firestore.collection('users').doc(uid).collection(AppConstants.cardsSubcollection);

  CollectionReference get _identitiesRef =>
      _firestore.collection('users').doc(uid).collection(AppConstants.idsSubcollection);

  CollectionReference get _trashRef =>
      _firestore.collection('users').doc(uid).collection(AppConstants.trashSubcollection);

  // ==================== NOTES ====================

  Stream<List<Note>> notesStream() {
    return _notesRef
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) =>
              Note.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
          .toList();
      list.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      return list;
    });
  }

  Future<List<Note>> getNotesPaginated({DocumentSnapshot? lastDoc}) async {
    Query query = _notesRef
        .orderBy('updatedAt', descending: true)
        .limit(AppConstants.pageSize);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Note.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
        .toList();
  }

  Future<void> addNote(Note note) async {
    await _notesRef.doc(note.id).set(note.toMap());
  }

  Future<void> updateNote(Note note) async {
    await _notesRef.doc(note.id).update(note.toMap());
  }

  Future<void> deleteNote(String noteId) async {
    // Get note data first for trash
    final doc = await _notesRef.doc(noteId).get();
    if (doc.exists) {
      await _moveToTrash('note', noteId, doc.data() as Map<String, dynamic>);
      await _notesRef.doc(noteId).delete();
    }
  }

  // ==================== FILES ====================

  Stream<List<VaultFile>> filesStream({String? fileType}) {
    return _filesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      var list = snapshot.docs
          .map((doc) => VaultFile.fromMap(
              doc.data() as Map<String, dynamic>,
              docId: doc.id))
          .toList();
      if (fileType != null) {
        list = list.where((f) => f.fileType == fileType).toList();
      }
      return list;
    });
  }

  Future<List<VaultFile>> getFilesPaginated({
    String? fileType,
    DocumentSnapshot? lastDoc,
  }) async {
    Query query = _filesRef.orderBy('createdAt', descending: true);
    query = query.limit(AppConstants.pageSize);
    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();
    var list = snapshot.docs
        .map((doc) => VaultFile.fromMap(
            doc.data() as Map<String, dynamic>,
            docId: doc.id))
        .toList();
    if (fileType != null) {
      list = list.where((f) => f.fileType == fileType).toList();
    }
    return list;
  }

  Future<void> addFile(VaultFile file) async {
    await _filesRef.doc(file.id).set(file.toMap());
  }

  Future<void> deleteFile(String fileId) async {
    final doc = await _filesRef.doc(fileId).get();
    if (doc.exists) {
      await _moveToTrash('file', fileId, doc.data() as Map<String, dynamic>);
      await _filesRef.doc(fileId).delete();
    }
  }

  // ==================== ACCOUNTS ====================

  Stream<List<AccountEntry>> accountsStream() {
    return _accountsRef
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                AccountEntry.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
            .toList());
  }

  Future<void> addAccount(AccountEntry account) async {
    await _accountsRef.doc(account.id).set(account.toMap());
  }

  Future<void> updateAccount(AccountEntry account) async {
    await _accountsRef.doc(account.id).update(account.toMap());
  }

  Future<void> deleteAccount(String accountId) async {
    final doc = await _accountsRef.doc(accountId).get();
    if (doc.exists) {
      await _moveToTrash('account', accountId, doc.data() as Map<String, dynamic>);
      await _accountsRef.doc(accountId).delete();
    }
  }

  // ==================== SAFE WEBSITES ====================

  Stream<List<SafeWebsite>> safeWebsitesStream() {
    return _websitesRef
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                SafeWebsite.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
            .toList());
  }

  Future<void> addSafeWebsite(SafeWebsite website) async {
    await _websitesRef.doc(website.id).set(website.toMap());
  }

  Future<void> updateSafeWebsite(SafeWebsite website) async {
    await _websitesRef.doc(website.id).update(website.toMap());
  }

  Future<void> deleteSafeWebsite(String websiteId) async {
    final doc = await _websitesRef.doc(websiteId).get();
    if (doc.exists) {
      await _moveToTrash('website', websiteId, doc.data() as Map<String, dynamic>);
      await _websitesRef.doc(websiteId).delete();
    }
  }

  // ==================== PAYMENT CARDS ====================

  Stream<List<PaymentCard>> cardsStream() {
    return _cardsRef
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                PaymentCard.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
            .toList());
  }

  Future<void> addCard(PaymentCard card) async {
    await _cardsRef.doc(card.id).set(card.toMap());
  }

  Future<void> updateCard(PaymentCard card) async {
    await _cardsRef.doc(card.id).update(card.toMap());
  }

  Future<void> deleteCard(String cardId) async {
    final doc = await _cardsRef.doc(cardId).get();
    if (doc.exists) {
      await _moveToTrash('card', cardId, doc.data() as Map<String, dynamic>);
      await _cardsRef.doc(cardId).delete();
    }
  }

  // ==================== IDENTITIES ====================

  Stream<List<IdentityCard>> identitiesStream() {
    return _identitiesRef
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                IdentityCard.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
            .toList());
  }

  Future<void> addIdentity(IdentityCard identity) async {
    await _identitiesRef.doc(identity.id).set(identity.toMap());
  }

  Future<void> updateIdentity(IdentityCard identity) async {
    await _identitiesRef.doc(identity.id).update(identity.toMap());
  }

  Future<void> deleteIdentity(String identityId) async {
    final doc = await _identitiesRef.doc(identityId).get();
    if (doc.exists) {
      await _moveToTrash('identity', identityId, doc.data() as Map<String, dynamic>);
      await _identitiesRef.doc(identityId).delete();
    }
  }

  // ==================== TRASH ====================

  Stream<List<TrashItem>> trashStream() {
    return _trashRef
        .orderBy('deletedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                TrashItem.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
            .toList());
  }

  Future<void> _moveToTrash(
      String type, String originalId, Map<String, dynamic> data) async {
    final now = DateTime.now();
    final trashItem = TrashItem(
      id: '${type}_${originalId}_${now.millisecondsSinceEpoch}',
      originalType: type,
      originalId: originalId,
      data: data,
      deletedAt: now,
      autoDeleteAt: now.add(const Duration(days: AppConstants.trashRetentionDays)),
    );
    await _trashRef.doc(trashItem.id).set(trashItem.toMap());
  }

  Future<void> restoreFromTrash(TrashItem item) async {
    // Restore to original collection
    switch (item.originalType) {
      case 'note':
        await _notesRef.doc(item.originalId).set(item.data);
        break;
      case 'file':
        await _filesRef.doc(item.originalId).set(item.data);
        break;
      case 'account':
        await _accountsRef.doc(item.originalId).set(item.data);
        break;
      case 'website':
        await _websitesRef.doc(item.originalId).set(item.data);
        break;
      case 'card':
        await _cardsRef.doc(item.originalId).set(item.data);
        break;
      case 'identity':
        await _identitiesRef.doc(item.originalId).set(item.data);
        break;
    }
    // Remove from trash
    await _trashRef.doc(item.id).delete();
  }

  Future<void> permanentDeleteFromTrash(String trashId) async {
    await _trashRef.doc(trashId).delete();
  }

  Future<void> emptyTrash() async {
    final snapshot = await _trashRef.get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> purgeExpiredTrash() async {
    final snapshot = await _trashRef
        .where('autoDeleteAt', isLessThan: Timestamp.fromDate(DateTime.now()))
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  // ==================== SEARCH ====================

  Future<Map<String, List<dynamic>>> searchAll(String query) async {
    final lowerQuery = query.toLowerCase();
    final results = <String, List<dynamic>>{
      'notes': [],
      'files': [],
      'accounts': [],
      'cards': [],
      'identities': [],
    };

    // Search notes
    final notesSnapshot = await _notesRef.get();
    for (final doc in notesSnapshot.docs) {
      final note = Note.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
      if (note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery)) {
        results['notes']!.add(note);
      }
    }

    // Search files
    final filesSnapshot = await _filesRef.get();
    for (final doc in filesSnapshot.docs) {
      final file = VaultFile.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
      if (file.fileName.toLowerCase().contains(lowerQuery)) {
        results['files']!.add(file);
      }
    }

    // Search accounts
    final accountsSnapshot = await _accountsRef.get();
    for (final doc in accountsSnapshot.docs) {
      final account =
          AccountEntry.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
      if (account.serviceName.toLowerCase().contains(lowerQuery) ||
          account.username.toLowerCase().contains(lowerQuery)) {
        results['accounts']!.add(account);
      }
    }

    // Search cards
    final cardsSnapshot = await _cardsRef.get();
    for (final doc in cardsSnapshot.docs) {
      final card =
          PaymentCard.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
      if (card.cardHolderName.toLowerCase().contains(lowerQuery) ||
          card.cardType.toLowerCase().contains(lowerQuery) ||
          (card.bankName?.toLowerCase().contains(lowerQuery) ?? false) ||
          card.cardNumber.contains(query)) {
        results['cards']!.add(card);
      }
    }

    // Search identities
    final idsSnapshot = await _identitiesRef.get();
    for (final doc in idsSnapshot.docs) {
      final idCard =
          IdentityCard.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
      if (idCard.title.toLowerCase().contains(lowerQuery) ||
          idCard.fullName.toLowerCase().contains(lowerQuery) ||
          idCard.idNumber.toLowerCase().contains(lowerQuery)) {
        results['identities']!.add(idCard);
      }
    }

    return results;
  }

  // ==================== STATS ====================

  Future<Map<String, int>> getItemCounts() async {
    try {
      final notesSnap = await _notesRef.get();
      final filesSnap = await _filesRef.get();
      final accountsSnap = await _accountsRef.get();
      final websitesSnap = await _websitesRef.get();
      final cardsSnap = await _cardsRef.get();
      final idsSnap = await _identitiesRef.get();
      final trashSnap = await _trashRef.get();

      int photosCount = 0;
      int videosCount = 0;
      int docsCount = 0;

      for (final doc in filesSnap.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;
        switch (data['fileType']) {
          case 'photo':
            photosCount++;
            break;
          case 'video':
            videosCount++;
            break;
          case 'document':
            docsCount++;
            break;
        }
      }

      return {
        'notes': notesSnap.docs.length,
        'photos': photosCount,
        'videos': videosCount,
        'gallery': photosCount + videosCount,
        'documents': docsCount,
        'accounts': accountsSnap.docs.length,
        'websites': websitesSnap.docs.length,
        'cards': cardsSnap.docs.length,
        'identities': idsSnap.docs.length,
        'trash': trashSnap.docs.length,
      };
    } catch (e) {
      debugPrint('getItemCounts error: $e');
      return {
        'notes': 0,
        'photos': 0,
        'videos': 0,
        'gallery': 0,
        'documents': 0,
        'accounts': 0,
        'websites': 0,
        'cards': 0,
        'identities': 0,
        'trash': 0,
      };
    }
  }

  // ==================== WINDOWS-SAFE ONE-TIME FETCH ====================
  // These use .get() instead of .snapshots() to avoid the Windows C++ SDK
  // crash on subcollection snapshot listeners (FlutterFire issue #18248).

  static bool get usePolling => _usePolling;

  Future<List<Note>> fetchNotes() async {
    try {
      final snapshot =
          await _notesRef.orderBy('updatedAt', descending: true).get();
      final list = snapshot.docs
          .map((doc) =>
              Note.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
          .toList();
      list.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      return list;
    } catch (e) {
      debugPrint('fetchNotes error: $e');
      return [];
    }
  }

  Future<List<VaultFile>> fetchFiles({String? fileType}) async {
    try {
      final snapshot =
          await _filesRef.orderBy('createdAt', descending: true).get();
      var list = snapshot.docs
          .map((doc) => VaultFile.fromMap(
              doc.data() as Map<String, dynamic>,
              docId: doc.id))
          .toList();
      if (fileType != null) {
        list = list.where((f) => f.fileType == fileType).toList();
      }
      return list;
    } catch (e) {
      debugPrint('fetchFiles error: $e');
      return [];
    }
  }

  Future<List<AccountEntry>> fetchAccounts() async {
    try {
      final snapshot =
          await _accountsRef.orderBy('updatedAt', descending: true).get();
      return snapshot.docs
          .map((doc) => AccountEntry.fromMap(
              doc.data() as Map<String, dynamic>,
              docId: doc.id))
          .toList();
    } catch (e) {
      debugPrint('fetchAccounts error: $e');
      return [];
    }
  }

  Future<List<SafeWebsite>> fetchSafeWebsites() async {
    try {
      final snapshot =
          await _websitesRef.orderBy('updatedAt', descending: true).get();
      return snapshot.docs
          .map((doc) => SafeWebsite.fromMap(
              doc.data() as Map<String, dynamic>,
              docId: doc.id))
          .toList();
    } catch (e) {
      debugPrint('fetchSafeWebsites error: $e');
      return [];
    }
  }

  Future<List<PaymentCard>> fetchCards() async {
    try {
      final snapshot =
          await _cardsRef.orderBy('updatedAt', descending: true).get();
      return snapshot.docs
          .map((doc) => PaymentCard.fromMap(
              doc.data() as Map<String, dynamic>,
              docId: doc.id))
          .toList();
    } catch (e) {
      debugPrint('fetchCards error: $e');
      return [];
    }
  }

  Future<List<IdentityCard>> fetchIdentities() async {
    try {
      final snapshot =
          await _identitiesRef.orderBy('updatedAt', descending: true).get();
      return snapshot.docs
          .map((doc) => IdentityCard.fromMap(
              doc.data() as Map<String, dynamic>,
              docId: doc.id))
          .toList();
    } catch (e) {
      debugPrint('fetchIdentities error: $e');
      return [];
    }
  }

  Future<List<TrashItem>> fetchTrash() async {
    try {
      final snapshot =
          await _trashRef.orderBy('deletedAt', descending: true).get();
      return snapshot.docs
          .map((doc) => TrashItem.fromMap(
              doc.data() as Map<String, dynamic>,
              docId: doc.id))
          .toList();
    } catch (e) {
      debugPrint('fetchTrash error: $e');
      return [];
    }
  }
}
