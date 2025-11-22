import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const QRWRApp());
}

class QRWRApp extends StatelessWidget {
  const QRWRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QRWR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const QrHomePage(),
    );
  }
}

class QrHomePage extends StatelessWidget {
  const QrHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QRWR'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.qr_code_scanner), text: 'قراءة'),
              Tab(icon: Icon(Icons.qr_code_2), text: 'إنشاء'),
            ],
          ),
        ),
        body: const TabBarView(children: [QrScannerView(), QrGeneratorView()]),
      ),
    );
  }
}

class QrScannerView extends StatefulWidget {
  const QrScannerView({super.key});

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
  bool _isScanningPaused = false;

  bool get _isSupportedCameraPlatform {
    if (kIsWeb) {
      return true;
    }
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScanner());
  }

  @override
  void reassemble() {
    super.reassemble();
    if (defaultTargetPlatform == TargetPlatform.android) {
      _controller.stop();
      if (!_isScanningPaused) {
        _startScanner();
      }
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

  void _handleTorchStateChanged() {
    if (!mounted) {
      return;
    }
    final torchState = _controller.torchState.value;
    setState(() {
      _isFlashOn = torchState == TorchState.on;
    });
  }

  void _handleCameraFacingChanged() {
    if (!mounted) {
      return;
    }
    setState(() {
      _cameraFacing = _controller.cameraFacingState.value;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!_isSupportedCameraPlatform) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed && !_isScanningPaused) {
      _startScanner();
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (!mounted) {
      return;
    }
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) {
      return;
    }
    final barcode = barcodes.firstWhere(
      (candidate) => (candidate.rawValue ?? "").isNotEmpty,
      orElse: () => barcodes.first,
    );
    setState(() {
      _barcode = barcode;
    });
  }

  Future<void> _startScanner() async {
    try {
      await _controller.start();
      if (!mounted) {
        return;
      }
      setState(() {
        _hasPermission = true;
      });
    } on MobileScannerException catch (error) {
      if (!mounted) {
        return;
      }
      if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
        setState(() {
          _hasPermission = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("???? ?????? ??? ????????. ?????? ??? ?????."),
          ),
        );
      } else {
        final message = error.errorDetails?.message ?? "???? ????? ????????.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (!_hasPermission) {
      return;
    }
    await _controller.toggleTorch();
  }

  Future<void> _flipCamera() async {
    if (!_hasPermission) {
      return;
    }
    await _controller.switchCamera();
  }

  Future<void> _copyResult() async {
    final code = _barcode?.rawValue;
    if (code == null || code.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("?? ????? ??? ???????."),
      ),
    );
  }

  Future<void> _toggleScanning() async {
    if (_isScanningPaused) {
      await _startScanner();
      if (!mounted || !_hasPermission) {
        return;
      }
    } else {
      await _controller.stop();
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _isScanningPaused = !_isScanningPaused;
    });
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
                "?????? ??? ???????? ??? ???? ??? ??? ??????.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                "????? ?????? ??????? ??????? ???? ?? ????? ???? QR.",
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

    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
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
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "???? ??? ??? ???????? ?? ????????? ?? ????? ????????.",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "???? ???????? ??? ??? QR ???? ??????? ???.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _buildResultCard(context),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      tooltip:
                          _isFlashOn ? "????? ??????" : "????? ??????",
                      onPressed: _hasPermission ? _toggleFlash : null,
                      icon: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton.filledTonal(
                      tooltip: "????? ????????",
                      onPressed: _hasPermission ? _flipCamera : null,
                      icon: Icon(
                        _cameraFacing == CameraFacing.front
                            ? Icons.camera_front
                            : Icons.camera_rear,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton.filledTonal(
                      tooltip:
                          _isScanningPaused ? "??????? ?????" : "????? ????? ??????",
                      onPressed: _hasPermission ? _toggleScanning : null,
                      icon: Icon(
                        _isScanningPaused ? Icons.play_arrow : Icons.pause,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(BuildContext context) {
    final code = _barcode?.rawValue;
    if (code == null || code.isEmpty) {
      return Center(
        child: Text(
          _hasPermission
              ? "?? ??? ?????? ?? ??? ???."
              : "??? ??? ??? ???????? ??? ????? ?? ?????.",
          textAlign: TextAlign.center,
        ),
      );
    }

    final uri = Uri.tryParse(code.trim());
    final bool isUrl =
        uri != null && uri.hasScheme && uri.host.isNotEmpty;
    final TextDirection direction =
        isUrl ? TextDirection.ltr : Directionality.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "???????:",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: SelectableText(
              code,
              style: Theme.of(context).textTheme.bodyLarge,
              textDirection: direction,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          children: [
            TextButton.icon(
              onPressed: _copyResult,
              icon: const Icon(Icons.copy),
              label: const Text("???"),
            ),
            if (isUrl)
              Chip(
                avatar: const Icon(Icons.link, size: 18),
                label: Text(
                  "????",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
        if (_isScanningPaused)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "????? ????? ??????. ???? ??? ?? ??????? ?????????.",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
      ],
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay({required this.scanArea});

  final double scanArea;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.primary;
    return IgnorePointer(
      child: Center(
        child: Container(
          width: scanArea,
          height: scanArea,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 8),
          ),
        ),
      ),
    );
  }
}

class QrGeneratorView extends StatefulWidget {
  const QrGeneratorView({super.key});

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
      setState(() {
        _qrData = null;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _qrData = _textController.text.trim();
    });
  }

  Future<void> _copyGeneratedLink() async {
    final data = _qrData;
    if (data == null || data.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: data));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ الرابط إلى الحافظة.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'حوّل أي رابط إلكتروني إلى رمز QR يمكن مشاركته أو حفظه.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _textController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'الرابط الإلكتروني',
                  hintText: 'https://example.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  suffixIcon: _textController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _textController.clear();
                            setState(() {
                              _qrData = null;
                            });
                          },
                        ),
                ),
                textDirection: TextDirection.ltr,
                validator: (value) {
                  final input = value?.trim() ?? '';
                  if (input.isEmpty) {
                    return 'الرجاء إدخال رابط إلكتروني.';
                  }
                  final uri = Uri.tryParse(input);
                  final isValidUrl =
                      uri != null && uri.hasScheme && uri.hasAuthority;
                  if (!isValidUrl) {
                    return 'تأكد من أن الرابط يبدأ بـ https:// أو http://';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
                onFieldSubmitted: (_) => _generateCode(),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _generateCode,
                icon: const Icon(Icons.qr_code_2),
                label: const Text('إنشاء الرمز'),
              ),
              const SizedBox(height: 32),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _qrData == null
                    ? const SizedBox.shrink()
                    : Column(
                        key: ValueKey(_qrData),
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: QrImageView(
                                data: _qrData!,
                                version: QrVersions.auto,
                                backgroundColor: Colors.white,
                                size: 220,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SelectableText(
                            _qrData!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textDirection: TextDirection.ltr,
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.center,
                            child: TextButton.icon(
                              onPressed: _copyGeneratedLink,
                              icon: const Icon(Icons.copy_all),
                              label: const Text('نسخ الرابط'),
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




