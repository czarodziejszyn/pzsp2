import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../video_selection/video_selection.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;

  late Future<String?> _thumbnailFuture;

  Future<String?> fetchFirstThumbnail() async {
    final response = await Supabase.instance.client
        .from('videos')
        .select('thumbnail')  // Pobieramy tylko kolumnę 'thumbnail'
        .limit(1)  // Ograniczamy do 1 wiersza
        .single();  // Zwracamy pojedynczy rekord

    if (response != null && response['thumbnail'] != null) {
      return response['thumbnail'];
    } else {
      return null;
    }
  }

  final List<Map<String, dynamic>> _items = [
    {'image': 'https://meompxrfkofzbxjwjpvr.supabase.co/storage/v1/object/sign/thumbnails/321image.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InN0b3JhZ2UtdXJsLXNpZ25pbmcta2V5XzUyNTQwNGExLWYzNjQtNDMyMS05MmM0LWJjNWU3MDRjY2NhNCJ9.eyJ1cmwiOiJ0aHVtYm5haWxzLzMyMWltYWdlLmpwZyIsImlhdCI6MTc0NTQ3MTc4MywiZXhwIjoxNzc3MDA3NzgzfQ.RLOsO9uXhCrLSg5FQjC7GKx-jVTeisNgUyt_TgJnBTU', 'video': 'https://picsum.photos/seed/746/600', 'length': 120, 'text': 'Dance Style 1'},
    {'image': 'https://picsum.photos/seed/926/600', 'video': 'https://picsum.photos/seed/747/600', 'length': 60,   'text': 'Dance Style 2'},
    {'image': 'https://picsum.photos/seed/165/600', 'video': 'https://picsum.photos/seed/748/600', 'length': 140,   'text': 'Dance Style 3'},
    {'image': 'https://picsum.photos/seed/999/600', 'video': 'https://picsum.photos/seed/749/600', 'length': 40,   'text': 'Dance Style 4'},
  ];

  @override
  void initState() {
    super.initState();
    _thumbnailFuture = fetchFirstThumbnail();
  }

  void _onButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoSelectionPage(
          selectedImage: _items[_currentIndex]['image'],
          selectedVideo: _items[_currentIndex]['video'],
          danceDescription: _items[_currentIndex]['text'],
          length: _items[_currentIndex]['length'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Użycie FutureBuilder do pobrania tytułu
        title: FutureBuilder<String?>(
          future: _thumbnailFuture,  // Oczekiwanie na dane
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Wyświetlamy wskaźnik ładowania
            } else if (snapshot.hasError) {
              return const Text('Error loading title'); // Obsługa błędu
            } else {
              return Text(snapshot.data ?? 'Default Title'); // Wyświetlamy tytuł, jeśli jest dostępny
            }
          },
        ),
      ),
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
