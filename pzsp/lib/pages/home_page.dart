import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pzsp/controllers/auth_controller.dart';
import 'package:pzsp/controllers/dance_controller.dart';
import 'package:pzsp/models/dance.dart';
import 'package:pzsp/pages/add_video.dart';
import 'package:pzsp/pages/edit_video.dart';

import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DanceController _danceController = DanceController();

  List<Dance> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    setState(() => _isLoading = true);
    final dances = await _danceController.loadDances();
    setState(() {
      _items = dances;
      _isLoading = false;
    });
  }

  Future<void> deleteVideoItem(Dance dance) async {
    try {
      await _danceController.deleteDance(dance);
      await fetchItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Błąd przy usuwaniu video: ${e.toString()}'),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    await authController.signOut();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Manage films',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 8.0),
            child: ElevatedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Log out', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(child: Text('No videos available'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: item.thumbnail.isNotEmpty
                                  ? Image.network(
                                      '${item.thumbnail}?v=${DateTime.now().millisecondsSinceEpoch}',
                                      width: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.error),
                                    )
                                  : const Icon(Icons.image_not_supported,
                                      size: 80),
                              title: Text(item.title),
                              subtitle: Text(item.description),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.deepPurple),
                                    onPressed: () async {
                                      final result = await showDialog<bool>(
                                        context: context,
                                        builder: (_) =>
                                            EditVideoDialog(video: item),
                                      );
                                      if (result == true) {
                                        await fetchItems();
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.grey),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete video'),
                                          content: const Text(
                                              'Are you sure you want to delete this video?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await deleteVideoItem(item);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final added = await showDialog<bool>(
                    context: context,
                    builder: (_) => const AddVideoDialog(),
                  );
                  if (added == true) {
                    await fetchItems();
                  }
                },
                icon: const Icon(Icons.add, size: 30),
                label: const Text(
                  'Add video',
                  style: TextStyle(fontSize: 24),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
