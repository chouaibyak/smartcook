import 'package:shared_preferences/shared_preferences.dart';
import '../services/ingredient_service.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // ── Couleurs principales du projet ─────────────────────────────
  static const Color _green = Color(0xFF0B5D3B);
  static const Color _greenLight = Color(0xFFE8F5EE);

  // ── Variables d'état de la page ─────────────────────────────────
  int _selectedTab = 0;
  bool _isLoading = false;
  bool _hasResult = false;
  String? _scannedBarcode;
  String _productName = '';
  String _productQty = '';

  // Variable pour stocker TOUTES les infos du produit (calories, image, marque, etc.)
  Map<String, dynamic>? _scannedProductData;

  // ── Contrôleur de la caméra ─────────────────────────────────────
  final MobileScannerController _cameraController = MobileScannerController();

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  // ── Détection d'un barcode ──────────────────────────────────────
  void _onBarcodeDetected(BarcodeCapture capture) async {
    print("BARCODE DETECTED: ${capture.barcodes.length} barcodes");
    final barcode = capture.barcodes.firstOrNull;
    print("BARCODE VALUE: ${barcode?.rawValue}");

    if (barcode == null || barcode.rawValue == null) return;
    if (_isLoading || _hasResult) return;

    final code = barcode.rawValue!;
    if (code == _scannedBarcode) return;

    setState(() {
      _scannedBarcode = code;
      _isLoading = true;
    });

    await _cameraController.stop();

    try {
      final result = await IngredientService.lookupBarcode(code);

      setState(() {
        _productName = result['name'] ?? 'Produit inconnu';
        _productQty = result['quantity'] ?? '';

        // On garde tout l'objet en mémoire (avec calories, imageUrl, brand...)
        _scannedProductData = result;

        _hasResult = true;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _productName = 'Produit non trouvé';
        _productQty = '';
        _scannedProductData = null;
        _hasResult = true;
        _isLoading = false;
      });
    }
  }

  // ── Réinitialisation pour un nouveau scan ───────────────────────
  void _reset() {
    setState(() {
      _hasResult = false;
      _scannedBarcode = null;
      _productName = '';
      _productQty = '';
      _scannedProductData = null; // On vide la mémoire du produit
    });
    _cameraController.start();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildTabSelector(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCameraBox(),
                  _buildDetectedSection(),
                  const SizedBox(height: 24),
                  _buildConfirmButton(),
                  const SizedBox(height: 12),
                  _buildAddManuallyButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [_buildTab(0, 'Barcode'), _buildTab(1, 'AI Visual')],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? _green : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 300,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_selectedTab == 0)
                MobileScanner(
                  controller: _cameraController,
                  onDetect: _onBarcodeDetected,
                )
              else
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Text(
                      'AI Visual — bientôt disponible',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),

              if (_selectedTab == 0)
                CustomPaint(painter: _ScannerOverlayPainter()),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: Text(
                    _isLoading
                        ? 'Recherche du produit...'
                        : _hasResult
                        ? 'Produit détecté !'
                        : 'Align barcode within frame',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetectedSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detected Inventory',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _green,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildResultCard(
                  tag: 'SCANNER',
                  tagColor: _greenLight,
                  tagTextColor: _green,
                  icon: Icons.egg_outlined,
                  iconColor: _green,
                  name: _productName,
                  subtitle: _productQty.isNotEmpty ? 'Qty: $_productQty' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResultCard(
                  tag: 'AI VISION',
                  tagColor: const Color(0xFFFFF0E8),
                  tagTextColor: const Color(0xFFD85A30),
                  icon: Icons.water_drop_outlined,
                  iconColor: const Color(0xFFD85A30),
                  name: 'Whole Milk',
                  subtitle: 'Replace soon',
                  subtitleColor: const Color(0xFFD85A30),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required String tag,
    required Color tagColor,
    required Color tagTextColor,
    required IconData icon,
    required Color iconColor,
    required String name,
    String? subtitle,
    Color? subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: tagColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: tagTextColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: tagColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: subtitleColor ?? Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _hasResult
              ? () async {
                  final prefs = await SharedPreferences.getInstance();
                  final storedToken = prefs.getString('token') ?? '';

                  print("TOKEN RÉCUPÉRÉ: $storedToken");

                  // Sécurisation et extraction propre des valeurs reçues de l'API
                  final String rawType = (_scannedProductData?['type'] ?? '')
                      .toString();
                  final String cleanType = rawType.contains(':')
                      ? rawType.split(':').first
                      : (rawType.isNotEmpty ? rawType : 'Aliment');

                  final String rawCategory =
                      (_scannedProductData?['categorie'] ?? '').toString();
                  final String cleanCategory = rawCategory.length > 50
                      ? rawCategory.substring(0, 50)
                      : rawCategory;

                  // Traduction et mise en forme des clés pour correspondre exactement à l'API Node.js
                  final Map<String, dynamic> itemData = {
                    'nom': _productName,
                    'quantite': 1.0,
                    'unite': _productQty.isNotEmpty ? _productQty : 'pcs',
                    'barcode': _scannedBarcode,
                    'calories': _scannedProductData?['calories'] ?? 0.0,
                    'proteines': _scannedProductData?['proteines'] ?? 0.0,
                    'glucides': _scannedProductData?['glucides'] ?? 0.0,
                    'lipides': _scannedProductData?['lipides'] ?? 0.0,
                    'marque': _scannedProductData?['brand'] ?? 'Inconnu',
                    'imageUrl': _scannedProductData?['imageUrl'] ?? '',
                    'categorie': cleanCategory.isNotEmpty
                        ? cleanCategory
                        : 'Divers',
                    'type': cleanType,
                    'allergenes': _scannedProductData?['allergenes'] ?? '',
                  };

                  print("DEBUG ENVOI FLUTTER -> $itemData");

                  final success = await IngredientService.addItem(
                    storedToken,
                    itemData,
                  );

                  if (success) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Ajouté à l\'inventaire !'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _reset();
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '❌ Erreur lors de l\'ajout côté serveur (Code 500)',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              : null,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          label: const Text(
            'Confirm Results',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            disabledBackgroundColor: Colors.grey[300],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddManuallyButton() {
    return GestureDetector(
      onTap: () {
        // TODO: navigation vers add_ingredient_screen
      },
      child: const Text(
        'Add Items Manually',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 5, 76, 8),
          fontSize: 14,
        ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0B5D3B)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double margin = 60;
    const double cornerLen = 24;

    final double left = margin;
    final double top = margin;
    final double right = size.width - margin;
    final double bottom = size.height - margin;

    canvas.drawLine(Offset(left, top + cornerLen), Offset(left, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLen, top), paint);
    canvas.drawLine(Offset(right - cornerLen, top), Offset(right, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + cornerLen), paint);
    canvas.drawLine(
      Offset(left, bottom - cornerLen),
      Offset(left, bottom),
      paint,
    );
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left + cornerLen, bottom),
      paint,
    );
    canvas.drawLine(
      Offset(right - cornerLen, bottom),
      Offset(right, bottom),
      paint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right, bottom - cornerLen),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
