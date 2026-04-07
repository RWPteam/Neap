import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/account_model.dart';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _accountsKey = 'totp_accounts';

  Future<List<TotpAccount>> getAccounts() async {
    final String? data = await _storage.read(key: _accountsKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => TotpAccount.fromJson(e)).toList();
  }

  Future<void> saveAccount(TotpAccount account) async {
    final accounts = await getAccounts();
    accounts.add(account);
    await _saveAccounts(accounts);
  }

  Future<void> deleteAccount(String id) async {
    final accounts = await getAccounts();
    accounts.removeWhere((a) => a.id == id);
    await _saveAccounts(accounts);
  }

  Future<void> updateAccount(TotpAccount updatedAccount) async {
    final accounts = await getAccounts();
    final index = accounts.indexWhere((a) => a.id == updatedAccount.id);
    if (index != -1) {
      accounts[index] = updatedAccount;
      await _saveAccounts(accounts);
    }
  }

  Future<void> replaceAccounts(List<TotpAccount> accounts) async {
    await _saveAccounts(accounts);
  }

  Future<void> _saveAccounts(List<TotpAccount> accounts) async {
    final jsonList = accounts.map((a) => a.toJson()).toList();
    await _storage.write(key: _accountsKey, value: jsonEncode(jsonList));
  }
}
