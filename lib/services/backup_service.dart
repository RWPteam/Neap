import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';
import '../models/account_model.dart';

class BackupService {
  static final Random _random = Random.secure();

  static Future<Directory> getBackupDirectory() async {
    Directory? backupDir;

    if (Platform.isAndroid) {
      final externalDirs = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );
      if (externalDirs != null && externalDirs.isNotEmpty) {
        backupDir = Directory('${externalDirs.first.path}/neap');
      }
    }

    if (backupDir == null) {
      final downloadDir = await getDownloadsDirectory();
      if (downloadDir == null) {
        throw Exception('Cannot access Downloads directory');
      }
      backupDir = Directory('${downloadDir.path}/neap');
    }

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    return backupDir;
  }

  static Future<String> encryptBackup(
    List<TotpAccount> accounts,
    String password,
  ) async {
    try {
      final salt = _randomBytes(16);
      final iv = encrypt.IV.fromSecureRandom(16);
      final key = _deriveAesKey(password, salt);

      final accountsJson = jsonEncode(
        accounts.map((acc) => acc.toJson()).toList(),
      );

      final cipher = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
      final encrypted = cipher.encrypt(accountsJson, iv: iv);

      final backup = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'salt': base64Url.encode(salt),
        'iv': base64Url.encode(iv.bytes),
        'data': encrypted.base64,
      };

      return jsonEncode(backup);
    } catch (e) {
      throw Exception('加密失败: $e');
    }
  }

  static Future<List<TotpAccount>> decryptBackup(
    String encryptedBackup,
    String password,
  ) async {
    try {
      final backupData = jsonDecode(encryptedBackup) as Map<String, dynamic>;
      final salt = base64Url.decode(backupData['salt'] as String);
      final iv = encrypt.IV(base64Url.decode(backupData['iv'] as String));
      final encryptedData = backupData['data'] as String;
      final key = _deriveAesKey(password, salt);

      final cipher = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
      final decrypted = cipher.decrypt64(encryptedData, iv: iv);

      final accountsJson = jsonDecode(decrypted) as List<dynamic>;
      return accountsJson
          .map((acc) => TotpAccount.fromJson(acc as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('解密失败: $e');
    }
  }

  static encrypt.Key _deriveAesKey(String password, List<int> salt) {
    final combined = Uint8List.fromList([...utf8.encode(password), ...salt]);
    final digest = sha256.convert(combined);
    return encrypt.Key(Uint8List.fromList(digest.bytes));
  }

  static Uint8List _randomBytes(int length) {
    return Uint8List.fromList(
      List<int>.generate(length, (_) => _random.nextInt(256)),
    );
  }

  static Future<String> exportBackupToFile(
    String encryptedBackup,
    String filename,
  ) async {
    try {
      final backupDir = await getBackupDirectory();
      final file = File('${backupDir.path}/$filename');
      await file.writeAsString(encryptedBackup);
      return file.path;
    } catch (e) {
      throw Exception('导出失败: $e');
    }
  }

  static Future<String> importBackupFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在: $filePath');
      }
      return await file.readAsString();
    } catch (e) {
      throw Exception('导入失败: $e');
    }
  }

  static bool isValidBackupFormat(String content) {
    try {
      final data = jsonDecode(content) as Map<String, dynamic>;
      return data.containsKey('version') &&
          data.containsKey('salt') &&
          data.containsKey('iv') &&
          data.containsKey('data');
    } catch (e) {
      return false;
    }
  }

  static Map<String, dynamic>? getBackupMetadata(String encryptedBackup) {
    try {
      final backupData = jsonDecode(encryptedBackup) as Map<String, dynamic>;
      return {
        'version': backupData['version'] ?? 'unknown',
        'timestamp': backupData['timestamp'] ?? 'unknown',
      };
    } catch (e) {
      return null;
    }
  }

  static Future<List<File>> listBackupFiles() async {
    try {
      final backupDir = await getBackupDirectory();
      final files = backupDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.bin'))
          .toList();
      return files;
    } catch (e) {
      return [];
    }
  }
}
