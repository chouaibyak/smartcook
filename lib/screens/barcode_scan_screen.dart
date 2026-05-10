import 'package:shared_preferences/shared_preferences.dart';
import '../services/ingredient_service.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/ingredient_service.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // ── Couleurs principales du projet ─────────────────────────────
  // Vert foncé utilisé pour les boutons, textes et icônes
  static const Color _green = Color(0xFF0B5D3B);
  // Vert clair utilisé pour les fonds des badges et icônes
  static const Color _greenLight = Color(0xFFE8F5EE);

  // ── Variables d'état de la page ─────────────────────────────────
  // 0 = onglet Barcode actif, 1 = onglet AI Visual actif
  int _selectedTab = 0;
  // true pendant l'appel API OpenFoodFacts
  bool _isLoading = false;
  // true quand un produit a été trouvé et affiché
  bool _hasResult = false;
  // Stocke le dernier code-barres scanné pour éviter les doublons
  String? _scannedBarcode;
  // Nom du produit retourné par OpenFoodFacts
  String _productName = '';
  // Quantité/poids du produit retourné par OpenFoodFacts
  String _productQty = '';

  // ── Contrôleur de la caméra ─────────────────────────────────────
  // Gère l'ouverture, la fermeture et la lecture de la caméra
  final MobileScannerController _cameraController = MobileScannerController();

  // ── Libération des ressources ───────────────────────────────────
  // Appelé automatiquement quand on quitte la page
  // Important : on doit fermer la caméra pour libérer la mémoire
  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  // ── Détection d'un barcode ──────────────────────────────────────
  // Appelé automatiquement par MobileScanner à chaque lecture
  // On arrête la caméra puis on appelle OpenFoodFacts
  void _onBarcodeDetected(BarcodeCapture capture) async {
    print("BARCODE DETECTED: ${capture.barcodes.length} barcodes");
    final barcode = capture.barcodes.firstOrNull;
    print("BARCODE VALUE: ${barcode?.rawValue}");
    // Si aucun barcode détecté ou valeur vide, on ignore
    if (barcode == null || barcode.rawValue == null) return;
    // Si on est déjà en train de chercher ou qu'on a déjà un résultat, on ignore
    if (_isLoading || _hasResult) return;

    final code = barcode.rawValue!;
    // Si c'est le même barcode que le dernier scan, on ignore
    if (code == _scannedBarcode) return;

    // On met à jour l'état : chargement en cours
    setState(() {
      _scannedBarcode = code;
      _isLoading = true;
    });

    // On arrête la caméra pendant la recherche
    await _cameraController.stop();

    try {
      // Appel API OpenFoodFacts via IngredientService
      final result = await IngredientService.lookupBarcode(code);

      // Produit trouvé : on met à jour l'affichage
      setState(() {
        _productName = result['name'] ?? 'Produit inconnu';
        _productQty = result['quantity'] ?? '';
        _hasResult = true;
        _isLoading = false;
      });
    } catch (_) {
      // Produit non trouvé ou erreur réseau
      setState(() {
        _productName = 'Produit non trouvé';
        _productQty = '';
        _hasResult = true;
        _isLoading = false;
      });
    }
  }

  // ── Réinitialisation pour un nouveau scan ───────────────────────
  // Appelé après confirmation ou pour recommencer
  void _reset() {
    setState(() {
      _hasResult = false;
      _scannedBarcode = null;
      _productName = '';
      _productQty = '';
    });
    // On redémarre la caméra
    _cameraController.start();
  }

  // ── Construction de l'interface ─────────────────────────────────
  // La page est composée de : onglets + caméra + résultats + boutons
  // Pas de header ni footer ici car ils sont gérés par HomeScreen
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Sélecteur d'onglets Barcode / AI Visual
          _buildTabSelector(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Zone caméra
                  _buildCameraBox(),
                  // Section résultats (visible seulement après un scan)
                  _buildDetectedSection(),
                  const SizedBox(height: 24),
                  // Bouton de confirmation
                  _buildConfirmButton(),
                  const SizedBox(height: 12),
                  // Lien pour ajouter manuellement
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

  // ── Onglets Barcode / AI Visual ─────────────────────────────────
  // Deux onglets dans un container arrondi blanc
  // L'onglet actif a un fond blanc avec une ombre légère
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

  // ── Un onglet individuel ────────────────────────────────────────
  // index : identifiant de l'onglet (0 ou 1)
  // label : texte affiché dans l'onglet
  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        // Au clic, on change l'onglet actif
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          // Animation fluide lors du changement d'onglet
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            // Fond blanc seulement pour l'onglet actif
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            // Ombre seulement pour l'onglet actif
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
              // Vert pour l'actif, gris pour l'inactif
              color: isSelected ? _green : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }

  // ── Zone caméra ─────────────────────────────────────────────────
  // Affiche le flux caméra en mode Barcode
  // Affiche un placeholder en mode AI Visual
  // Superpose : le viseur + le texte d'instruction + le loader
  Widget _buildCameraBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ClipRRect(
        // Coins arrondis sur la zone caméra
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 300,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Caméra active en mode Barcode, placeholder en mode AI Visual
              if (_selectedTab == 0)
                MobileScanner(
                  controller: _cameraController,
                  // Callback appelé à chaque barcode détecté
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

              // Coins du viseur (dessinés par CustomPainter)
              if (_selectedTab == 0)
                CustomPaint(painter: _ScannerOverlayPainter()),

              // Texte d'instruction en bas de la caméra
              // Change selon l'état : chargement / trouvé / en attente
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  // Dégradé noir transparent → noir pour lisibilité
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

              // Indicateur de chargement pendant l'appel API
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

  // ── Section résultats détectés   ──────────────────────────────────
  // Affiche 2 cartes côte à côte : SCANNER + AI VISION
  Widget _buildDetectedSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de la section
          const Text(
            'Detected Inventory',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _green,
            ),
          ),
          const SizedBox(height: 12),
          // 2 cartes côte à côte
          Row(
            children: [
              // Carte gauche : produit scanné par barcode
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
              // Carte droite : placeholder AI VISION (pour l'instant fixe)
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

  // ── Carte d'un produit détecté ──────────────────────────────────
  // Affiche : badge (SCANNER/AI VISION) + icône + nom + quantité
  Widget _buildResultCard({
    required String tag, // Texte du badge ex: 'SCANNER'
    required Color tagColor, // Couleur de fond du badge
    required Color tagTextColor, // Couleur du texte du badge
    required IconData icon, // Icône du produit
    required Color iconColor, // Couleur de l'icône
    required String name, // Nom du produit
    String? subtitle, // Quantité (optionnel)
    Color? subtitleColor, // Couleur du texte de sous-titre (optionnel)
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
          // Badge SCANNER ou AI VISION en haut à droite
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
          // Icône du produit dans un cercle coloré
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: tagColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 10),
          // Nom du produit
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          // Quantité (affichée seulement si disponible)
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

  // ── Bouton Confirm Results ──────────────────────────────────────
  // Actif seulement quand un produit a été détecté (_hasResult == true)
  // Au clic : affiche un message de succès et remet la page à zéro
  // TODO: connecter à l'inventaire via InventoryController
  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          // Bouton désactivé (gris) si pas encore de résultat
          onPressed: _hasResult
              ? () async {
                  // Récupérer le token depuis le storage
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('token') ?? '';

                  // Envoyer le produit scanné à l'inventaire
                  final success = await IngredientService.addItem(token, {
                    'nom': _productName,
                    'quantite': _productQty.isNotEmpty ? _productQty : '1',
                  });

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Produit ajouté à l\'inventaire !'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erreur lors de l\'ajout !'),
                      ),
                    );
                  }
                  _reset();
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
            // Gris quand désactivé
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

  // ── Lien Add Items Manually ─────────────────────────────────────
  // Permet à l'utilisateur d'ajouter un produit sans scanner
  // TODO: naviguer vers add_ingredient_screen
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

// ── Painter pour dessiner les coins du viseur ───────────────────────
// Dessine 4 coins en vert dans la zone caméra
// Indique à l'utilisateur où placer le barcode
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Style du trait : vert, épais, bout arrondi
    final paint = Paint()
      ..color = const Color(0xFF0B5D3B)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Marges depuis les bords de la caméra
    const double margin = 60;
    // Longueur de chaque coin
    const double cornerLen = 24;

    final double left = margin;
    final double top = margin;
    final double right = size.width - margin;
    final double bottom = size.height - margin;

    // Coin haut-gauche
    canvas.drawLine(Offset(left, top + cornerLen), Offset(left, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLen, top), paint);
    // Coin haut-droit
    canvas.drawLine(Offset(right - cornerLen, top), Offset(right, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + cornerLen), paint);
    // Coin bas-gauche
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
    // Coin bas-droit
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

  // Pas besoin de redessiner si rien ne change
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
