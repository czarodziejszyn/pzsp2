import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'video_selection.dart';
import 'package:pzsp/constants.dart';


// https://meompxrfkofzbxjwjpvr.supabase.co/storage/v1/object/sign/thumbnails/168.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InN0b3JhZ2UtdXJsLXNpZ25pbmcta2V5X2E1NTNkOGVjLTgyYzUtNGM2Mi05NTg1LThhZTU1ZDRjYjJlOSJ9.eyJ1cmwiOiJ0aHVtYm5haWxzLzE2OC5qcGciLCJpYXQiOjE3NDc2NjM3ODEsImV4cCI6MTc3OTE5OTc4MX0.MtdPx_0e_i3doZ63fR70-f4qZ7uLsS130-FmYKBMfzU
// https://meompxrfkofzbxjwjpvr.supabase.co/storage/v1/object/sign/thumbnails/321image.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InN0b3JhZ2UtdXJsLXNpZ25pbmcta2V5X2E1NTNkOGVjLTgyYzUtNGM2Mi05NTg1LThhZTU1ZDRjYjJlOSJ9.eyJ1cmwiOiJ0aHVtYm5haWxzLzMyMWltYWdlLmpwZyIsImlhdCI6MTc0NzY2MzgwMiwiZXhwIjoxNzc5MTk5ODAyfQ.O39_OT86H5Mg1uZs475Z6xo2dgQglgYLZyYaU_aqcgQ
// https://meompxrfkofzbxjwjpvr.supabase.co/storage/v1/object/sign/videos/123name.mp4?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InN0b3JhZ2UtdXJsLXNpZ25pbmcta2V5X2E1NTNkOGVjLTgyYzUtNGM2Mi05NTg1LThhZTU1ZDRjYjJlOSJ9.eyJ1cmwiOiJ2aWRlb3MvMTIzbmFtZS5tcDQiLCJpYXQiOjE3NDc2NjM4MjcsImV4cCI6MTc3OTE5OTgyN30.vOscNiQgYQrtx3PqYxPs3_EeUKAP8FQTvcI7wqt3vEs
//

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;

  List<Map<String, dynamic>> _items = [];




  // final List<Map<String, dynamic>> _items = [
  //   {'image': 'https://meompxrfkofzbxjwjpvr.supabase.co/storage/v1/object/sign/thumbnails/168.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InN0b3JhZ2UtdXJsLXNpZ25pbmcta2V5X2E1NTNkOGVjLTgyYzUtNGM2Mi05NTg1LThhZTU1ZDRjYjJlOSJ9.eyJ1cmwiOiJ0aHVtYm5haWxzLzE2OC5qcGciLCJpYXQiOjE3NDc2NjM0ODEsImV4cCI6MTc0ODI2ODI4MX0.5HmU6USM-z7SCdwVL16NAWk6A7ekKN-n_yoCNsMmdOw', 'video': 'https://picsum.photos/seed/746/600', 'length': 120, 'text': 'Dance Style 1'},
  //   {'image': 'https://picsum.photos/seed/926/600', 'video': 'https://picsum.photos/seed/747/600', 'length': 60,   'text': 'Dance Style 2'},
  //   {'image': 'https://picsum.photos/seed/165/600', 'video': 'https://picsum.photos/seed/748/600', 'length': 140,   'text': 'Dance Style 3'},
  //   {'image': 'https://picsum.photos/seed/999/600', 'video': 'https://picsum.photos/seed/749/600', 'length': 40,   'text': 'Dance Style 4'},
  // ];

  @override
  void initState() {
    super.initState();
    fetchItems(); // już nie przypisujesz do _items
  }

  Future<void> fetchItems() async {
    final response = await Supabase.instance.client
        .from('dance_info')
        .select();

    setState(() {
      _items = List<Map<String, dynamic>>.from(response);
    });
  }

  void _onButtonPressed() {
    if (_items.isEmpty) return;  // zabezpieczenie na wypadek braku danych

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoSelectionPage(
          selectedImage: '$supabaseUrl$supabaseBuckerDir/thumbnails/${_items[_currentIndex]['title']}.jpg',
          selectedVideo: '$supabaseUrl$supabaseBuckerDir/videos/${_items[_currentIndex]['title']}.mp4',
          danceDescription: _items[_currentIndex]['description'],
          length: _items[_currentIndex]['length'],
          id: _items[_currentIndex]['id'],
        ),
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
          child: Column(
            children: [
              const Spacer(),
              _items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : CarouselSlider(
                      items: _items.map((item) {

                        return Builder(
                          builder: (BuildContext context) {
                            return Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      '$supabaseUrl$supabaseBuckerDir/thumbnails/${item['title']}.jpg',
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
                                  item['description'] ?? '',  // użyj opisu jako tekstu
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
