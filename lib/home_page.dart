import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'services/city_service.dart';

// Model untuk data kota
class CityModel {
  final String id;
  final String name;
  final String desc;
  final IconData icon;

  CityModel({
    required this.id,
    required this.name,
    required this.desc,
    required this.icon,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      desc: json['description'] ?? '',
      icon: Icons.location_city, // Default icon
    );
  }
}

// Halaman detail kota
class CityDetailPage extends StatelessWidget {
  final CityModel city;

  const CityDetailPage({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(city.name), backgroundColor: Colors.teal),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal, Colors.tealAccent],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(city.icon, size: 64, color: Colors.teal),
                    const SizedBox(height: 16),
                    Text(
                      city.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      city.desc,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String username;
  final bool isAdmin;
  const HomePage({super.key, required this.username, required this.isAdmin});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CityService _cityService = CityService();

  Future<List<CityModel>> _loadCities() async {
    try {
      final result = await _cityService.getCities();
      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> citiesData = result['data'];
        return citiesData.map((city) => CityModel.fromJson(city)).toList();
      }
      throw Exception(result['message'] ?? 'Failed to load cities');
    } catch (e) {
      throw Exception('Failed to load cities: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Profile di kiri atas
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.black,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.username,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 Judul daftar kota
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Daftar Kota:',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 🔹 List kota dari API
                FutureBuilder<List<CityModel>>(
                  future: _loadCities(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final cities = snapshot.data ?? [];

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: cities.length,
                      itemBuilder: (context, index) {
                        final city = cities[index];
                        return GFCard(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          boxFit: BoxFit.cover,
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(12),
                          content: GFListTile(
                            avatar: GFAvatar(
                              radius: 24,
                              backgroundColor: Colors.white,
                              child: Icon(
                                city.icon,
                                color: Colors.blueAccent,
                                size: 32,
                              ),
                            ),
                            titleText: city.name,
                            subTitleText: city.desc,
                            icon: widget.isAdmin
                                ? GestureDetector(
                                    onTap: () async {
                                      // Konfirmasi hapus
                                      bool confirm =
                                          await showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Hapus Kota'),
                                              content: Text(
                                                'Yakin ingin menghapus kota ${city.name}?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text('Batal'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text('Hapus'),
                                                ),
                                              ],
                                            ),
                                          ) ??
                                          false;

                                      if (confirm) {
                                        print(
                                          'Menghapus kota dengan ID: ${city.id}',
                                        );
                                        final result = await _cityService
                                            .deleteCity(city.id);
                                        print('Hasil penghapusan: $result');
                                        if (result['success'] == true) {
                                          setState(() {}); // Refresh list
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  result['message'] ??
                                                      'Kota berhasil dihapus',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                  ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CityDetailPage(city: city),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
