import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pzsp/controllers/dance_controller.dart';
import 'package:pzsp/models/dance.dart';
import 'package:pzsp/models/dance_video_selection.dart';
import 'package:pzsp/pages/video_selection_page.dart';
import 'package:pzsp/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DanceController _controller = DanceController();
  int _currentIndex = 0;
  List<Dance> _dances = [];

  @override
  void initState() {
    super.initState();
    _loadDances();
  }

  Future<void> _loadDances() async {
    final data = await _controller.loadDances();
    setState(() => _dances = data);
  }

  void _onSelectDance() {
    if (_dances.isEmpty) return;
    final selected = _dances[_currentIndex];

    final selection = DanceVideoSelection(
      imageUrl:
          '$supabaseUrl$supabaseBuckerDir/thumbnails/${selected.title}.jpg',
      videoUrl: '$supabaseUrl$supabaseBuckerDir/videos/${selected.title}.mp4',
      title: selected.title,
      description: selected.description,
      length: selected.length,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoSelectionPage(selection: selection),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MoovIT')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _dances.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    const Spacer(),
                    CarouselSlider(
                      items: _dances.map(
                        (dance) {
                          return Builder(
                            builder: (context) => Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    height: 300,
                                    child: Image.network(
                                      '$supabaseUrl$supabaseBuckerDir/thumbnails/${dance.title}.jpg',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.error, size: 50),
                                        );
                                      },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  dance.title,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  dance.description,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                      options: CarouselOptions(
                        height: 450,
                        enlargeCenterPage: true,
                        viewportFraction: 0.5,
                        onPageChanged: (i, _) =>
                            setState(() => _currentIndex = i),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _onSelectDance,
                      icon: const Icon(Icons.check_circle_outline_rounded,
                          size: 30),
                      label: const Text(
                        'Select Dance',
                        style: TextStyle(fontSize: 24),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const Spacer(
                      flex: 2,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
