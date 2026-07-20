import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_model.dart';
import '../services/gemini_service.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  List<FoodModel> _history = [];
  bool _isLoading = false;
  String _loadingMessage = "";

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyData = prefs.getStringList('scan_history') ?? [];
      setState(() {
        _history = historyData
            .map((item) => FoodModel.fromJson(json.decode(item)))
            .toList();
      });
    } catch (e) {
      debugPrint("Error loading history: $e");
    }
  }

  Future<void> _saveToHistory(FoodModel food) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Avoid duplicate names in history for clean presentation
      _history.removeWhere((item) => item.name == food.name);
      _history.insert(0, food);
      
      final historyStrings = _history
          .map((item) => json.encode(item.toJson()))
          .toList();
      
      await prefs.setStringList('scan_history', historyStrings);
      setState(() {});
    } catch (e) {
      debugPrint("Error saving to history: $e");
    }
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scan_history');
    setState(() {
      _history.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Riwayat pemindaian berhasil dihapus')),
      );
    }
  }

  Future<void> _pickAndAnalyzeImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isLoading = true;
        _loadingMessage = "Menganalisis Makanan...";
      });

      final bytes = await image.readAsBytes();
      
      setState(() {
        _loadingMessage = "Kecerdasan Buatan sedang menganalisis bahan...";
      });

      final result = await GeminiService.scanFoodImage(bytes);
      await _saveToHistory(result);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            foodItem: result,
            imageFile: File(image.path),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menganalisis gambar: $e')),
        );
      }
    }
  }

  // Trigger simulated food items immediately for testing/instant review
  void _selectPresetFood(String foodName) {
    setState(() {
      _isLoading = true;
      _loadingMessage = "Menganalisis Preset $foodName...";
    });

    // Simulate analysis delay
    Future.delayed(const Duration(milliseconds: 1200), () async {
      FoodModel result;
      if (foodName.toLowerCase().contains("sate matang")) {
        result = FoodModel(
          name: "Sate Matang",
          scientificName: "Bos taurus (Sapi) & Capra hircus (Kambing)",
          englishName: "Beef Skewers with Broth",
          confidence: 0.98,
          calories: 420,
          carbs: 18,
          fat: 26,
          fiber: 2,
          protein: 28,
          healthAnalysis: "Sate Matang khas Aceh kaya akan protein hewani tinggi dan zat besi yang luar biasa baik untuk sirkulasi darah. Proses pemanggangan memberikan cita rasa gurih namun disarankan mengurangi bagian yang hangus dan memakan timun segar pendamping untuk menetralkan karsinogen.",
          halalStatus: "Halal",
          halalReason: "Daging sapi atau kambing disembelih berdasarkan syariat Islam murni. Bumbu kacang disajikan higienis tanpa penambahan khamar atau pengawet non-halal.",
          recipeTitle: "Resep Sate Matang Khas Aceh Autentik",
          recipeIngredients: "500g daging sapi segar; 10 siung bawang merah; 5 siung bawang putih; 2 sdm ketumbar; 1 batang serai; 200g kacang tanah sangrai; 2 sdm kecap manis; garam secukupnya",
          recipeInstructions: "1. Potong daging sapi kecil-kecil lalu lumuri bumbu halus ketumbar dan bawang.\\n2. Tusuk daging dengan lidi sate lalu bakar di atas bara arang hingga matang.\\n3. Buat kuah soto kaldu gurih dari sisa rebusan tulang dan rempah.\\n4. Haluskan kacang tanah, campur kecap manis dan kuah soto untuk saus cocolan sate.\\n5. Sajikan sate matang hangat dengan siraman bumbu kacang dan kuah kaldu di mangkok terpisah.",
          suggestedRestaurants: [
            SuggestedRestaurant(name: "Sate Matang Khas Aceh Cut Zein", address: "Jl. Teuku Umar, Banda Aceh", rating: 4.8),
            SuggestedRestaurant(name: "Warung Sate Matang Ayah", address: "Jl. Medan-Banda Aceh, Bireuen", rating: 4.7),
          ],
        );
      } else if (foodName.toLowerCase().contains("sate ayam")) {
        result = FoodModel(
          name: "Sate Ayam",
          scientificName: "Gallus gallus domesticus",
          englishName: "Chicken Satay",
          confidence: 0.95,
          calories: 320,
          carbs: 15,
          fat: 16,
          fiber: 1,
          protein: 29,
          healthAnalysis: "Sate ayam menyajikan protein berkualitas tinggi yang sangat bagus untuk pembentukan jaringan otot tubuh harian. Bumbu kacang lezat dengan kandungan lemak tak jenuh, namun penggunaannya tetap disarankan dalam porsi wajar.",
          halalStatus: "Halal",
          halalReason: "Daging ayam segar disembelih secara syar'i oleh rumah potong bersertifikasi halal MUI. Seluruh bahan saus bumbu kacang murni berbahan dasar nabati.",
          recipeTitle: "Resep Sate Ayam Madura Asli",
          recipeIngredients: "500g fillet dada ayam; 150g kacang tanah goreng; 4 siung bawang putih; 5 siung bawang merah; 3 butir kemiri; 3 sdm kecap manis; 1 sdm air asam jawa; garam secukupnya",
          recipeInstructions: "1. Potong dadu dada ayam lalu tusuk dengan tusukan sate.\\n2. Haluskan kacang tanah, bawang merah, bawang putih, kemiri, tumis hingga harum.\\n3. Lumuri sate ayam dengan sedikit bumbu kacang dan kecap manis, lalu bakar hingga kecoklatan.\\n4. Sajikan sate dengan siraman bumbu kacang, kecap manis, irisan bawang merah, dan cabai.",
          suggestedRestaurants: [
            SuggestedRestaurant(name: "Sate Khas Senayan", address: "Menteng, Jakarta Pusat", rating: 4.6),
            SuggestedRestaurant(name: "Sate Ayam RSPP", address: "Kebayoran Baru, Jakarta Selatan", rating: 4.5),
          ],
        );
      } else {
        result = FoodModel(
          name: "Nasi Goreng Kampung",
          scientificName: "Oryza sativa",
          englishName: "Traditional Fried Rice",
          confidence: 0.96,
          calories: 390,
          carbs: 52,
          fat: 13,
          fiber: 3,
          protein: 10,
          healthAnalysis: "Karbohidrat tinggi memberikan energi instan bagi aktivitas tubuh. Disarankan menambah sayur kol, sawi, atau wortel guna meningkatkan kadar vitamin dan serat larat harian.",
          halalStatus: "Halal",
          halalReason: "Semua bumbu berupa rempah alami, kecap, dan garam bersertifikasi halal resmi dari LPPOM MUI.",
          recipeTitle: "Resep Nasi Goreng Kampung Tradisional",
          recipeIngredients: "2 piring nasi putih; 3 cabai merah; 4 siung bawang merah; 2 siung bawang putih; 1 sdt terasi bakar; 1 butir telur; garam secukupnya",
          recipeInstructions: "1. Haluskan cabai, bawang merah, bawang putih, terasi, dan garam.\\n2. Tumis bumbu halus hingga harum, masukkan telur lalu buat orak-arik.\\n3. Masukkan nasi putih, aduk rata di atas api sedang hingga harum bumbu meresap.\\n4. Sajikan dengan kerupuk, tomat, dan timun.",
          suggestedRestaurants: [
            SuggestedRestaurant(name: "Nasi Goreng Kambing Kebon Sirih", address: "Menteng, Jakarta Pusat", rating: 4.5),
          ],
        );
      }

      await _saveToHistory(result);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            foodItem: result,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F9D58)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _loadingMessage,
                style: const TextStyle(
                  fontWeight: FontWeight.black,
                  fontSize: 16,
                  color: Color(0xFF1A202C),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Kecerdasan Buatan sedang menganalisis gambar untuk mengidentifikasi bahan, resep, dan info nutrisi secara mendalam.",
                  style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Food Recognizer',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.black,
                          color: Color(0xFF1A202C),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pindai Makanan, Cek Gizi, Halal & Resep',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    radius: 20,
                    child: Icon(Icons.spa, color: Color(0xFF0F9D58), size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Upload Scanner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F9D58), Color(0xFF0B8043)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F9D58).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(Icons.photo_camera_rounded, color: Color(0xFF0F9D58), size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pindai Gambar Makanan',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.black, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ambil foto langsung atau unggah dari galeri HP Anda untuk mulai memindai.',
                      style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _pickAndAnalyzeImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt, size: 16),
                            label: const Text('Kamera'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0F9D58),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickAndAnalyzeImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library, size: 16),
                            label: const Text('Galeri'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24, width: 2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Preset Quick Demo
              const Text(
                'Coba Demo Instan',
                style: TextStyle(fontWeight: FontWeight.black, fontSize: 14, color: Color(0xFF1A202C)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildPresetItem('Sate Matang', '420 kkal', Colors.amber),
                    _buildPresetItem('Sate Ayam', '320 kkal', Colors.orange),
                    _buildPresetItem('Nasi Goreng', '390 kkal', Colors.teal),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Scanning History
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  const Text(
                    'Riwayat Pemindaian',
                    style: TextStyle(fontWeight: FontWeight.black, fontSize: 14, color: Color(0xFF1A202C)),
                  ),
                  if (_history.isNotEmpty)
                    TextButton(
                      onPressed: _clearHistory,
                      child: const Text(
                        'Hapus Semua',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (_history.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEDF2F7)),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.history_toggle_off, color: Colors.grey, size: 40),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada riwayat pemindaian',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEDF2F7)),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8F5E9),
                          child: Icon(Icons.restaurant, color: Color(0xFF0F9D58), size: 18),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          '${item.calories} kkal | Halal: ${item.halalStatus}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResultScreen(foodItem: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetItem(String name, String cal, Color color) {
    return GestureDetector(
      onTap: () => _selectPresetFood(name),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEDF2F7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  radius: 12,
                  child: Icon(Icons.restaurant, color: color, size: 10),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1A202C)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              cal,
              style: TextStyle(fontWeight: FontWeight.black, fontSize: 13, color: color),
            ),
            const SizedBox(height: 2),
            const Text(
              'Coba Instan ↗',
              style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
