import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen pencarian KBLI dan KBJI
class KbliKbjiSearchScreen extends StatefulWidget {
  const KbliKbjiSearchScreen({super.key});

  @override
  State<KbliKbjiSearchScreen> createState() => _KbliKbjiSearchScreenState();
}

class _KbliKbjiSearchScreenState extends State<KbliKbjiSearchScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  bool _isKbliSelected = true;
  
  // TODO: Implement search logic dengan Drift local DB
  List<Map<String, String>> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Ganti dengan query ke Drift database
    // Contoh: await ref.read(appDatabaseProvider).searchKbli(query);
    
    // Mock data untuk sementara
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _searchResults = [
          {'kode': 'A01', 'judul': 'Pertanian, Perkebunan, dan Kehutanan', 'deskripsi': 'Kegiatan pertanian tanaman pangan'},
          {'kode': 'A02', 'judul': 'Kehutanan dan Penebangan Kayu', 'deskripsi': 'Kegiatan kehutanan'},
          {'kode': 'B05', 'judul': 'Pertambangan Batubara', 'deskripsi': 'Pertambangan batubara dan lignit'},
        ];
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KBLI & KBJI'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Toggle KBLI/KBJI
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('KBLI')),
                    ButtonSegment(value: false, label: Text('KBJI')),
                  ],
                  selected: {_isKbliSelected},
                  onSelectionChanged: (Set<bool> selected) {
                    setState(() {
                      _isKbliSelected = selected.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: _isKbliSelected ? 'Cari KBLI' : 'Cari KBJI',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: _performSearch,
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Masukkan kata kunci untuk mencari'
                                  : 'Tidak ditemukan hasil',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: Text(
                                '${result['kode']} - ${result['judul']}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(result['deskripsi'] ?? ''),
                              isThreeLine: true,
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                // TODO: Show detail dialog
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('${result['kode']} - ${result['judul']}'),
                                    content: Text(result['deskripsi'] ?? ''),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Tutup'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
