import 'package:flutter/material.dart';
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
  bool _preventScreenshot = false;
  bool _useNetworkTime = false;
  String _ntpServer = 'pool.ntp.org';
  bool _showOnHome = false;

  final List<String> _languages = ['system', 'zh', 'en', 'ja'];

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
            child: SwitchListTile(
              title: Text(AppLocalizations.of(context).useNetworkTime),
              subtitle: Text(
                AppLocalizations.of(context).networkTimeDescription,
              ),
              value: _useNetworkTime,
              onChanged: (value) {
                setState(() => _useNetworkTime = value);
                _saveSettings();
              },
              contentPadding: const EdgeInsets.all(16),
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
