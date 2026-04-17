import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/account_model.dart';
import '../models/settings_model.dart';
import '../services/storage_service.dart';
import '../services/setting_service.dart';
import 'add.dart';
import 'detail.dart';
import 'settings/splash.dart';

class AnimatedCountdownCircle extends StatefulWidget {
  final double value;
  final Color color;
  final double size;
  final double strokeWidth;

  const AnimatedCountdownCircle({
    super.key,
    required this.value,
    required this.color,
    this.size = 32,
    this.strokeWidth = 2.5,
  });

  @override
  State<AnimatedCountdownCircle> createState() =>
      _AnimatedCountdownCircleState();
}

class _AnimatedCountdownCircleState extends State<AnimatedCountdownCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double? _previousValue;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _previousValue = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedCountdownCircle oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 检测倒计时重置（value 从接近 0 突然变为接近 1）
    if (_previousValue != null) {
      final isReset = _previousValue! < 0.1 && widget.value > 0.9;

      if (isReset) {
        // 重置时直接跳转到新值，不使用动画
        _controller.value = widget.value;
      } else {
        // 平滑过渡到新值
        _controller.animateTo(widget.value);
      }
    }

    _previousValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            value: _controller.value,
            strokeWidth: widget.strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(widget.color),
            backgroundColor: Colors.grey[200],
          ),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StorageService _storage = StorageService();
  final SettingsService _settingsService = SettingsService();
  List<TotpAccount> _accounts = [];
  bool _isLoading = true;
  AppSettings _settings = AppSettings.defaults;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadAccounts() async {
    final accounts = await _storage.getAccounts();
    final settings = await _settingsService.getSettings();
    setState(() {
      _accounts = accounts;
      _settings = settings;
      _isLoading = false;
    });
  }

  void _addAccount(TotpAccount account) async {
    await _storage.saveAccount(account);
    _loadAccounts();
  }

  void _updateAccount(
    TotpAccount oldAccount,
    String newLabel,
    String newIssuer,
    String newAvatarType, [
    String? avatarImagePath,
  ]) async {
    final updatedAccount = TotpAccount(
      id: oldAccount.id,
      label: newLabel,
      issuer: newIssuer,
      secret: oldAccount.secret,
      interval: oldAccount.interval,
      digits: oldAccount.digits,
      avatarType: newAvatarType,
      avatarImagePath: avatarImagePath,
    );
    await _storage.updateAccount(updatedAccount);
    _loadAccounts();
  }

  void _deleteAccount(String id) async {
    await _storage.deleteAccount(id);
    _loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsMainPage()),
              ).then((_) => _loadAccounts());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _accounts.length,
              itemBuilder: (context, index) {
                final account = _accounts[index];
                return _buildAccountTile(account);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<TotpAccount>(
            context,
            MaterialPageRoute(builder: (_) => const AddAccountPage()),
          );
          if (result != null) _addAccount(result);
        },
        tooltip: t.add,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    final t = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            t.emptyAccountsTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            t.emptyAccountsHint,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTile(TotpAccount account) {
    final code = account.generateCode();
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final remaining = account.interval - (now % account.interval);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: SizedBox(
          width: 48,
          height: 48,
          child: account.getAvatarWidget(
            size: 48,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.1),
            iconColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          account.label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(account.issuer),
            if (_settings.showOnHome) ...[
              const SizedBox(height: 4),
              Text(
                code,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
        trailing: _settings.showOnHome
            ? AnimatedCountdownCircle(
                value: remaining / account.interval,
                color: remaining <= 5
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
                size: 32,
                strokeWidth: 2.5,
              )
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AccountDetailPage(
                account: account,
                onDelete: () => _deleteAccount(account.id),
                onUpdate:
                    (newLabel, newIssuer, newAvatarType, [avatarImagePath]) =>
                        _updateAccount(
                          account,
                          newLabel,
                          newIssuer,
                          newAvatarType,
                          avatarImagePath,
                        ),
              ),
            ),
          );
        },
      ),
    );
  }
}
