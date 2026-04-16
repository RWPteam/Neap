import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account_model.dart';

class StorageService {
  static const String _accountsKey = 'totp_accounts';

  Future<List<TotpAccount>> getAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_accountsKey);
      if (data == null) return [];
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((e) => TotpAccount.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
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
    final prefs = await SharedPreferences.getInstance();
    final jsonList = accounts.map((a) => a.toJson()).toList();
    await prefs.setString(_accountsKey, jsonEncode(jsonList));
  }
}
