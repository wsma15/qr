import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleThemeMode() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner',
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          color: Colors.white,
          shadowColor: Color.fromRGBO(102, 51, 153, 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        textTheme: const TextTheme(
          titleMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Color(0xFF333333)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Color(0xFF6C63FF)),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            textStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF181A20),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF23234B),
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          color: Color(0xFF23234B),
          shadowColor: Color.fromRGBO(102, 51, 153, 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        textTheme: const TextTheme(
          titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Color(0xFFE3E3E3)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Color(0xFF6C63FF)),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            textStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      home: QrHomePage(
        onToggleTheme: _toggleThemeMode,
        themeMode: _themeMode,
      ),
    );
  }
}


enum QrToolTab { scan, generate }

class QrHomePage extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  const QrHomePage({super.key, this.onToggleTheme, this.themeMode});

  @override
  State<QrHomePage> createState() => _QrHomePageState();
}

class _QrHomePageState extends State<QrHomePage> {
  int _selectedIndex = 0;
  QrToolTab _toolTab = QrToolTab.scan;
  final MobileScannerController _scannerController = MobileScannerController();
  final TextEditingController _linkController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final GlobalKey _qrPreviewKey = GlobalKey();
  final List<String> _favorites = <String>[];

  bool _isHandlingResult = false;
  String? _qrData;

  @override
  void initState() {
    super.initState();
    _scannerController.addListener(_handleControllerUpdates);
  }

