import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:neap/main.dart';
import 'package:neap/services/time_service.dart';

import '../l10n/app_localizations.dart';
import '../models/account_model.dart';

class AccountDetailPage extends StatefulWidget {
  final TotpAccount account;
  final VoidCallback onDelete;
  final Function(
    String newLabel,
    String newIssuer,
    String newAvatarType, [
    String? avatarImagePath,
  ])?
  onUpdate;

  const AccountDetailPage({
    super.key,
    required this.account,
    required this.onDelete,
    this.onUpdate,
  });

  @override
  State<AccountDetailPage> createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage>
    with TickerProviderStateMixin {
  late TotpAccount _account;
  Timer? _timer;
  String _currentCode = '';
  int _remainingSeconds = 0;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _account = widget.account;

    _progressController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _updateCode();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateCode();
      }
    });
  }

  Future<void> _updateCode() async {
    final timeService = TimeService();
    final nowDateTime = await timeService.getCurrentTime();
    final now = nowDateTime.millisecondsSinceEpoch ~/ 1000;
    final remaining = _account.interval - (now % _account.interval);
    final code = _account.generateCode(time: nowDateTime);

    if (!mounted) return;
    setState(() {
      _currentCode = code;
      _remainingSeconds = remaining;
    });

    final progress = remaining / _account.interval;
    _progressController.animateTo(
      progress,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _copyCode() {
    final t = AppLocalizations.of(context);
    Clipboard.setData(ClipboardData(text: _currentCode));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.copiedToClipboard)));
  }

  void _showEditMenu() {
    final t = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(t.edit),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(t.delete, style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog() {
    final t = AppLocalizations.of(context);
    final labelController = TextEditingController(text: _account.label);
    final issuerController = TextEditingController(text: _account.issuer);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.editAccountInfo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: InputDecoration(
                labelText: t.label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: issuerController,
              decoration: InputDecoration(
                labelText: t.issuerOptional,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () {
              final newLabel = labelController.text.trim();
              final newIssuer = issuerController.text.trim();
              if (newLabel.isNotEmpty && widget.onUpdate != null) {
                setState(() {
                  _account = TotpAccount(
                    id: _account.id,
                    label: newLabel,
                    issuer: newIssuer,
                    secret: _account.secret,
                    interval: _account.interval,
                    digits: _account.digits,
                    avatarType: _account.avatarType,
                  );
                });
                widget.onUpdate!(
                  _account.label,
                  _account.issuer,
                  _account.avatarType,
                  _account.avatarImagePath,
                );
              }
              Navigator.pop(context);
            },
            child: Text(t.save),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker() {
    final t = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.selectAvatar,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 16,
                  children: [
                    _buildAvatarOption(
                      'default',
                      Icons.account_circle,
                      t.defaultAvatar,
                    ),
                    _buildAvatarOption('code', Icons.code, t.code),
                    _buildAvatarOption('shop', Icons.shopping_cart, t.shop),
                    _buildAvatarOption('google', Icons.g_mobiledata, t.google),
                    _buildAvatarOption('microsoft', Icons.window, t.microsoft),
                    _buildAvatarOption('apple', Icons.apple, t.apple),
                    _buildGalleryOption(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarOption(String type, IconData icon, String label) {
    final isSelected = _account.avatarType == type;
    return SizedBox(
      width: 72,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _account = TotpAccount(
              id: _account.id,
              label: _account.label,
              issuer: _account.issuer,
              secret: _account.secret,
              interval: _account.interval,
              digits: _account.digits,
              avatarType: type,
            );
          });

          if (widget.onUpdate != null) {
            widget.onUpdate!(_account.label, _account.issuer, type, null);
          }
          Navigator.pop(context);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                  : Colors.grey.shade200,
              child: Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(
                fontSize: 12,
                height: 1.1,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryOption() {
    final t = AppLocalizations.of(context);
    return SizedBox(
      width: 72,
      child: GestureDetector(
        onTap: _pickImageFromGallery,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade200,
              child: Icon(Icons.photo_library, color: Colors.grey[700]),
            ),
            const SizedBox(height: 6),
            Text(
              t.fromGallery,
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(
                fontSize: 12,
                height: 1.1,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final t = AppLocalizations.of(context);
    Theme.of(context);
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        MyAppState.shouldSkipAuthentication = true;
        setState(() {
          _account = TotpAccount(
            id: _account.id,
            label: _account.label,
            issuer: _account.issuer,
            secret: _account.secret,
            interval: _account.interval,
            digits: _account.digits,
            avatarType: 'custom_image',
            avatarImagePath: image.path,
          );
        });

        if (widget.onUpdate != null) {
          widget.onUpdate!(
            _account.label,
            _account.issuer,
            'custom_image',
            image.path,
          );
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${t.pickImageFailed}: $e')));
        debugPrint('Error picking image: $e');
      }
      if (mounted) Navigator.pop(context);
    }
  }

  void _showDeleteDialog() {
    final t = AppLocalizations.of(context);
    bool confirmed = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          title: Text(t.confirmDelete),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.confirmDeleteMessage(_account.label)),
              const SizedBox(height: 16),
              Text(
                confirmed
                    ? t.finalConfirmDeleteMessage(_account.label)
                    : t.initialConfirmDeleteMessage(_account.label),
                style: TextStyle(color: Colors.red[600], fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.cancel),
            ),
            TextButton(
              onPressed: () {
                if (!confirmed) {
                  dialogSetState(() {
                    confirmed = true;
                  });
                } else {
                  Navigator.pop(context);
                  widget.onDelete();
                  Navigator.pop(context);
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(confirmed ? t.confirmDeleteButton : t.delete),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.accountDetail)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: 128,
                    height: 128,
                    child: _account.getAvatarWidget(
                      size: 128,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      iconColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _showAvatarPicker,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _account.label,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (_account.issuer.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _account.issuer,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentCode,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: _copyCode,
                        tooltip: t.copyCodeTooltip,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              value: _progressAnimation.value,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                '$_remainingSeconds',
                                key: ValueKey<int>(_remainingSeconds),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              t.secondsToUpdate,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showEditMenu,
        child: const Icon(Icons.edit),
      ),
    );
  }
}
