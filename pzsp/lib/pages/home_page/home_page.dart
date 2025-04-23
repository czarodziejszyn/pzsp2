import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../video_selection/video_selection.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _items = [
    {'image': 'https://picsum.photos/seed/745/600', 'text': 'Dance Style 1'},
    {'image': 'https://picsum.photos/seed/926/600', 'text': 'Dance Style 2'},
    {'image': 'https://picsum.photos/seed/165/600', 'text': 'Dance Style 3'},
    {'image': 'https://picsum.photos/seed/999/600', 'text': 'Dance Style 4'},
  ];

  void _onButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoSelectionPage(
          selectedImage: _items[_currentIndex]['image'],
          danceStyle: _items[_currentIndex]['text'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dance App')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const Spacer(),
              CarouselSlider(
                items: _items.map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item['image'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.error, size: 50),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item['text'],
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    },
                  );
                }).toList(),
                carouselController: _controller,
                options: CarouselOptions(
                  height: 400,
                  initialPage: _currentIndex,
                  viewportFraction: 0.5,
                  pageSnapping: true,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _onButtonPressed,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 30),
                label: const Text('Select Dance', style: TextStyle(fontSize: 24)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}