  @override
  void dispose() {
    _scannerController.removeListener(_handleControllerUpdates);
    _scannerController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _handleControllerUpdates() {
    if (!mounted) return;
    setState(() {});
  }

  void _handleNavigationTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _toggleTorch() async {
    try {
      await _scannerController.toggleTorch();
    } on MobileScannerException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _pickImageAndScan() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image == null) {
        return;
      }
      // تحليل الصورة للحصول على بيانات QR
      final BarcodeCapture? capture = await MobileScannerController().analyzeImage(image.path);
      final List<Barcode> barcodes = capture?.barcodes ?? [];
      if (barcodes.isEmpty || barcodes.first.rawValue == null || barcodes.first.rawValue!.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم العثور على رابط QR في الصورة المختارة.'),
          ),
        );
        return;
      }
      final String qrLink = barcodes.first.rawValue!;
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('رابط QR'),
          content: SelectableText(qrLink),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (await canLaunchUrl(Uri.parse(qrLink))) {
                  await launchUrl(Uri.parse(qrLink));
                }
              },
              child: const Text('فتح الرابط'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _favorites.add(qrLink);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تمت إضافة الرابط للمفضلة')),
                );
              },
              child: const Text('إضافة للمفضلة'),
            ),
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: qrLink));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نسخ الرابط!')),
                );
              },
              child: const Text('نسخ الرابط'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل في قراءة رمز QR من الصورة المختارة.'),
        ),
      );
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isHandlingResult) return;
    if (capture.barcodes.isEmpty) {
      return;
    }

    final Barcode barcode = capture.barcodes.first;
    final String? value = barcode.rawValue;
    if (value == null || value.isEmpty) {
      return;
    }

    _isHandlingResult = true;
    if (!mounted) return;
    // No need to set _scanResult, result is shown only in popup

    // إظهار نافذة منبثقة عند مسح QR بالكاميرا
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رابط QR'),
        content: SelectableText(value),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (await canLaunchUrl(Uri.parse(value))) {
                await launchUrl(Uri.parse(value));
              }
            },
            child: const Text('فتح الرابط'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _favorites.add(value);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تمت إضافة الرابط للمفضلة')),
              );
            },
            child: const Text('إضافة للمفضلة'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نسخ الرابط!')),
              );
            },
            child: const Text('نسخ الرابط'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 700));
    _isHandlingResult = false;
  }


  void _generateQr() {
    final String data = _linkController.text.trim();
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a link before generating.')),
      );
      return;
    }

    setState(() {
      _qrData = data;
    });
  }

  void _addFavorite(String value) {
    final String link = value.trim();
    if (link.isEmpty) {
      return;
    }
    if (_favorites.contains(link)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link is already in favorites.')),
      );
      return;
    }

    setState(() {
      _favorites.insert(0, link);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Added to favorites.')));
  }

  void _removeFavorite(String link) {
    setState(() {
      _favorites.remove(link);
    });
  }

  void _useFavorite(String link) {
    setState(() {
      _linkController.text = link;
      _qrData = link;
      _selectedIndex = 0;
      _toolTab = QrToolTab.generate;
    });
  }

  Uri? _normalizeUri(String input) {
    final String trimmed = input.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    Uri? uri = Uri.tryParse(trimmed);
    if (uri == null) {
      return null;
    }
    if (!uri.hasScheme) {
      uri = Uri.tryParse('https://$trimmed');
    }
    return uri;
  }

  Future<void> _openLink(String link) async {
    final Uri? uri = _normalizeUri(link);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('This link is not valid.')));
      return;
    }

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open the link.')));
    }
  }

  Future<void> _saveQrImage() async {
    if (_qrData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generate a QR code first.')),
      );
      return;
    }

    final RenderRepaintBoundary? boundary =
        _qrPreviewKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preview is not ready yet.')),
      );
      return;
    }

    try {
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw Exception('Could not encode image.');
      }
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final Directory tempDir = await getTemporaryDirectory();
      final File file = await File(
        '${tempDir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(pngBytes);

      final bool? result = await GallerySaver.saveImage(
        file.path,
        albumName: 'QR Toolkit',
      );

      if (result == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved to gallery.')));
      } else {
        throw Exception('Save failed');
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save the image: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isScanTab = _selectedIndex == 0 && _toolTab == QrToolTab.scan;
    final TorchState torchState = _scannerController.value.torchState;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? (_toolTab == QrToolTab.scan
                    ? 'Scan QR Code'
                    : 'Generate QR Code')
              : 'Favorites',
        ),
        actions: [
          if (isScanTab) ...[
            IconButton(
              icon: Icon(
                torchState == TorchState.on
                    ? Icons.flash_on
                    : Icons.flash_off,
              ),
              onPressed: _toggleTorch,
            ),
            IconButton(
              icon: const Icon(Icons.cameraswitch),
              onPressed: _scannerController.switchCamera,
            ),
            IconButton(
              icon: const Icon(Icons.image_outlined),
              onPressed: _pickImageAndScan,
            ),
          ],
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode // شمس
                  : Icons.dark_mode // قمر
            ),
            tooltip: Theme.of(context).brightness == Brightness.dark
                ? 'الوضع الفاتح'
                : 'الوضع الليلي',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [_buildToolsScreen(), _buildFavoritesView()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _handleNavigationTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.qr_code_2), label: 'QR Tools'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Favorites'),
        ],
      ),
    );
  }

  Widget _buildToolsScreen() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: SegmentedButton<QrToolTab>(
            segments: const [
              ButtonSegment<QrToolTab>(
                value: QrToolTab.scan,
                label: Text('Read QR'),
                icon: Icon(Icons.qr_code_scanner),
              ),
              ButtonSegment<QrToolTab>(
                value: QrToolTab.generate,
                label: Text('Generate QR'),
                icon: Icon(Icons.auto_awesome),
              ),
            ],
            selected: <QrToolTab>{_toolTab},
            onSelectionChanged: (Set<QrToolTab> value) {
              setState(() {
                _toolTab = value.first;
              });
            },
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _toolTab == QrToolTab.scan
                ? _buildScannerView()
                : _buildGeneratorView(),
          ),
        ),
      ],
    );
  }

  Widget _buildScannerView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          Expanded(
            child: Card(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: MobileScanner(
                  controller: _scannerController,
                  onDetect: _onDetect,
                ),
              ),
            ),
          ),
          // Removed scan result section under camera. Only popup will show scan results.
        ],
      ),
    );
  }

  Widget _buildGeneratorView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _linkController,
                    decoration: const InputDecoration(
                      labelText: 'Link or text',
                      hintText: 'https://example.com',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _generateQr(),
                    onChanged: (value) {
                      if (value.trim().isEmpty) {
                        setState(() {
                          _qrData = null;
                          _toolTab = QrToolTab.scan;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _generateQr,
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text('Generate QR'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_qrData != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Preview',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    RepaintBoundary(
                      key: _qrPreviewKey,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            QrImageView(
                              data: _qrData!,
                              size: 220,
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Hussein Alwisi',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: _saveQrImage,
                          icon: const Icon(Icons.download),
                          label: const Text('Save to gallery'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _openLink(_qrData!),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open link'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _addFavorite(_qrData!),
                          icon: const Icon(Icons.favorite_border),
                          label: const Text('Add to favorites'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFavoritesView() {
    if (_favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'No favorites yet. Save links from the QR tools tab to access them quickly.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _favorites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        final String link = _favorites[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.link),
            title: Text(link),
            onTap: () => _openLink(link),
            subtitle: const Text('Tap an action to open, generate, or remove'),
            trailing: Wrap(
              spacing: 4,
              children: [
                IconButton(
                  tooltip: 'Generate QR',
                  icon: const Icon(Icons.qr_code_2),
                  onPressed: () => _useFavorite(link),
                ),
                  IconButton(
                    tooltip: 'Copy Link',
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: link));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Link copied to clipboard')),
                      );
                    },
                  ),
                IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removeFavorite(link),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
