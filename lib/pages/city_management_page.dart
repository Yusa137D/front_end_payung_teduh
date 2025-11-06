import 'package:flutter/material.dart';
import '../services/city_service.dart';

class CityManagementPage extends StatefulWidget {
  const CityManagementPage({super.key});

  @override
  State<CityManagementPage> createState() => _CityManagementPageState();
}

class _CityManagementPageState extends State<CityManagementPage> {
  final CityService _cityService = CityService();
  List<dynamic> cities = [];
  bool isLoading = false;

  // Controller untuk form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  // Load data kota
  Future<void> _loadCities() async {
    setState(() => isLoading = true);

    try {
      final response = await _cityService.getCities();
      if (response['success']) {
        setState(() {
          cities = response['data'];
        });
      } else {
        _showSnackBar(response['message'], Colors.red);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e', Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Tampilkan form tambah/edit kota
  void _showCityForm({Map<String, dynamic>? city}) {
    if (city != null) {
      _nameController.text = city['name'];
      _descriptionController.text = city['description'];
      _imageUrlController.text = city['imageUrl'] ?? '';
    } else {
      _nameController.clear();
      _descriptionController.clear();
      _imageUrlController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(city == null ? 'Tambah Kota' : 'Edit Kota'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kota',
                  hintText: 'Masukkan nama kota',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Masukkan deskripsi kota',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar (opsional)',
                  hintText: 'Masukkan URL gambar kota',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (_nameController.text.isEmpty ||
                  _descriptionController.text.isEmpty) {
                _showSnackBar(
                  'Nama dan deskripsi kota harus diisi!',
                  Colors.red,
                );
                return;
              }

              final response = city == null
                  ? await _cityService.addCity(
                      name: _nameController.text,
                      description: _descriptionController.text,
                      imageUrl: _imageUrlController.text.isNotEmpty
                          ? _imageUrlController.text
                          : null,
                    )
                  : await _cityService.updateCity(
                      id: city['id'],
                      name: _nameController.text,
                      description: _descriptionController.text,
                      imageUrl: _imageUrlController.text.isNotEmpty
                          ? _imageUrlController.text
                          : null,
                    );

              if (mounted) {
                Navigator.pop(context);
                if (response['success']) {
                  _showSnackBar(response['message'], Colors.green);
                  _loadCities();
                } else {
                  _showSnackBar(response['message'], Colors.red);
                }
              }
            },
            child: Text(city == null ? 'Tambah' : 'Update'),
          ),
        ],
      ),
    );
  }

  // Konfirmasi hapus kota
  void _showDeleteConfirmation(Map<String, dynamic> city) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kota'),
        content: Text(
          'Apakah Anda yakin ingin menghapus kota ${city['name']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final response = await _cityService.deleteCity(city['id']);
              if (response['success']) {
                _showSnackBar(response['message'], Colors.green);
                _loadCities();
              } else {
                _showSnackBar(response['message'], Colors.red);
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kota'),
        backgroundColor: Colors.yellow.shade800,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cities.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum ada data kota',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCities,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: cities.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final city = cities[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: city['imageUrl'] != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(city['imageUrl']),
                          )
                        : const CircleAvatar(child: Icon(Icons.location_city)),
                    title: Text(city['name']),
                    subtitle: Text(
                      city['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showCityForm(city: city),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteConfirmation(city),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCityForm(),
        backgroundColor: Colors.yellow.shade800,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
