import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const QRWRApp());
}

enum AppLanguage { en, ar }

extension AppLanguageX on AppLanguage {
  Locale get locale =>
      this == AppLanguage.ar ? const Locale('ar') : const Locale('en');
  String get shortLabel => this == AppLanguage.ar ? 'ÃƒËœÃ‚Â¹' : 'EN';
}

Color _fadeColor(Color color, double opacity) =>
    color.withValues(alpha: opacity);

class AppStrings {
  const AppStrings(this.language);

  final AppLanguage language;

  bool get isAr => language == AppLanguage.ar;

  String get appName => isAr
      ? '\u0645\u0627\u0633\u062d QR \u0627\u0644\u0641\u0627\u062e\u0631'
      : 'QRWR Luxe';
  String get appSubtitle => isAr
      ? '\u0645\u0633\u062d \u0648\u0625\u0646\u0634\u0627\u0621 \u0631\u0645\u0632 QR \u0628\u0633\u0647\u0648\u0644\u0629'
      : 'Scan & craft QR codes effortlessly';
  String get scannerTab => isAr ? '\u0645\u0633\u062d' : 'Scan';
  String get generatorTab =>
      isAr ? '\u0625\u0646\u0634\u0627\u0621' : 'Generate';
  String get scanHeadline => isAr
      ? '\u0648\u062c\u0651\u0647 \u0627\u0644\u0643\u0627\u0645\u064a\u0631\u0627 \u0646\u062d\u0648 \u0627\u0644\u0631\u0645\u0632 \u0644\u0642\u0631\u0627\u0621\u0629 \u0633\u0631\u064a\u0639\u0629 \u0648\u0648\u0627\u0636\u062d\u0629.'
      : 'Point the camera at the QR for a fast, crisp read.';
  String get scanSubhead => isAr
      ? '\u0639\u0646\u062f \u0627\u0644\u0639\u062b\u0648\u0631 \u0639\u0644\u0649 \u0631\u0627\u0628\u0637 \u0633\u0646\u0648\u0642\u0641 \u0627\u0644\u0643\u0627\u0645\u064a\u0631\u0627 \u0648\u0646\u0639\u0631\u0636\u0647 \u0641\u064a \u0646\u0627\u0641\u0630\u0629 \u0645\u0646\u0628\u062b\u0642\u0629. \u0639\u0646\u062f \u0627\u0644\u0625\u063a\u0644\u0627\u0642 \u0646\u0639\u064a\u062f \u0627\u0644\u062a\u0634\u063a\u064a\u0644.'
      : 'When we find a link, the camera pauses and shows a popup. Closing it restarts scanning.';
  String get permissionMissing => isAr
      ? '\u0644\u0645 \u064a\u062a\u0645 \u0645\u0646\u062d \u0635\u0644\u0627\u062d\u064a\u0629 \u0627\u0644\u0643\u0627\u0645\u064a\u0631\u0627. \u0641\u0639\u0651\u0644\u0647\u0627 \u0645\u0646 \u0627\u0644\u0625\u0639\u062f\u0627\u062f\u0627\u062a.'
      : 'Camera permission is missing. Please enable it in settings.';
  String get unsupportedCameraTitle => isAr
      ? '\u0627\u0644\u0643\u0627\u0645\u064a\u0631\u0627 \u063a\u064a\u0631 \u0645\u062a\u0627\u062d\u0629'
      : 'Camera unavailable';
  String get unsupportedCameraBody => isAr
      ? '\u0647\u0630\u0627 \u0627\u0644\u062c\u0647\u0627\u0632 \u0623\u0648 \u0627\u0644\u0645\u062a\u0635\u0641\u062d \u0644\u0627 \u064a\u062f\u0639\u0645 \u062a\u0634\u063a\u064a\u0644 \u0627\u0644\u0643\u0627\u0645\u064a\u0631\u0627 \u0644\u0645\u0633\u062d QR.'
      : 'This device or browser cannot run the camera for QR scanning.';
  String get keepStill => isAr
      ? '\u062b\u0628\u0651\u062a \u0627\u0644\u062c\u0647\u0627\u0632 \u0644\u0642\u0631\u0627\u0621\u0629 \u0623\u0633\u0631\u0639'
      : 'Keep the device steady for a quick read';
  String get lastResult => isAr
      ? '\u0622\u062e\u0631 \u0646\u062a\u064a\u062c\u0629'
      : 'Latest result';
  String get lastResultEmpty => isAr
      ? '\u0644\u0645 \u064a\u062a\u0645 \u0645\u0633\u062d \u0623\u064a \u0631\u0645\u0632 \u0628\u0639\u062f.'
      : 'No code scanned yet.';
  String get cameraControls => isAr
      ? '\u0627\u0644\u062a\u062d\u0643\u0645 \u0628\u0627\u0644\u0643\u0627\u0645\u064a\u0631\u0627'
      : 'Camera controls';
  String get flashTooltip => isAr
      ? '\u062a\u0634\u063a\u064a\u0644/\u0625\u064a\u0642\u0627\u0641 \u0627\u0644\u0641\u0644\u0627\u0634'
      : 'Toggle flash';
  String get flipTooltip => isAr
      ? '\u062a\u0628\u062f\u064a\u0644 \u0628\u064a\u0646 \u0627\u0644\u0623\u0645\u0627\u0645\u064a\u0629 \u0648\u0627\u0644\u062e\u0644\u0641\u064a\u0629'
      : 'Switch front/back camera';
  String get pauseTooltip => isAr
      ? '\u0625\u064a\u0642\u0627\u0641 \u0645\u0624\u0642\u062a'
      : 'Pause scanning';
  String get resumeTooltip => isAr
      ? '\u062a\u0634\u063a\u064a\u0644 \u0627\u0644\u0643\u0627\u0645\u064a\u0631\u0627'
      : 'Resume scanning';
  String get cameraPaused => isAr
      ? '\u0627\u0644\u062a\u0635\u0648\u064a\u0631 \u0645\u062a\u0648\u0642\u0641'
      : 'Camera paused';
  String get scanning => isAr
      ? '\u064a\u062a\u0645 \u0627\u0644\u0645\u0633\u062d \u0627\u0644\u0622\u0646'
      : 'Scanning now';
  String get copy => isAr ? '\u0646\u0633\u062e' : 'Copy';
  String get copied =>
      isAr ? '\u062a\u0645 \u0627\u0644\u0646\u0633\u062e' : 'Copied';
  String get close => isAr ? '\u0625\u063a\u0644\u0627\u0642' : 'Close';
  String get openLink => isAr
      ? '\u0641\u062a\u062d \u0627\u0644\u0631\u0627\u0628\u0637'
      : 'Open link';
  String get scanAgain =>
      isAr ? '\u0645\u0633\u062d \u062c\u062f\u064a\u062f' : 'Scan again';
  String get releaseToClose => isAr
      ? '\u0627\u0633\u062d\u0628 \u0644\u0623\u0633\u0641\u0644 \u0644\u0625\u063a\u0644\u0627\u0642 \u0627\u0644\u0646\u0627\u0641\u0630\u0629 \u0648\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u062a\u0634\u063a\u064a\u0644'
      : 'Swipe down to close and resume';
  String get generatorTitle => isAr
      ? '\u0623\u0646\u0634\u0626 \u0631\u0645\u0632 QR \u0627\u0644\u062e\u0627\u0635 \u0628\u0643'
      : 'Create your QR code';
  String get generatorHint => isAr
      ? '\u0623\u062f\u062e\u0644 \u0631\u0627\u0628\u0637\u0627\u064b \u0623\u0648 \u0646\u0635\u0627\u064b \u0648\u0633\u0646\u062d\u0648\u0651\u0644\u0647 \u0625\u0644\u0649 \u0631\u0645\u0632 QR \u0623\u0646\u064a\u0642.'
      : 'Enter a link or text and we will render a sleek QR code.';
  String get inputLabel => isAr
      ? '\u0627\u0644\u0631\u0627\u0628\u0637 \u0623\u0648 \u0627\u0644\u0646\u0635'
      : 'Link or text';
  String get inputHint => 'https://example.com';
  String get inputErrorEmpty => isAr
      ? '\u0623\u062f\u062e\u0644 \u0646\u0635\u0627\u064b \u0623\u0648 \u0631\u0627\u0628\u0637\u0627\u064b \u0623\u0648\u0644\u0627\u064b.'
      : 'Please add text or a link first.';
  String get inputErrorUrl => isAr
      ? '\u064a\u0628\u062f\u0648 \u0623\u0646 \u0627\u0644\u0631\u0627\u0628\u0637 \u063a\u064a\u0631 \u0635\u0627\u0644\u062d.'
      : 'That link does not look valid.';
  String get generate =>
      isAr ? '\u0625\u0646\u0634\u0627\u0621 QR' : 'Generate QR';
  String get copyGenerated => isAr
      ? '\u0646\u0633\u062e \u0627\u0644\u0645\u062d\u062a\u0648\u0649'
      : 'Copy content';
  String get copyGeneratedMessage => isAr
      ? '\u062a\u0645 \u0646\u0633\u062e \u0627\u0644\u0645\u062d\u062a\u0648\u0649 \u0627\u0644\u0630\u064a \u0623\u0646\u0634\u0623\u062a\u0647'
      : 'Generated content copied';
  String get linkLabel => isAr ? '\u0631\u0627\u0628\u0637' : 'URL';
  String get textLabel => isAr ? '\u0646\u0635' : 'Text';
  String get themeSystem =>
      isAr ? '\u0627\u0644\u0646\u0638\u0627\u0645' : 'System';
  String get themeLight => isAr ? '\u0641\u0627\u062a\u062d' : 'Light';
  String get themeDark => isAr ? '\u062f\u0627\u0643\u0646' : 'Dark';
  String get languageToggle => isAr ? 'English' : '\u0639\u0631\u0628\u064a';
  String get openFailed => isAr
      ? '\u062a\u0639\u0630\u0631 \u0641\u062a\u062d \u0627\u0644\u0631\u0627\u0628\u0637 \u0627\u0644\u0622\u0646.'
      : 'Unable to open the link.';
}

