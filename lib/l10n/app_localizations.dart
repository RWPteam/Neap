import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'app_title': 'Neap Authenticator',
      'add_account': 'Add Account',
      'scan_qr_code': 'Scan QR Code',
      'manual_input_uri': 'Manual Input URI',
      'or_manual_input': 'Or Manual Input',
      'manual_input_hint':
          'e.g. otpauth://totp/Example:Account?secret=ABC123&issuer=Example',
      'enter_uri': 'Enter URI',
      'label': 'Label',
      'issuer': 'Issuer (Optional)',
      'secret': 'Secret (Base32, Base64, Hex, String)',
      'advanced_options': 'Advanced Options',
      'encryption_algorithm': 'Encryption Algorithm',
      'code_digits': 'Code Digits',
      'refresh_period': 'Refresh Period',
      'save': 'Save',
      'settings': 'Settings',
      'global_settings': 'Global Settings',
      'theme_settings': 'Theme Settings',
      'language_settings': 'Language Settings',
      'follow_system': 'Follow System',
      'chinese': 'Chinese',
      'english': 'English',
      'japanese': 'Japanese',
      'enable_biometric': 'Enable Biometric Authentication',
      'biometric_description':
          'Require biometric authentication when starting the app',
      'about': 'About',
      'theme_style': 'Theme Style',
      'light': 'Light',
      'dark': 'Dark',
      'copied_to_clipboard': 'Code copied to clipboard',
      'delete': 'Delete',
      'confirm_delete': 'Confirm Delete',
      'confirm_delete_message':
          'Are you sure you want to delete "{label}"? This cannot be undone.',
      'photo_permission_required':
          'Photo permission is required to select images. Please enable permissions in settings.',
      'barcode_permission_required':
          'Photo permission is required to select images',
      'invalid_qr_code': 'Invalid QR Code',
      'settings_saved': 'Settings Saved',
      'save_failed': 'Save Failed',
      'please_enter_label': 'Please enter label',
      'please_enter_secret': 'Please enter secret',
      'please_enter_period': 'Please enter refresh period',
      'period_range_error': 'Refresh period must be between 1-120 seconds',
      'confirm_account_info': 'Confirm Account Information',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'seconds': 'seconds',
      'place_qr_code_in_frame': 'Place QR code inside frame',
      'biometric_reason': 'Please authenticate with biometrics to unlock Neap',
      'digits_unit': 'digits',
      'use_material_you': 'Use Material You',
      'page_theme': 'Page Theme',
      'permission_gallery_denied': 'Gallery permission denied',
      'pick_image_failed': 'Failed to pick image',
      'from_gallery': 'From Gallery',
      'edit': 'Edit',
      'edit_account_info': 'Edit Account Info',
      'issuer_optional': 'Issuer (Optional)',
      'select_avatar': 'Select Avatar',
      'default_avatar': 'Default',
      'code': 'Code',
      'microsoft': 'Microsoft',
      'shop': 'Shop',
      'apple': 'Apple',
      'google': 'Google',
      'permission_required': 'Permission Required',
      'permission_gallery_description':
          'Neap needs access to your gallery to select an avatar image.',
      'allow': 'Allow',
      'permission_gallery_denied_permanently':
          'Gallery permission permanently denied. Please enable it in settings.',
      'crop_image': 'Crop Image',
      'confirm_delete_button': 'Delete',
      'account_detail': 'Account Detail',
      'copy_code_tooltip': 'Copy code',
      'seconds_to_update': ' seconds to update',
      'add': 'Add',
      'empty_accounts_title': 'No accounts yet',
      'empty_accounts_hint': 'Tap the + button to add your first account',
      'ok': 'OK',
      'initial_confirm_delete_message': 'Tap "Delete" again to confirm.',
      'final_confirm_delete_message':
          'This is your last chance. Tap "Delete" again to confirm',
      'global_settings_subtitle': 'Language, Biometric and Privacy',
      'theme_settings_subtitle': 'Theme and color',
      'about_subtitle': 'Version and license',
      'save_settings_error': 'Failed to save settings',
      'app_locked': 'App Locked',
      'unlock': 'Unlock',
      'easter_egg_title': 'samuiord',
      'type_message': 'Type a message...',
      'send': 'Send',
      'secret_message_received': 'Now...?',
      'prevent_screenshot': 'Prevent Screenshot',
      'prevent_screenshot_description':
          'Prevent screenshots when you are using the app',
      'custom_ntp_server': 'Custom NTP Server',
      'network_time_description':
          'Use network time to generate codes when enabled',
      'use_network_time': 'Use Network Time',
      'show_on_home': 'Show Codes on Home',
      'show_on_home_description':
          'Display verification codes directly in the home account list',
      'password': 'Password',
    },
    'zh': {
      'app_title': 'Neap Authenticator',
      'add_account': '添加账户',
      'scan_qr_code': '扫描二维码',
      'manual_input_uri': '手动输入 URI',
      'or_manual_input': '或手动输入',
      'manual_input_hint': '手动输入',
      'enter_uri': '输入 URI',
      'label': '标签',
      'issuer': '发行者（非必填）',
      'secret': '密钥（支持 Base32、Base64、Hex、String）',
      'advanced_options': '高级选项',
      'encryption_algorithm': '加密算法',
      'code_digits': '验证码位数',
      'refresh_period': '刷新周期',
      'save': '保存',
      'settings': '设置',
      'global_settings': '全局设置',
      'theme_settings': '主题设置',
      'language_settings': '语言设置',
      'follow_system': '跟随系统',
      'chinese': '中文',
      'english': '英文',
      'japanese': '日文',
      'enable_biometric': '启用生物识别验证',
      'biometric_description': '启动应用时需要生物识别验证',
      'about': '关于',
      'theme_style': '主题风格',
      'light': '浅色',
      'dark': '深色',
      'copied_to_clipboard': '验证码已复制到剪贴板',
      'delete': '删除',
      'confirm_delete': '确认删除',
      'confirm_delete_message': '确定要删除 "{label}" 吗？该操作不可撤销',
      'photo_permission_required': '需要相册权限才能选择图片。请在设置中启用权限。',
      'barcode_permission_required': '需要相册权限才能选择图片',
      'invalid_qr_code': '无效的二维码',
      'settings_saved': '设置已保存',
      'save_failed': '保存失败',
      'please_enter_label': '请输入标签',
      'please_enter_secret': '请输入密钥',
      'please_enter_period': '请输入刷新周期',
      'period_range_error': '刷新周期必须在1-120秒之间',
      'confirm_account_info': '确认账户信息',
      'confirm': '确定',
      'cancel': '取消',
      'seconds': '秒',
      'place_qr_code_in_frame': '将二维码放在框内',
      'biometric_reason': '请验证指纹以解锁 Neap',
      'digits_unit': '位',
      'use_material_you': '使用 Material You',
      'page_theme': '页面主题',
      'permission_gallery_denied': '相册权限被拒绝',
      'pick_image_failed': '选择图片失败',
      'from_gallery': '从相册',
      'edit': '编辑',
      'edit_account_info': '编辑账户信息',
      'issuer_optional': '发行者（非必填）',
      'select_avatar': '选择头像',
      'default_avatar': '默认',
      'code': '代码',
      'microsoft': '微软',
      'shop': '购物',
      'apple': '苹果',
      'google': '谷歌',
      'permission_required': '需要权限',
      'permission_gallery_description': 'Neap 需要访问相册以选择头像图片。',
      'allow': '允许',
      'permission_gallery_denied_permanently': '相册权限被永久拒绝。请在设置中启用。',
      'crop_image': '裁剪图片',
      'confirm_delete_button': '删除',
      'account_detail': '账户详情',
      'copy_code_tooltip': '复制验证码',
      'seconds_to_update': ' 秒后更新',
      'add': '添加',
      'empty_accounts_title': '暂无账户',
      'empty_accounts_hint': '点击 + 按钮添加第一个账户',
      'ok': '确定',
      'initial_confirm_delete_message': '若信息无误，再次点击“删除”按钮。',
      'final_confirm_delete_message': '这是最后一次机会，请再次点击“删除”',
      'global_settings_subtitle': '语言、生物识别和隐私设置',
      'theme_settings_subtitle': '主题和颜色',
      'about_subtitle': '版本和许可',
      'save_settings_error': '保存设置失败',
      'app_locked': '应用已锁定',
      'unlock': '解锁',
      'easter_egg_title': 'samuiord',
      'type_message': '输入消息...',
      'send': '发送',
      'secret_message_received': '现在吗...还有点早',
      'prevent_screenshot': '禁止截图',
      'prevent_screenshot_description': '开启后，您将无法在应用内截图',
      'custom_ntp_server': '自定义 NTP 服务器',
      'network_time_description': '开启后将优先使用网络时间生成验证码',
      'use_network_time': '使用网络时间',
      'show_on_home': '主页显示验证码',
      'show_on_home_description': '在主页账户列表中直接显示验证码',
      'password': '密码',
    },
    'ja': {
      'app_title': 'Neap Authenticator',
      'add_account': 'アカウントを追加',
      'scan_qr_code': 'QRコードをスキャン',
      'manual_input_uri': 'URIを手動入力',
      'or_manual_input': 'または手動入力',
      'manual_input_hint': '手動入力',
      'enter_uri': 'URIを入力',
      'label': 'ラベル',
      'issuer': '発行者（オプション）',
      'secret': 'シークレット（Base32、Base64、Hex、文字列）',
      'advanced_options': '詳細設定',
      'encryption_algorithm': '暗号化アルゴリズム',
      'code_digits': 'コード桁数',
      'refresh_period': '更新間隔',
      'save': '保存',
      'settings': '設定',
      'global_settings': 'グローバル設定',
      'theme_settings': 'テーマ設定',
      'language_settings': '言語設定',
      'follow_system': 'システムに従う',
      'chinese': '中国語',
      'english': '英語',
      'enable_biometric': '生体認証を有効にする',
      'biometric_description': 'アプリ起動時に生体認証を要求する',
      'about': '情報',
      'theme_style': 'テーマスタイル',
      'light': 'ライト',
      'dark': 'ダーク',
      'copied_to_clipboard': 'コードをクリップボードにコピーしました',
      'delete': '削除',
      'confirm_delete': '削除の確認',
      'confirm_delete_message': '"{label}" を削除してもよろしいですか？この操作は取り消せません。',
      'photo_permission_required': '画像を選択するには写真の許可が必要です。設定で権限を有効にしてください。',
      'barcode_permission_required': '画像を選択するには写真の許可が必要です',
      'invalid_qr_code': '無効なQRコード',
      'settings_saved': '設定を保存しました',
      'save_failed': '保存に失敗しました',
      'please_enter_label': 'ラベルを入力してください',
      'please_enter_secret': 'シークレットを入力してください',
      'please_enter_period': '更新間隔を入力してください',
      'period_range_error': '更新間隔は1〜120秒の間で設定してください',
      'confirm_account_info': 'アカウント情報の確認',
      'confirm': '確認',
      'cancel': 'キャンセル',
      'seconds': '秒',
      'place_qr_code_in_frame': 'QRコードを枠内に合わせてください',
      'biometric_reason': 'Neapを解除するために生体認証が必要',
      'digits_unit': '桁',
      'use_material_you': 'Material Youを使用',
      'page_theme': 'ページテーマ',
      'permission_gallery_denied': 'ギャラリーの許可が拒否されました',
      'pick_image_failed': '画像の選択に失敗しました',
      'from_gallery': 'ギャラリーから',
      'edit': '編集',
      'edit_account_info': 'アカウント情報を編集',
      'issuer_optional': '発行者（オプション）',
      'select_avatar': 'アバターを選択',
      'default_avatar': 'デフォルト',
      'code': 'コード',
      'microsoft': 'マイクロソフト',
      'shop': 'ショップ',
      'apple': 'アップル',
      'google': 'グーグル',
      'permission_required': '権限が必要',
      'permission_gallery_description': 'アバター画像を選択するためにギャラリーへのアクセスが必要です。',
      'allow': '許可',
      'permission_gallery_denied_permanently':
          'ギャラリーの権限が永久に拒否されました。設定で有効にしてください。',
      'crop_image': '画像を切り抜き',
      'confirm_delete_button': '削除',
      'account_detail': 'アカウント詳細',
      'copy_code_tooltip': 'コードをコピー',
      'seconds_to_update': ' 秒後に更新',
      'add': '追加',
      'empty_accounts_title': 'アカウントがありません',
      'empty_accounts_hint': '「＋」をタップしてアカウント追加',
      'ok': 'OK',
      'initial_confirm_delete_message': 'もう一度「削除」をタップして確定してください。',
      'final_confirm_delete_message':
          'これが最後の確認です。「削除」をタップすると "{label}" が完全に削除されます。',
      'global_settings_subtitle': '言語，生体認証，プライバシー',
      'theme_settings_subtitle': 'テーマと色',
      'about_subtitle': 'バージョンとライセンス',
      'save_settings_error': '設定の保存に失敗しました',
      'japanese': '日本語',
      'app_locked': 'アプリがロックされました',
      'unlock': 'ロック解除',
      'easter_egg_title': 'samuiord',
      'type_message': 'メッセージを入力...',
      'send': '送信',
      'secret_message_received': 'まだその時じゃない...',
      'prevent_screenshot': 'スクリーンショットを防止',
      'prevent_screenshot_description': 'スクリーンショットを防止します',
      'custom_ntp_server': 'NTP サーバーをカスタマイズ',
      'network_time_description': '有効にすると、ネットワーク時間を優先してコードを生成します',
      'use_network_time': 'ネットワーク時間を使用',
      'show_on_home': 'ホームにコードを表示',
      'show_on_home_description': 'ホームのアカウントリストに直接確認コードを表示します',
      'password': 'パスワード',
    },
  };

  String get appTitle =>
      _localizedValues[locale.languageCode]?['app_title'] ??
      'Neap Authenticator';
  String get addAccount =>
      _localizedValues[locale.languageCode]?['add_account'] ?? 'Add Account';
  String get scanQrCode =>
      _localizedValues[locale.languageCode]?['scan_qr_code'] ?? 'Scan QR Code';
  String get manualInputUri =>
      _localizedValues[locale.languageCode]?['manual_input_uri'] ??
      'Manual Input URI';
  String get orManualInput =>
      _localizedValues[locale.languageCode]?['or_manual_input'] ??
      'Or Manual Input';
  String get label =>
      _localizedValues[locale.languageCode]?['label'] ?? 'Label';
  String get issuer =>
      _localizedValues[locale.languageCode]?['issuer'] ?? 'Issuer (Optional)';
  String get secret =>
      _localizedValues[locale.languageCode]?['secret'] ?? 'Secret';
  String get advancedOptions =>
      _localizedValues[locale.languageCode]?['advanced_options'] ??
      'Advanced Options';
  String get encryptionAlgorithm =>
      _localizedValues[locale.languageCode]?['encryption_algorithm'] ??
      'Encryption Algorithm';
  String get codeDigits =>
      _localizedValues[locale.languageCode]?['code_digits'] ?? 'Code Digits';
  String get refreshPeriod =>
      _localizedValues[locale.languageCode]?['refresh_period'] ??
      'Refresh Period';
  String get save => _localizedValues[locale.languageCode]?['save'] ?? 'Save';
  String get settings =>
      _localizedValues[locale.languageCode]?['settings'] ?? 'Settings';
  String get globalSettings =>
      _localizedValues[locale.languageCode]?['global_settings'] ??
      'Global Settings';
  String get themeSettings =>
      _localizedValues[locale.languageCode]?['theme_settings'] ??
      'Theme Settings';
  String get languageSettings =>
      _localizedValues[locale.languageCode]?['language_settings'] ??
      'Language Settings';
  String get followSystem =>
      _localizedValues[locale.languageCode]?['follow_system'] ??
      'Follow System';
  String get chinese =>
      _localizedValues[locale.languageCode]?['chinese'] ?? 'Chinese';
  String get english =>
      _localizedValues[locale.languageCode]?['english'] ?? 'English';
  String get enableBiometric =>
      _localizedValues[locale.languageCode]?['enable_biometric'] ??
      'Enable Biometric Authentication';
  String get biometricDescription =>
      _localizedValues[locale.languageCode]?['biometric_description'] ??
      'Require biometric authentication when starting the app';
  String get biometricReason =>
      _localizedValues[locale.languageCode]?['biometric_reason'] ??
      'Please authenticate with biometrics to unlock Neap';
  String get about =>
      _localizedValues[locale.languageCode]?['about'] ?? 'About';
  String get invalidQrCode =>
      _localizedValues[locale.languageCode]?['invalid_qr_code'] ??
      'Invalid QR Code';
  String get settingsSaved =>
      _localizedValues[locale.languageCode]?['settings_saved'] ??
      'Settings Saved';
  String get saveFailed =>
      _localizedValues[locale.languageCode]?['save_failed'] ?? 'Save Failed';
  String get pleaseEnterLabel =>
      _localizedValues[locale.languageCode]?['please_enter_label'] ??
      'Please enter label';
  String get pleaseEnterSecret =>
      _localizedValues[locale.languageCode]?['please_enter_secret'] ??
      'Please enter secret';
  String get pleaseEnterPeriod =>
      _localizedValues[locale.languageCode]?['please_enter_period'] ??
      'Please enter refresh period';
  String get periodRangeError =>
      _localizedValues[locale.languageCode]?['period_range_error'] ??
      'Refresh period must be between 1-120 seconds';
  String get confirmAccountInfo =>
      _localizedValues[locale.languageCode]?['confirm_account_info'] ??
      'Confirm Account Information';
  String get confirm =>
      _localizedValues[locale.languageCode]?['confirm'] ?? 'Confirm';
  String get cancel =>
      _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancel';
  String get seconds =>
      _localizedValues[locale.languageCode]?['seconds'] ?? 'seconds';
  String get placeQrCodeInFrame =>
      _localizedValues[locale.languageCode]?['place_qr_code_in_frame'] ??
      'Place QR code inside frame';
  String get themeStyle =>
      _localizedValues[locale.languageCode]?['theme_style'] ?? 'Theme Style';
  String get light =>
      _localizedValues[locale.languageCode]?['light'] ?? 'Light';
  String get dark => _localizedValues[locale.languageCode]?['dark'] ?? 'Dark';
  String get copiedToClipboard =>
      _localizedValues[locale.languageCode]?['copied_to_clipboard'] ??
      'Code copied to clipboard';
  String get delete =>
      _localizedValues[locale.languageCode]?['delete'] ?? 'Delete';
  String get confirmDelete =>
      _localizedValues[locale.languageCode]?['confirm_delete'] ??
      'Confirm Delete';
  String confirmDeleteMessage(String label) {
    final template =
        _localizedValues[locale.languageCode]?['confirm_delete_message'] ??
        'Are you sure you want to delete "{label}"? This cannot be undone.';
    return template.replaceAll('{label}', label);
  }

  String confirmDeletePrompt(String label) {
    final template =
        _localizedValues[locale.languageCode]?['confirm_delete_prompt'] ??
        'This is your last chance, delete "{label}"?';
    return template.replaceAll('{label}', label);
  }

  String get photoPermissionRequired =>
      _localizedValues[locale.languageCode]?['photo_permission_required'] ??
      'Photo permission is required to select images. Please enable permissions in settings.';
  String get barcodePermissionRequired =>
      _localizedValues[locale.languageCode]?['barcode_permission_required'] ??
      'Photo permission is required to select images';

  String get digitsUnit =>
      _localizedValues[locale.languageCode]?['digits_unit'] ?? 'digits';
  String get manualInputHint =>
      _localizedValues[locale.languageCode]?['manual_input_hint'] ??
      'input manually';
  String get enterUri =>
      _localizedValues[locale.languageCode]?['enter_uri'] ?? 'Enter URI';
  String get useMaterialYou =>
      _localizedValues[locale.languageCode]?['use_material_you'] ??
      'Use Material You';
  String get pageTheme =>
      _localizedValues[locale.languageCode]?['page_theme'] ?? 'Page Theme';
  String get permissionGalleryDenied =>
      _localizedValues[locale.languageCode]?['permission_gallery_denied'] ??
      'Gallery permission denied';
  String get pickImageFailed =>
      _localizedValues[locale.languageCode]?['pick_image_failed'] ??
      'Failed to pick image';
  String get fromGallery =>
      _localizedValues[locale.languageCode]?['from_gallery'] ?? 'From Gallery';
  String get edit => _localizedValues[locale.languageCode]?['edit'] ?? 'Edit';
  String get editAccountInfo =>
      _localizedValues[locale.languageCode]?['edit_account_info'] ??
      'Edit Account Info';
  String get issuerOptional =>
      _localizedValues[locale.languageCode]?['issuer_optional'] ??
      'Issuer (Optional)';
  String get selectAvatar =>
      _localizedValues[locale.languageCode]?['select_avatar'] ??
      'Select Avatar';
  String get defaultAvatar =>
      _localizedValues[locale.languageCode]?['default_avatar'] ?? 'Default';
  String get code => _localizedValues[locale.languageCode]?['code'] ?? 'Code';
  String get microsoft =>
      _localizedValues[locale.languageCode]?['microsoft'] ?? 'Microsoft';
  String get shop => _localizedValues[locale.languageCode]?['shop'] ?? 'Shop';
  String get apple =>
      _localizedValues[locale.languageCode]?['apple'] ?? 'Apple';
  String get google =>
      _localizedValues[locale.languageCode]?['google'] ?? 'Google';
  String get permissionRequired =>
      _localizedValues[locale.languageCode]?['permission_required'] ??
      'Permission Required';
  String get permissionGalleryDescription =>
      _localizedValues[locale
          .languageCode]?['permission_gallery_description'] ??
      'Neap needs access to your gallery to select an avatar image.';
  String get allow =>
      _localizedValues[locale.languageCode]?['allow'] ?? 'Allow';
  String get permissionGalleryDeniedPermanently =>
      _localizedValues[locale
          .languageCode]?['permission_gallery_denied_permanently'] ??
      'Gallery permission permanently denied. Please enable it in settings.';
  String get cropImage =>
      _localizedValues[locale.languageCode]?['crop_image'] ?? 'Crop Image';
  String get confirmDeleteButton =>
      _localizedValues[locale.languageCode]?['confirm_delete_button'] ??
      'Delete';
  String get accountDetail =>
      _localizedValues[locale.languageCode]?['account_detail'] ??
      'Account Detail';
  String get copyCodeTooltip =>
      _localizedValues[locale.languageCode]?['copy_code_tooltip'] ??
      'Copy code';
  String get secondsToUpdate =>
      _localizedValues[locale.languageCode]?['seconds_to_update'] ??
      ' seconds to update';
  String get add => _localizedValues[locale.languageCode]?['add'] ?? 'Add';
  String get emptyAccountsTitle =>
      _localizedValues[locale.languageCode]?['empty_accounts_title'] ??
      'No accounts yet';
  String get emptyAccountsHint =>
      _localizedValues[locale.languageCode]?['empty_accounts_hint'] ??
      'Tap the + button to add your first account';
  String get ok => _localizedValues[locale.languageCode]?['ok'] ?? 'OK';

  String get saveSettingsError =>
      _localizedValues[locale.languageCode]?['save_settings_error'] ??
      'Failed to save settings';

  String get globalSettingsSubtitle =>
      _localizedValues[locale.languageCode]?['global_settings_subtitle'] ??
      'Language, Biometric and Privacy';
  String get themeSettingsSubtitle =>
      _localizedValues[locale.languageCode]?['theme_settings_subtitle'] ??
      'Theme and color, Material You';
  String get aboutSubtitle =>
      _localizedValues[locale.languageCode]?['about_subtitle'] ??
      'Version and license';

  String get japanese =>
      _localizedValues[locale.languageCode]?['japanese'] ?? 'Japanese';

  String get appLocked =>
      _localizedValues[locale.languageCode]?['app_locked'] ?? 'App Locked';

  String get unlock =>
      _localizedValues[locale.languageCode]?['unlock'] ?? 'Unlock';

  String get easterEggTitle =>
      _localizedValues[locale.languageCode]?['easter_egg_title'] ?? 'samuiord';

  String get typeMessage =>
      _localizedValues[locale.languageCode]?['type_message'] ??
      'Type a message...';

  String get send => _localizedValues[locale.languageCode]?['send'] ?? 'Send';

  String get secretMessageReceived =>
      _localizedValues[locale.languageCode]?['secret_message_received'] ??
      'Now?';

  String get preventScreenshot =>
      _localizedValues[locale.languageCode]?['prevent_screenshot'] ??
      'Prevent Screenshot';

  String get preventScreenshotDescription =>
      _localizedValues[locale
          .languageCode]?['prevent_screenshot_description'] ??
      'Prevent screenshots when you are using the app';

  String get customNtpServer =>
      _localizedValues[locale.languageCode]?['custom_ntp_server'] ??
      'Custom NTP Server';

  String get networkTimeDescription =>
      _localizedValues[locale.languageCode]?['network_time_description'] ??
      'Use network time to generate codes';

  String get useNetworkTime =>
      _localizedValues[locale.languageCode]?['use_network_time'] ??
      'Use Network Time';

  String get showOnHome =>
      _localizedValues[locale.languageCode]?['show_on_home'] ??
      'Show Codes on Home';

  String get showOnHomeDescription =>
      _localizedValues[locale.languageCode]?['show_on_home_description'] ??
      'Display verification codes directly in the home account list';

  String get password =>
      _localizedValues[locale.languageCode]?['password'] ?? 'Password';

  String initialConfirmDeleteMessage(String label) {
    final template =
        _localizedValues[locale
            .languageCode]?['initial_confirm_delete_message'] ??
        'Tap "Delete" again to confirm.';
    return template.replaceAll('{label}', label);
  }

  String finalConfirmDeleteMessage(String label) {
    final template =
        _localizedValues[locale
            .languageCode]?['final_confirm_delete_message'] ??
        'This is your last chance. Tap "Delete" to permanently delete "{label}".';
    return template.replaceAll('{label}', label);
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'zh', 'ja'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
