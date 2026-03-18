import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/account_model.dart';

class AddAccountPage extends StatefulWidget {
  const AddAccountPage({super.key});

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _issuerController = TextEditingController();
  final _secretController = TextEditingController();
  final _periodController = TextEditingController(text: '30');
  bool _showScanner = false;

  int _selectedDigits = 6;
  int _selectedPeriod = 30;
  String _selectedAlgorithm = 'SHA1';

  @override
  void dispose() {
    _labelController.dispose();
    _issuerController.dispose();
    _secretController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _showScannerPage() {
    setState(() => _showScanner = true);
  }

  void _closeScannerPage() {
    setState(() => _showScanner = false);
  }

  Future<void> _showUriInputDialog() async {
    final uriController = TextEditingController();

    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('输入 URI'),
          content: TextFormField(
            controller: uriController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1.0,
                ),
              ),
            ),
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (uriController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _handleQrCode(uriController.text.trim(), showConfirm: true);
                }
              },
              style: ElevatedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _handleQrCode(String code, {bool showConfirm = false}) {
    try {
      final uri = Uri.parse(code);
      if (uri.scheme == 'otpauth' && uri.host == 'totp') {
        final pathSegments = uri.path.split('/');
        String pathLabel = pathSegments.isNotEmpty ? pathSegments.last : '';
        pathLabel = Uri.decodeComponent(pathLabel);

        String label = pathLabel;
        String issuerFromPath = '';
        if (pathLabel.contains(':')) {
          final parts = pathLabel.split(':');
          issuerFromPath = parts[0];
          label = parts[1];
        }

        final secret = uri.queryParameters['secret'] ?? '';
        final issuer = uri.queryParameters['issuer'] ?? issuerFromPath;
        final algorithm = uri.queryParameters['algorithm'] ?? 'SHA1';
        final digitsStr = uri.queryParameters['digits'] ?? '6';
        final periodStr = uri.queryParameters['period'] ?? '30';

        if (secret.isNotEmpty) {
          final digits = int.tryParse(digitsStr) ?? 6;
          final period = int.tryParse(periodStr) ?? 30;

          _applyParsedData(
            secret: secret,
            label: label,
            issuer: issuer,
            digits: digits,
            period: period,
            algorithm: algorithm,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('无效的二维码：$e')));
    }
  }

  void _applyParsedData({
    required String secret,
    required String label,
    required String issuer,
    required int digits,
    required int period,
    required String algorithm,
  }) {
    int validatedDigits = digits;
    if (![4, 5, 6, 7, 8, 9, 10].contains(digits)) {
      validatedDigits = 6;
    }

    int validatedPeriod = period;
    if (period < 1 || period > 120) {
      validatedPeriod = 30;
    }

    String validatedAlgorithm = algorithm;
    if (!['SHA1', 'SHA256', 'SHA512'].contains(algorithm)) {
      validatedAlgorithm = 'SHA1';
    }

    setState(() {
      _secretController.text = secret;
      _labelController.text = label;
      _issuerController.text = issuer;
      _periodController.text = validatedPeriod.toString();
      _showScanner = false;
      _selectedDigits = validatedDigits;
      _selectedPeriod = validatedPeriod;
      _selectedAlgorithm = validatedAlgorithm;
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final account = TotpAccount(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: _labelController.text.trim(),
        issuer: _issuerController.text.trim(),
        secret: _secretController.text.trim(),
        digits: _selectedDigits,
        interval: _selectedPeriod,
        algorithm: _selectedAlgorithm,
      );
      Navigator.pop(context, account);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showScanner) {
      return _buildScannerPage();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('添加账户')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ElevatedButton.icon(
                onPressed: _showScannerPage,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('扫描二维码'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _showUriInputDialog,
                icon: const Icon(Icons.edit),
                label: const Text('手动输入 URI'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                '或手动输入',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: '标签',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.0,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.label_outline),
                ),
                validator: (v) => v?.trim().isEmpty == true ? '请输入标签' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _issuerController,
                decoration: InputDecoration(
                  labelText: '发行者（非必填）',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.0,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _secretController,
                decoration: InputDecoration(
                  labelText: '密钥',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.0,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.vpn_key),
                ),
                validator: (v) {
                  if (v?.trim().isEmpty == true) return '请输入密钥';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                '高级选项',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedAlgorithm,
                decoration: InputDecoration(
                  labelText: '加密算法',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.0,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.security),
                ),
                items: const [
                  DropdownMenuItem(value: 'SHA1', child: Text('SHA1')),
                  DropdownMenuItem(value: 'SHA256', child: Text('SHA256')),
                  DropdownMenuItem(value: 'SHA512', child: Text('SHA512')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedAlgorithm = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _selectedDigits,
                decoration: InputDecoration(
                  labelText: '验证码位数',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.0,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.format_list_numbered),
                ),
                items: const [6, 7, 8]
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text('$value 位'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedDigits = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _periodController,
                decoration: InputDecoration(
                  labelText: '周期',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.0,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.schedule),
                  suffixText: '秒',
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v?.trim().isEmpty == true) return '请输入周期';
                  final period = int.tryParse(v?.trim() ?? '') ?? 0;
                  if (period < 1 || period > 120) {
                    return '刷新周期必须在1-120秒之间';
                  }
                  return null;
                },
                onChanged: (value) {
                  final period = int.tryParse(value.trim()) ?? 30;
                  if (period >= 1 && period <= 120) {
                    setState(() => _selectedPeriod = period);
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫描二维码'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _closeScannerPage,
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  _handleQrCode(code);
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '将二维码放在框内',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
