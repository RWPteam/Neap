import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/backup_service.dart';
import '../../services/storage_service.dart';
import '../../services/setting_service.dart';
import '../../l10n/app_localizations.dart';

class GlobalSettingsPage extends StatefulWidget {
  final SettingsService settingsService;
  final Function() onSettingsChanged;

  const GlobalSettingsPage({
    super.key,
    required this.settingsService,
    required this.onSettingsChanged,
  });

  @override
  State<GlobalSettingsPage> createState() => _GlobalSettingsPageState();
}

class _GlobalSettingsPageState extends State<GlobalSettingsPage> {
  bool _isLoading = true;
  String _language = 'system';
  bool _requireBiometrics = true;
  bool _preventScreenshot = true;
  bool _useNetworkTime = false;
  String _ntpServer = 'pool.ntp.org';
  bool _showOnHome = false;

  final List<String> _languages = ['system', 'zh', 'en', 'ja'];
  final StorageService _storageService = StorageService();

  Map<String, String> _getLanguageMap(BuildContext context) {
    return {
      'system': AppLocalizations.of(context).followSystem,
      'zh': AppLocalizations.of(context).chinese,
      'en': AppLocalizations.of(context).english,
      'ja': AppLocalizations.of(context).japanese,
    };
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await widget.settingsService.getSettings();
    setState(() {
      _language = settings.language;
      _requireBiometrics = settings.requireBiometrics;
      _isLoading = false;
      _preventScreenshot = settings.preventScreenshot;
      _useNetworkTime = settings.useNetworkTime;
      _ntpServer = settings.ntpServer;
      _showOnHome = settings.showOnHome;
    });
  }

  Future<void> _saveSettings() async {
    try {
      final currentSettings = await widget.settingsService.getSettings();
      final newSettings = currentSettings.copyWith(
        language: _language,
        requireBiometrics: _requireBiometrics,
        preventScreenshot: _preventScreenshot,
        useNetworkTime: _useNetworkTime,
        ntpServer: _ntpServer,
        showOnHome: _showOnHome,
      );
      await widget.settingsService.saveSettings(newSettings);

      widget.onSettingsChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).saveSettingsError),
          ),
        );
      }
    }
  }

  void _showNtpServerDialog() {
    final controller = TextEditingController(text: _ntpServer);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).customNtpServer),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'pool.ntp.org',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              setState(() => _ntpServer = controller.text.trim());
              _saveSettings();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context).save),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).languageSettings),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _languages.map((lang) {
                return RadioListTile<String>(
                  title: Text(_getLanguageMap(context)[lang]!),
                  value: lang,
                  groupValue: _language,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _language = value;
                      });
                      _saveSettings();
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _backupAccounts() async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await _ensureStoragePermission()) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(t.permissionRequired)));
      }
      return;
    }

    final password = await _promptPassword(t.backupPasswordPrompt);
    if (password == null || password.isEmpty) return;

    try {
      final accounts = await _storageService.getAccounts();
      final encrypted = await BackupService.encryptBackup(accounts, password);
      final filename =
          'neap_backup_${DateTime.now().millisecondsSinceEpoch}.bin';
      final filePath = await BackupService.exportBackupToFile(
        encrypted,
        filename,
      );

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(t.backupSavedMessage(filePath))),
        );
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(t.backupError)));
      }
    }
  }

  Future<void> _restoreAccounts() async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (!await _ensureStoragePermission()) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(t.permissionRequired)));
      }
      return;
    }

    final filePath = await _selectBackupFile();
    if (filePath == null) return;

    final password = await _promptPassword(t.restorePasswordPrompt);
    if (password == null || password.isEmpty) return;

    try {
      final backupText = await BackupService.importBackupFromFile(filePath);
      final accounts = await BackupService.decryptBackup(backupText, password);
      await _storageService.replaceAccounts(accounts);
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(t.restoreSuccess)));
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(t.passwordIncorrect)));
      }
    }
  }

  Future<String?> _selectBackupFile() async {
    final t = AppLocalizations.of(context);
    final files = await BackupService.listBackupFiles();
    if (!mounted) return null;
    if (files.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.noBackupFiles)));
      return null;
    }

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.selectBackupFile),
          content: SizedBox(
            width: double.maxFinite,
            height: 320,
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final name = file.uri.pathSegments.last;
                final modified = file.lastModifiedSync();
                return ListTile(
                  title: Text(name),
                  subtitle: Text(modified.toLocal().toString()),
                  onTap: () => Navigator.pop(context, file.path),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(t.cancel),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _ensureStoragePermission() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 30) {
      final manageStatus = await Permission.manageExternalStorage.status;
      if (manageStatus.isGranted) return true;

      if (await _requestPermission(Permission.manageExternalStorage)) {
        return true;
      }
    }

    return _requestPermission(Permission.storage);
  }

  Future<bool> _requestPermission(Permission permission) async {
    final currentContext = context;
    final t = AppLocalizations.of(currentContext);
    final status = await permission.status;
    if (status.isGranted || status.isLimited) return true;

    final shouldRequest = await showDialog<bool>(
      context: currentContext,
      builder: (context) {
        return AlertDialog(
          title: Text(t.permissionRequired),
          content: Text(t.permissionRequired),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.allow),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldRequest != true) return false;

    final result = await permission.request();
    if (!mounted) return false;
    if (result.isGranted || result.isLimited) return true;

    if (result.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.permissionRequired),
            action: SnackBarAction(
              label: t.settings,
              onPressed: openAppSettings,
            ),
          ),
        );
      }
    }

    return false;
  }

  Future<String?> _promptPassword(String title) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).password,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(AppLocalizations.of(context).confirm),
            ),
          ],
        );
      },
    );

    return result?.trim();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).globalSettings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(AppLocalizations.of(context).languageSettings),
              subtitle: Text(_getLanguageMap(context)[_language] ?? 'unknown'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showLanguageDialog,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: Text(AppLocalizations.of(context).enableBiometric),
              subtitle: Text(AppLocalizations.of(context).biometricDescription),
              value: _requireBiometrics,
              onChanged: (value) {
                setState(() {
                  _requireBiometrics = value;
                });
                _saveSettings();
              },
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: Text(AppLocalizations.of(context).preventScreenshot),
              subtitle: Text(
                AppLocalizations.of(context).preventScreenshotDescription,
              ),
              value: _preventScreenshot,
              onChanged: (value) {
                setState(() => _preventScreenshot = value);
                _saveSettings();
              },
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: Text(AppLocalizations.of(context).showOnHome),
              subtitle: Text(
                AppLocalizations.of(context).showOnHomeDescription,
              ),
              value: _showOnHome,
              onChanged: (value) {
                setState(() => _showOnHome = value);
                _saveSettings();
              },
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(AppLocalizations.of(context).backupAccounts),
              subtitle: Text(
                AppLocalizations.of(context).backupAccountsDescription,
              ),
              trailing: const Icon(Icons.backup),
              onTap: _backupAccounts,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(AppLocalizations.of(context).restoreAccounts),
              subtitle: Text(
                AppLocalizations.of(context).restoreAccountsDescription,
              ),
              trailing: const Icon(Icons.restore),
              onTap: _restoreAccounts,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_useNetworkTime)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(AppLocalizations.of(context).customNtpServer),
                  subtitle: Text(_ntpServer),
                  trailing: const Icon(Icons.edit),
                  onTap: _showNtpServerDialog,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
