import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/food_model.dart';

class ResultScreen extends StatelessWidget {
  final FoodModel foodItem;
  final File? imageFile;

  const ResultScreen({
    super.key,
    required this.foodItem,
    this.imageFile,
  });

  Future<void> _launchMaps(String query) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch Google Maps for query: $query');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'Hasil Analisis Kuliner',
            style: TextStyle(fontWeight: FontWeight.black, fontSize: 18),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          actions: [
            VoiceAnalysisButton(foodItem: foodItem),
            const SizedBox(width: 8),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF0F9D58),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF0F9D58),
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: 'Nutrisi & Gizi', icon: Icon(Icons.analytics_outlined, size: 20)),
              Tab(text: 'Resep Masak', icon: Icon(Icons.restaurant_menu, size: 20)),
              Tab(text: 'Cari Tempat', icon: Icon(Icons.map_outlined, size: 20)),
            ],
          ),
        ),
        body: Column(
          children: [
            // Floating image card
            if (imageFile != null)
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: FileImage(imageFile!),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              foodItem.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.black,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              foodItem.scientificName.isNotEmpty
                                  ? foodItem.scientificName
                                  : "Cibus deliciosis",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, py: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'AI: ${(foodItem.confidence * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Color(0xFF0F9D58),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Fallback food banner
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(Icons.fastfood, color: Color(0xFF0F9D58), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            foodItem.name,
                            style: const TextStyle(fontWeight: FontWeight.black, fontSize: 18),
                          ),
                          Text(
                            foodItem.scientificName.isNotEmpty
                                ? foodItem.scientificName
                                : "Cibus deliciosis",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Tabs Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildNutritionTab(context),
                  _buildRecipeTab(),
                  _buildRestaurantsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Halal & Scientific Badge section
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEDF2F7)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.eco_outlined, color: Colors.blue, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Nama Ilmiah', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                            Text(
                              foodItem.scientificName.isNotEmpty ? foodItem.scientificName : 'Cibus deliciosis',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEDF2F7)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: foodItem.halalStatus == "Halal" ? Colors.emerald : Colors.amber,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sertifikasi Halal', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                            Text(
                              '${foodItem.halalStatus} (MUI)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: foodItem.halalStatus == "Halal" ? Colors.emerald : Colors.amber,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (foodItem.halalReason.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9).withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Analisis Titik Kritis Halal:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    foodItem.halalReason,
                    style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.4),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          const Text(
            'Kandungan Gizi & Nutrisi',
            style: TextStyle(fontWeight: FontWeight.black, fontSize: 14, color: Color(0xFF0F9D58)),
          ),
          const SizedBox(height: 12),

          // Macros grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildMacroItem('Kalori', '${foodItem.calories} kkal', Icons.local_fire_department, Colors.orange),
              _buildMacroItem('Protein', '${foodItem.protein} g', Icons.fitness_center, Colors.deepOrange),
              _buildMacroItem('Karbohidrat', '${foodItem.carbs} g', Icons.breakfast_dining, Colors.amber),
              _buildMacroItem('Lemak', '${foodItem.fat} g', Icons.opacity, Colors.teal),
            ],
          ),

          const SizedBox(height: 16),
          // Qualitative Nutrition Feedback
          const Text(
            '1. Analisis Kesehatan & Gizi',
            style: TextStyle(fontWeight: FontWeight.black, fontSize: 13, color: Colors.rose),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.rose.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.rose.withOpacity(0.1)),
            ),
            child: Text(
              foodItem.healthAnalysis.isNotEmpty
                  ? foodItem.healthAnalysis
                  : 'Masakan ini menyajikan kombinasi zat gizi esensial yang sangat penting untuk mendukung metabolisme harian Anda. Nikmati secukupnya sebagai bagian dari gaya hidup aktif dan pola makan seimbang.',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF2F7)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 18,
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.black, fontSize: 13, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeTab() {
    final ingredients = foodItem.recipeIngredients.split(';');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFFFF9C4),
                      radius: 18,
                      child: Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            foodItem.recipeTitle.isNotEmpty ? foodItem.recipeTitle : 'Resep Spesial Sate Matang',
                            style: const TextStyle(fontWeight: FontWeight.black, fontSize: 14),
                          ),
                          const Text('Resep diolah otomatis oleh Gemini AI', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, color: Color(0xFFEDF2F7)),
                const Text(
                  'Bahan-bahan yang Dibutuhkan:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber),
                ),
                const SizedBox(height: 10),
                ...ingredients.map((ing) {
                  final text = ing.trim();
                  if (text.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.emerald, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            text,
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 24, color: Color(0xFFEDF2F7)),
                const Text(
                  'Langkah-langkah Memasak:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber),
                ),
                const SizedBox(height: 10),
                Text(
                  foodItem.recipeInstructions.isNotEmpty
                      ? foodItem.recipeInstructions.replaceAll(r'\n', '\n')
                      : '1. Siapkan semua bahan di meja dapur.\n2. Olah daging dan sayur sesuai resep dasar masakan.\n3. Masak hingga matang dan sajikan hangat.',
                  style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cari di Sekitar Anda',
                        style: TextStyle(fontWeight: FontWeight.black, fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dapatkan penunjuk jalan langsung di Google Maps untuk menu ${foodItem.name}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _launchMaps('${foodItem.name} terdekat'),
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: const Text('Cari Peta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Rekomendasi Restoran Populer',
            style: TextStyle(fontWeight: FontWeight.black, fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          if (foodItem.suggestedRestaurants.isNotEmpty)
            ...foodItem.suggestedRestaurants.map((res) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEDF2F7)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            res.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            res.address,
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9C4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                res.rating.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _launchMaps('${res.name} ${res.address}'),
                          child: const Text(
                            'Rute Jalan ↗',
                            style: TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            })
          else
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text(
                'Saran restoran tidak tersedia.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class VoiceAnalysisButton extends StatefulWidget {
  final FoodModel foodItem;

  const VoiceAnalysisButton({super.key, required this.foodItem});

  @override
  State<VoiceAnalysisButton> createState() => _VoiceAnalysisButtonState();
}

class _VoiceAnalysisButtonState extends State<VoiceAnalysisButton> with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _initTts();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  void _initTts() async {
    await _flutterTts.setLanguage("id-ID");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
      _animationController?.repeat(reverse: true);
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
      _animationController?.stop();
    });

    _flutterTts.setCancelHandler(() {
      setState(() {
        _isSpeaking = false;
      });
      _animationController?.stop();
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _isSpeaking = false;
      });
      _animationController?.stop();
    });
  }

  Future<void> _speak() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      return;
    }

    final name = widget.foodItem.name;
    final calories = widget.foodItem.calories;
    final protein = widget.foodItem.protein;
    final carbs = widget.foodItem.carbs;
    final fat = widget.foodItem.fat;
    final halal = widget.foodItem.halalStatus;
    
    final text = "Hasil analisis makanan. Menu ini diidentifikasi sebagai $name. "
        "Kandungan gizi terdiri dari: kalori sebesar $calories kilo kalori, "
        "protein $protein gram, karbohidrat $carbs gram, "
        "dan lemak $fat gram. "
        "Makanan ini bersertifikat $halal.";

    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController!,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: _isSpeaking 
                ? const Color(0xFF0F9D58).withOpacity(0.1 + (_animationController!.value * 0.15))
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            tooltip: _isSpeaking ? 'Hentikan Suara' : 'Dengarkan Analisis',
            icon: Icon(
              _isSpeaking ? Icons.volume_up : Icons.volume_mute,
              color: _isSpeaking ? const Color(0xFF0F9D58) : Colors.black87,
            ),
            onPressed: _speak,
          ),
        );
      },
    );
  }
}
