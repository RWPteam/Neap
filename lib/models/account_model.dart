import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class TotpAccount {
  final String id;
  final String label;
  final String issuer;
  final String secret;
  final int interval;
  final int digits;
  final String avatarType;
  final String? avatarImagePath;
  final String algorithm;

  TotpAccount({
    required this.id,
    required this.label,
    required this.issuer,
    required this.secret,
    this.interval = 30,
    this.digits = 6,
    this.avatarType = 'auto',
    this.avatarImagePath,
    this.algorithm = 'SHA1',
  });

  String generateCode() {
    final secretBytes = _decodeSecret(secret);
    final time = DateTime.now().millisecondsSinceEpoch ~/ 1000 ~/ interval;

    final timeBytes = Uint8List(8)
      ..buffer.asByteData().setInt64(0, time, Endian.big);

    final Hash hashAlgorithm = _getHashAlgorithm(algorithm);
    final hmac = Hmac(hashAlgorithm, secretBytes);
    final hash = hmac.convert(timeBytes).bytes;

    final offset = hash[hash.length - 1] & 0xf;
    final binary =
        ((hash[offset] & 0x7f) << 24) |
        ((hash[offset + 1] & 0xff) << 16) |
        ((hash[offset + 2] & 0xff) << 8) |
        (hash[offset + 3] & 0xff);

    final divisor = _pow(10, digits);
    final code = binary % divisor;

    return code.toString().padLeft(digits, '0');
  }

  static Hash _getHashAlgorithm(String algorithm) {
    final upperAlgo = algorithm.toUpperCase();
    if (upperAlgo == 'SHA256') {
      return sha256;
    } else if (upperAlgo == 'SHA512') {
      return sha512;
    } else {
      return sha1;
    }
  }

  static List<int> _decodeSecret(String secret) {
    final processed = secret.replaceAll(RegExp(r'[ -]'), '').toUpperCase();

    if (_isBase32(processed)) {
      try {
        return _base32Decode(processed);
      } catch (e) {
        debugPrint('Base32 decode failed: $e');
      }
    }

    try {
      return base64.decode(processed);
    } catch (e) {
      debugPrint('Base64 decode failed: $e');
    }

    if (_isHex(processed)) {
      try {
        return _hexDecode(processed);
      } catch (e) {
        debugPrint('Hex decode failed: $e');
      }
    }

    try {
      return utf8.encode(secret);
    } catch (e) {
      return utf8.encode(secret);
    }
  }

  static bool _isBase32(String str) {
    final base32Chars = RegExp(r'^[A-Z2-7=]+$');
    return base32Chars.hasMatch(str);
  }

  static bool _isHex(String str) {
    final hexChars = RegExp(r'^[0-9A-F]+$', caseSensitive: false);
    return str.length.isEven && hexChars.hasMatch(str);
  }

  static List<int> _hexDecode(String hex) {
    final result = <int>[];
    for (int i = 0; i < hex.length; i += 2) {
      result.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return result;
  }

  static List<int> _base32Decode(String base32) {
    const base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final buffer = <int>[];
    var bits = 0;
    var value = 0;

    for (var char in base32.toUpperCase().codeUnits) {
      if (char == '='.codeUnitAt(0)) break;
      final index = base32Chars.indexOf(String.fromCharCode(char));
      if (index == -1) {
        throw ArgumentError('Invalid Base32 character: $char');
      }
      value = (value << 5) | index;
      bits += 5;

      if (bits >= 8) {
        buffer.add((value >> (bits - 8)) & 0xff);
        bits -= 8;
      }
    }
    return buffer;
  }

  static int _pow(int base, int exponent) {
    int result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'issuer': issuer,
    'secret': secret,
    'interval': interval,
    'digits': digits,
    'avatarType': avatarType,
    'avatarImagePath': avatarImagePath,
    'algorithm': algorithm,
  };

  factory TotpAccount.fromJson(Map<String, dynamic> json) {
    return TotpAccount(
      id: json['id'],
      label: json['label'],
      issuer: json['issuer'],
      secret: json['secret'],
      interval: json['interval'] ?? 30,
      digits: json['digits'] ?? 6,
      avatarType: json['avatarType'] ?? 'auto',
      avatarImagePath: json['avatarImagePath'],
      algorithm: json['algorithm'] ?? 'SHA1',
    );
  }

  String get resolvedAvatarType {
    if (avatarImagePath != null && avatarImagePath!.isNotEmpty) {
      return 'custom_image';
    }
    if (avatarType.isNotEmpty && avatarType != 'auto') {
      return avatarType;
    }

    final labelKey = label.toLowerCase();
    final issuerKey = issuer.toLowerCase();
    if (labelKey.contains('github') || labelKey.contains('git')) {
      return 'code';
    }
    if (labelKey.contains('google')) {
      return 'google';
    }
    if (labelKey.contains('microsoft') ||
        labelKey.contains('azure') ||
        labelKey.contains('office')) {
      return 'microsoft';
    }
    if (labelKey.contains('amazon') || labelKey.contains('aws')) {
      return 'shop';
    }
    if (labelKey.contains('apple')) {
      return 'apple';
    }

    if (issuerKey.contains('github') || issuerKey.contains('git')) {
      return 'code';
    }
    if (issuerKey.contains('google')) {
      return 'google';
    }
    if (issuerKey.contains('microsoft') ||
        issuerKey.contains('azure') ||
        issuerKey.contains('office')) {
      return 'microsoft';
    }
    if (issuerKey.contains('amazon') || issuerKey.contains('shop')) {
      return 'shop';
    }
    if (issuerKey.contains('apple')) {
      return 'apple';
    }

    return 'default';
  }

  IconData get avatarIcon {
    switch (resolvedAvatarType) {
      case 'code':
        return Icons.code;
      case 'google':
        //返回google logo，暂时用别的代替
        return Icons.logo_dev_sharp;
      case 'microsoft':
        return Icons.window;
      case 'shop':
        return Icons.shopping_cart;
      case 'apple':
        return Icons.apple;
      default:
        return Icons.account_circle;
    }
  }

  Widget getAvatarWidget({
    required double size,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    if (resolvedAvatarType == 'custom_image' && avatarImagePath != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: FileImage(File(avatarImagePath!)),
        backgroundColor: backgroundColor,
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor,
      child: Icon(avatarIcon, color: iconColor, size: size * 0.6),
    );
  }
}
