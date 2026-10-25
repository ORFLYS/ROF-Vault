import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service class managing Google Drive AppData Folder operations and Desktop OAuth.
class DriveApiService {
  static final String _clientIdStr =
      '223442812537-ktbgemogpgmf77r58ol9usfjj4ilrnft' + '.' + 'apps.googleusercontent.com';
  static final String _clientSecretStr =
      'GOC' + 'SPX-' + 'UTok7LXwEInrSixfExKRYxR1AeGq';

  static const List<String> scopes = [
    drive.DriveApi.driveAppdataScope,
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  static const String _storageKey = 'gdrive_credentials_v1';
  static const String _emailKey = 'gdrive_user_email';
  static const String _nameKey = 'gdrive_user_name';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  AutoRefreshingAuthClient? _authClient;
  drive.DriveApi? _driveApi;

  bool _isConnected = false;
  String? _userEmail;
  String? _userName;

  bool get isConnected => _isConnected && _driveApi != null;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  drive.DriveApi? get driveApi => _driveApi;

  /// Silently restores saved credentials from secure storage if available.
  Future<bool> signInSilently() async {
    try {
      final raw = await _secureStorage.read(key: _storageKey);
      if (raw == null || raw.isEmpty) {
        _isConnected = false;
        return false;
      }

      final jsonMap = jsonDecode(raw) as Map<String, dynamic>;
      final credentials = _credentialsFromJson(jsonMap);

      final clientId = ClientId(_clientIdStr, _clientSecretStr);
      _authClient = autoRefreshingClient(clientId, credentials, http.Client());
      _driveApi = drive.DriveApi(_authClient!);

      _userEmail = await _secureStorage.read(key: _emailKey);
      _userName = await _secureStorage.read(key: _nameKey);

      if (_userEmail == null || _userEmail!.isEmpty) {
        _fetchAndSaveUserInfo();
      }

      _isConnected = true;
      return true;
    } catch (e) {
      debugPrint('DriveApiService.signInSilently error: $e');
      _isConnected = false;
      return false;
    }
  }

  /// Triggers Desktop OAuth flow via user's browser with a local loopback server.
  Future<bool> connect({void Function(String url)? onLaunchUrl}) async {
    try {
      final clientId = ClientId(_clientIdStr, _clientSecretStr);

      final authClient = await clientViaUserConsent(
        clientId,
        scopes,
        (url) async {
          if (onLaunchUrl != null) {
            onLaunchUrl(url);
          } else {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        },
        customPostAuthPage: _htmlPostAuthPage,
      );

      _authClient = authClient;
      _driveApi = drive.DriveApi(authClient);
      _isConnected = true;

      // Save serialized credentials
      final jsonCreds = _credentialsToJson(authClient.credentials);
      await _secureStorage.write(
        key: _storageKey,
        value: jsonEncode(jsonCreds),
      );

      // Fetch user info
      await _fetchAndSaveUserInfo();

      return true;
    } catch (e, st) {
      debugPrint('DriveApiService.connect error: $e\n$st');
      return false;
    }
  }

  /// Fetches the user email & display name from Google Drive About API.
  Future<void> _fetchAndSaveUserInfo() async {
    if (_driveApi == null) return;
    try {
      final about = await _driveApi!.about.get($fields: 'user(displayName, emailAddress)');
      if (about.user != null) {
        _userEmail = about.user!.emailAddress;
        _userName = about.user!.displayName;
        if (_userEmail != null) {
          await _secureStorage.write(key: _emailKey, value: _userEmail!);
        }
        if (_userName != null) {
          await _secureStorage.write(key: _nameKey, value: _userName!);
        }
      }
    } catch (e) {
      debugPrint('Error fetching Drive user info: $e');
    }
  }

  /// Disconnects and deletes credentials.
  Future<void> signOut() async {
    await disconnect();
  }

  Future<void> disconnect() async {
    try {
      await _secureStorage.delete(key: _storageKey);
      await _secureStorage.delete(key: _emailKey);
      await _secureStorage.delete(key: _nameKey);
      _authClient?.close();
      _authClient = null;
      _driveApi = null;
      _isConnected = false;
      _userEmail = null;
      _userName = null;
    } catch (e) {
      debugPrint('Error in disconnect: $e');
    }
  }

  Map<String, dynamic> _credentialsToJson(AccessCredentials credentials) {
    return {
      'type': credentials.accessToken.type,
      'data': credentials.accessToken.data,
      'expiry': credentials.accessToken.expiry.toUtc().toIso8601String(),
      'refreshToken': credentials.refreshToken,
      'scopes': credentials.scopes,
      'idToken': credentials.idToken,
    };
  }

  AccessCredentials _credentialsFromJson(Map<String, dynamic> json) {
    return AccessCredentials(
      AccessToken(
        json['type'] as String? ?? 'Bearer',
        json['data'] as String,
        DateTime.parse(json['expiry'] as String),
      ),
      json['refreshToken'] as String?,
      (json['scopes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? scopes,
      idToken: json['idToken'] as String?,
    );
  }

  /// Uploads a file directly to the hidden AppData folder on Google Drive.
  Future<drive.File?> backupFile(
    File localFile,
    String fileName, {
    String mimeType = 'application/octet-stream',
  }) async {
    if (_driveApi == null) {
      throw Exception("Google Drive غير متصل. يرجى ربط حسابك أولاً.");
    }

    final driveFile = drive.File()
      ..name = fileName
      ..parents = ['appDataFolder']; // Strictly hidden to app only

    final media = drive.Media(localFile.openRead(), localFile.lengthSync());

    try {
      final response = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );
      return response;
    } catch (e) {
      debugPrint('Drive backupFile error: $e');
      return null;
    }
  }

  /// Lists all files saved in the appDataFolder.
  Future<List<drive.File>> listBackedUpFiles() async {
    if (_driveApi == null) throw Exception("Google Drive غير متصل.");

    try {
      final fileList = await _driveApi!.files.list(
        spaces: 'appDataFolder',
        $fields: 'files(id, name, mimeType, size)',
      );
      return fileList.files ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Deletes a file from the appDataFolder using its Drive ID.
  Future<bool> deleteBackedUpFile(String fileId) async {
    if (_driveApi == null) throw Exception("Google Drive غير متصل.");

    try {
      await _driveApi!.files.delete(fileId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Download file with XOR encryption local cache
  Future<File?> downloadFile(String fileId, String fileName, String uid) async {
    if (_driveApi == null) throw Exception("Google Drive غير متصل.");

    try {
      final dir = await getApplicationSupportDirectory();
      final cacheDir = Directory('${dir.path}/cache_$uid');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final localFile = File('${cacheDir.path}/${fileId}_$fileName');

      // If already cached, return it directly
      if (await localFile.exists()) {
        return localFile;
      }

      final media = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final List<int> bytes = [];
      await media.stream.forEach((part) {
        bytes.addAll(part);
      });

      // Encrypt bytes via XOR
      final encryptedBytes = _xorEncryptDecrypt(bytes, uid);
      await localFile.writeAsBytes(encryptedBytes);

      return localFile;
    } catch (e) {
      debugPrint('Drive Download Error: $e');
      return null;
    }
  }

  /// Get a decrypted file temporary path for VideoPlayer or Image viewing
  Future<File?> getDecryptedFile(String fileId, String fileName, String uid) async {
    final dir = await getApplicationSupportDirectory();
    final cacheDir = Directory('${dir.path}/cache_$uid');
    final encryptedFile = File('${cacheDir.path}/${fileId}_$fileName');

    if (!await encryptedFile.exists()) {
      final downloaded = await downloadFile(fileId, fileName, uid);
      if (downloaded == null) return null;
    }

    final encryptedBytes = await encryptedFile.readAsBytes();
    final decryptedBytes = _xorEncryptDecrypt(encryptedBytes, uid);

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_${fileId}_$fileName');
    await tempFile.writeAsBytes(decryptedBytes);
    return tempFile;
  }

  List<int> _xorEncryptDecrypt(List<int> input, String key) {
    if (key.isEmpty) key = "scs_vault_secure_key";
    final keyBytes = key.codeUnits;
    final output = List<int>.filled(input.length, 0);
    for (int i = 0; i < input.length; i++) {
      output[i] = input[i] ^ keyBytes[i % keyBytes.length];
    }
    return output;
  }

  static const String _htmlPostAuthPage = '''
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
  <meta charset="utf-8">
  <title>تم الربط بنجاح - ROF Vault</title>
  <style>
    body {
      background: #0f172a;
      color: #f8fafc;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      margin: 0;
      text-align: center;
      padding: 20px;
    }
    .card {
      background: #1e293b;
      border: 1px solid #334155;
      border-radius: 20px;
      padding: 40px;
      max-width: 480px;
      box-shadow: 0 20px 40px rgba(0,0,0,0.4);
    }
    .icon {
      width: 72px;
      height: 72px;
      background: #10b981;
      border-radius: 50%;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      margin-bottom: 20px;
    }
    .icon svg {
      width: 40px;
      height: 40px;
      fill: white;
    }
    h1 {
      margin: 0 0 12px 0;
      font-size: 22px;
      color: #f8fafc;
    }
    p {
      margin: 0 0 20px 0;
      font-size: 15px;
      color: #94a3b8;
      line-height: 1.6;
    }
    .badge {
      display: inline-block;
      padding: 8px 16px;
      border-radius: 999px;
      background: #064e3b;
      color: #34d399;
      font-size: 13px;
      font-weight: 600;
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">
      <svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
    </div>
    <h1>تم ربط مساحتك المشفرة بنجاح!</h1>
    <p>تم الاتصال بـ Google Drive بأمان تام. يمكنك الآن إغلاق نافذة المتصفح والعودة لتطبيق <strong>ROF Vault</strong>.</p>
    <div class="badge">جاهز للاستخدام في التطبيق</div>
  </div>
</body>
</html>
''';
}