class AppTheme {
  static const Color _seed = Color(0xFF1E8E8E);
  static ThemeData light() => _base(brightness: Brightness.light);
  static ThemeData dark() => _base(brightness: Brightness.dark);

  static ThemeData _base({required Brightness brightness}) {
    final bool isLight = brightness == Brightness.light;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
      surface: isLight ? const Color(0xFFF6F8FB) : const Color(0xFF0C1118),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStateProperty.all(
            BorderSide(color: colorScheme.outlineVariant),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 10),
          ),
        ),
      ),
    );
  }
}

class QRWRApp extends StatefulWidget {
  const QRWRApp({super.key});

  @override
  State<QRWRApp> createState() => _QRWRAppState();
}

class _QRWRAppState extends State<QRWRApp> {
  AppLanguage _language = AppLanguage.en;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(_language);
    return MaterialApp(
      title: strings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      locale: _language.locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: QrHomePage(
        strings: strings,
        language: _language,
        themeMode: _themeMode,
        onLanguageToggled: () {
          setState(
            () => _language = _language == AppLanguage.en
                ? AppLanguage.ar
                : AppLanguage.en,
          );
        },
        onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}

class QrHomePage extends StatelessWidget {
  const QrHomePage({
    super.key,
    required this.strings,
    required this.language,
    required this.themeMode,
    required this.onLanguageToggled,
    required this.onThemeModeChanged,
  });

  final AppStrings strings;
  final AppLanguage language;
  final ThemeMode themeMode;
  final VoidCallback onLanguageToggled;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _fadeColor(colorScheme.primaryContainer, 0.6),
              _fadeColor(colorScheme.surfaceContainerHighest, 0.7),
              colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _fadeColor(colorScheme.surface, 0.72),
                    _fadeColor(colorScheme.surface, 0.38),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            titleSpacing: 16,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  strings.appSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
            actions: [
              _LanguageAction(
                language: language,
                strings: strings,
                onTap: onLanguageToggled,
              ),
              _ThemeModeAction(
                themeMode: themeMode,
                strings: strings,
                onChanged: onThemeModeChanged,
              ),
              const SizedBox(width: 8),
            ],
            bottom: TabBar(
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(color: colorScheme.primary, width: 3),
                insets: const EdgeInsets.symmetric(horizontal: 24),
              ),
              tabs: [
                Tab(
                  icon: const Icon(Icons.qr_code_scanner),
                  text: strings.scannerTab,
                ),
                Tab(
                  icon: const Icon(Icons.qr_code_2),
                  text: strings.generatorTab,
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              QrScannerView(strings: strings),
              QrGeneratorView(strings: strings),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageAction extends StatelessWidget {
  const _LanguageAction({
    required this.language,
    required this.strings,
    required this.onTap,
  });

  final AppLanguage language;
  final AppStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.translate, size: 18, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(language == AppLanguage.en ? 'EN / \u0639' : '\u0639 / EN'),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeAction extends StatelessWidget {
  const _ThemeModeAction({
    required this.themeMode,
    required this.strings,
    required this.onChanged,
  });

  final ThemeMode themeMode;
  final AppStrings strings;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (themeMode) {
      case ThemeMode.dark:
        icon = Icons.dark_mode;
      case ThemeMode.light:
        icon = Icons.wb_sunny_rounded;
      case ThemeMode.system:
        icon = Icons.brightness_auto;
    }
    return PopupMenuButton<ThemeMode>(
      tooltip: strings.themeSystem,
      icon: Icon(icon),
      initialValue: themeMode,
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ThemeMode.system,
          child: Text(strings.themeSystem),
        ),
        PopupMenuItem(value: ThemeMode.light, child: Text(strings.themeLight)),
        PopupMenuItem(value: ThemeMode.dark, child: Text(strings.themeDark)),
      ],
    );
  }
}

class QrScannerView extends StatefulWidget {
  const QrScannerView({super.key, required this.strings});

  final AppStrings strings;

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView>
    with WidgetsBindingObserver {
  late final MobileScannerController _controller;
  Barcode? _barcode;
  bool _hasPermission = true;
  bool _isFlashOn = false;
  CameraFacing? _cameraFacing;
  bool _userPaused = false;
  bool _isShowingResult = false;

  bool get _shouldScan => !_userPaused && !_isShowingResult;

  bool get _isSupportedCameraPlatform {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      formats: const [BarcodeFormat.qrCode],
      autoStart: false,
    );
    _controller.torchState.addListener(_handleTorchStateChanged);
    _controller.cameraFacingState.addListener(_handleCameraFacingChanged);
    _handleTorchStateChanged();
    _handleCameraFacingChanged();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _startScannerIfNeeded(),
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    if (defaultTargetPlatform == TargetPlatform.android) {
      _controller.stop();
      _startScannerIfNeeded();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.torchState.removeListener(_handleTorchStateChanged);
    _controller.cameraFacingState.removeListener(_handleCameraFacingChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!_isSupportedCameraPlatform) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      _startScannerIfNeeded();
    }
  }

  void _handleTorchStateChanged() {
    if (!mounted) return;
    final torchState = _controller.torchState.value;
    setState(() {
      _isFlashOn = torchState == TorchState.on;
    });
  }

  void _handleCameraFacingChanged() {
    if (!mounted) return;
    setState(() {
      _cameraFacing = _controller.cameraFacingState.value;
    });
  }

  Future<void> _startScannerIfNeeded() async {
    if (!_shouldScan || !_isSupportedCameraPlatform) {
      return;
    }
    try {
      await _controller.start();
      if (!mounted) return;
      setState(() => _hasPermission = true);
    } on MobileScannerException catch (error) {
      if (!mounted) return;
      if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
        setState(() => _hasPermission = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.strings.permissionMissing)),
        );
      } else {
        final message = error.errorDetails?.message ?? 'Scanner error';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!mounted || _isShowingResult || _userPaused) return;
    final barcode = capture.barcodes.firstWhere(
      (candidate) => (candidate.rawValue ?? '').isNotEmpty,
      orElse: () => capture.barcodes.first,
    );
    final code = barcode.rawValue?.trim();
    if (code == null || code.isEmpty) return;

    setState(() {
      _barcode = barcode;
      _isShowingResult = true;
    });
    await _controller.stop();

    if (!mounted) return;
    final bool isUrl = _looksLikeUrl(code);
    await _showResultSheet(code, isUrl);

    if (!mounted) return;
    setState(() {
      _isShowingResult = false;
    });
    await _startScannerIfNeeded();
  }

  bool _looksLikeUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  Future<void> _toggleFlash() async {
    if (!_hasPermission) return;
    await _controller.toggleTorch();
  }

  Future<void> _flipCamera() async {
    if (!_hasPermission) return;
    await _controller.switchCamera();
  }

  Future<void> _toggleScanning() async {
    if (_userPaused) {
      setState(() => _userPaused = false);
      await _startScannerIfNeeded();
    } else {
      setState(() => _userPaused = true);
      await _controller.stop();
    }
  }

  Future<void> _copyToClipboard(String code, {bool showToast = true}) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted || !showToast) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(widget.strings.copied)));
  }

  Future<void> _openLink(String code) async {
    final uri = Uri.tryParse(code);
    if (uri == null) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.strings.openFailed)));
    }
  }

  Future<void> _showResultSheet(String code, bool isUrl) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ResultSheet(
          strings: widget.strings,
          code: code,
          isUrl: isUrl,
          onCopy: () => _copyToClipboard(code),
          onOpen: isUrl ? () => _openLink(code) : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSupportedCameraPlatform) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mobile_off,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                widget.strings.unsupportedCameraTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                widget.strings.unsupportedCameraBody,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final size = MediaQuery.sizeOf(context);
    final scanArea =
        (size.width < size.height ? size.width : size.height) * 0.7;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _fadeColor(Theme.of(context).colorScheme.surface, 0.4),
                    _fadeColor(
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                      0.5,
                    ),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Headline(strings: widget.strings),
              const SizedBox(height: 12),
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: _controller,
                        fit: BoxFit.cover,
                        onDetect: _onDetect,
                        overlay: _ScannerOverlay(scanArea: scanArea),
                      ),
                      if (!_hasPermission)
                        Container(
                          color: Colors.black54,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            widget.strings.permissionMissing,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _StatusCard(
                strings: widget.strings,
                isPaused: _userPaused || _isShowingResult,
                lastCode: _barcode?.rawValue,
              ),
              const SizedBox(height: 12),
              _ControlRow(
                strings: widget.strings,
                isPaused: _userPaused,
                isFlashOn: _isFlashOn,
                cameraFacing: _cameraFacing,
                onToggleFlash: _toggleFlash,
                onFlipCamera: _flipCamera,
                onToggleScanning: _toggleScanning,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.strings});
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.scanHeadline,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          strings.scanSubhead,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.strings,
    required this.isPaused,
    required this.lastCode,
  });

  final AppStrings strings;
  final bool isPaused;
  final String? lastCode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final code = lastCode?.trim() ?? '';
    final bool hasCode = code.isNotEmpty;
    final uri = hasCode ? Uri.tryParse(code) : null;
    final bool isUrl = uri != null && uri.hasScheme && uri.host.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _fadeColor(colorScheme.surface, 0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                isPaused ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: colorScheme.primary,
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.55,
                ),
                child: Text(
                  isPaused ? strings.cameraPaused : strings.scanning,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Chip(
                avatar: const Icon(Icons.camera_enhance, size: 18),
                label: Text(strings.keepStill, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            strings.lastResult,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          if (!hasCode)
            Text(
              strings.lastResultEmpty,
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          isUrl ? strings.linkLabel : strings.textLabel,
                        ),
                        avatar: Icon(
                          isUrl ? Icons.link : Icons.notes,
                          size: 18,
                        ),
                      ),
                      ActionChip(
                        label: Text(strings.copy),
                        avatar: const Icon(Icons.copy, size: 18),
                        onPressed: () =>
                            Clipboard.setData(ClipboardData(text: code)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    code,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textDirection: isUrl
                        ? TextDirection.ltr
                        : Directionality.of(context),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ControlRow extends StatelessWidget {
  const _ControlRow({
    required this.strings,
    required this.isPaused,
    required this.isFlashOn,
    required this.cameraFacing,
    required this.onToggleFlash,
    required this.onFlipCamera,
    required this.onToggleScanning,
  });

  final AppStrings strings;
  final bool isPaused;
  final bool isFlashOn;
  final CameraFacing? cameraFacing;
  final VoidCallback onToggleFlash;
  final VoidCallback onFlipCamera;
  final VoidCallback onToggleScanning;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controls = [
      (_ControlButtonData(
        icon: isFlashOn ? Icons.flash_on : Icons.flash_off,
        label: strings.flashTooltip,
        onTap: onToggleFlash,
      )),
      (_ControlButtonData(
        icon: cameraFacing == CameraFacing.front
            ? Icons.camera_front
            : Icons.camera_rear,
        label: strings.flipTooltip,
        onTap: onFlipCamera,
      )),
      (_ControlButtonData(
        icon: isPaused ? Icons.play_arrow : Icons.pause,
        label: isPaused ? strings.resumeTooltip : strings.pauseTooltip,
        onTap: onToggleScanning,
      )),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _fadeColor(colorScheme.surface, 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: controls
            .map(
              (item) => _ControlButton(
                icon: item.icon,
                label: item.label,
                onTap: item.onTap,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ControlButtonData {
  _ControlButtonData({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton.filledTonal(
      tooltip: label,
      onPressed: onTap,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(14),
        backgroundColor: colorScheme.primaryContainer,
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay({required this.scanArea});

  final double scanArea;

  @override
  Widget build(BuildContext context) {
    final borderColor = _fadeColor(Theme.of(context).colorScheme.primary, 0.9);
    return IgnorePointer(
      child: Center(
        child: Container(
          width: scanArea,
          height: scanArea,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: 6),
            boxShadow: [
              BoxShadow(
                color: _fadeColor(borderColor, 0.4),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          child: CustomPaint(painter: _CornerPainter(color: borderColor)),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double inset = 6;
    const double corner = 28;

    // Top left
    canvas.drawLine(Offset(inset, inset), Offset(corner, inset), paint);
    canvas.drawLine(Offset(inset, inset), Offset(inset, corner), paint);
    // Top right
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(size.width - corner, inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(size.width - inset, corner),
      paint,
    );
    // Bottom left
    canvas.drawLine(
      Offset(inset, size.height - inset),
      Offset(corner, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(inset, size.height - inset),
      Offset(inset, size.height - corner),
      paint,
    );
    // Bottom right
    canvas.drawLine(
      Offset(size.width - inset, size.height - inset),
      Offset(size.width - corner, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, size.height - inset),
      Offset(size.width - inset, size.height - corner),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ResultSheet extends StatelessWidget {
  const _ResultSheet({
    required this.strings,
    required this.code,
    required this.isUrl,
    required this.onCopy,
    this.onOpen,
  });

  final AppStrings strings;
  final String code;
  final bool isUrl;
  final VoidCallback onCopy;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final padding = MediaQuery.viewInsetsOf(context);
    return Padding(
      padding: EdgeInsets.only(bottom: padding.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: _fadeColor(Colors.black, 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    isUrl ? Icons.link : Icons.qr_code_2,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.lastResult,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strings.releaseToClose,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SelectableText(
                code,
                style: Theme.of(context).textTheme.bodyLarge,
                textDirection: isUrl
                    ? TextDirection.ltr
                    : Directionality.of(context),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_all),
                  label: Text(strings.copy),
                ),
                if (onOpen != null)
                  OutlinedButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.open_in_new),
                    label: Text(strings.openLink),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close),
                label: Text(strings.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QrGeneratorView extends StatefulWidget {
  const QrGeneratorView({super.key, required this.strings});

  final AppStrings strings;

  @override
  State<QrGeneratorView> createState() => _QrGeneratorViewState();
}

class _QrGeneratorViewState extends State<QrGeneratorView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  String? _qrData;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _generateCode() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() => _qrData = null);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _qrData = _textController.text.trim());
  }

  Future<void> _copyGenerated() async {
    final data = _qrData;
    if (data == null || data.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: data));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.strings.copyGeneratedMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.strings.generatorTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.strings.generatorHint,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _textController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: widget.strings.inputLabel,
                  hintText: widget.strings.inputHint,
                  suffixIcon: _textController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _textController.clear();
                            setState(() => _qrData = null);
                          },
                        ),
                ),
                textDirection: TextDirection.ltr,
                validator: (value) {
                  final input = value?.trim() ?? '';
                  if (input.isEmpty) {
                    return widget.strings.inputErrorEmpty;
                  }
                  final uri = Uri.tryParse(input);
                  final looksUrl =
                      uri != null && uri.hasScheme && uri.host.isNotEmpty;
                  if (input.toLowerCase().startsWith('http') && !looksUrl) {
                    return widget.strings.inputErrorUrl;
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
                onFieldSubmitted: (_) => _generateCode(),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _generateCode,
                icon: const Icon(Icons.qr_code_2),
                label: Text(widget.strings.generate),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _qrData == null
                    ? const SizedBox(height: 12)
                    : Column(
                        key: ValueKey(_qrData),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primaryContainer,
                                  colorScheme.surface,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: _fadeColor(Colors.black, 0.08),
                                  blurRadius: 14,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: QrImageView(
                              data: _qrData!,
                              version: QrVersions.auto,
                              backgroundColor: Colors.white,
                              size: 240,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.circle,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Wrap(
                                  spacing: 10,
                                  children: [
                                    Chip(
                                      avatar: Icon(
                                        _qrData!.startsWith('http')
                                            ? Icons.link
                                            : Icons.text_fields,
                                        size: 18,
                                      ),
                                      label: Text(
                                        _qrData!.startsWith('http')
                                            ? widget.strings.linkLabel
                                            : widget.strings.textLabel,
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: _copyGenerated,
                                      icon: const Icon(Icons.copy_all),
                                      label: Text(widget.strings.copyGenerated),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SelectableText(
                                  _qrData!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textDirection: TextDirection.ltr,
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
      ),
    );
  }
}
