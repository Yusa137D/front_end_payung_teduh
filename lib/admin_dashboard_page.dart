import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'pages/city_management_page.dart';

class AdminDashboardPage extends StatefulWidget {
  final String username;

  const AdminDashboardPage({super.key, required this.username});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // Menu admin
  final List<Map<String, dynamic>> adminMenus = [
    {
      'title': 'Kelola User',
      'icon': Icons.people,
      'color': Colors.blue,
      'subtitle': 'Manage user accounts',
    },
    {
      'title': 'Kelola Kota',
      'icon': Icons.location_city,
      'color': Colors.green,
      'subtitle': 'Manage city data',
    },
    {
      'title': 'Data Transaksi',
      'icon': Icons.receipt_long,
      'color': Colors.orange,
      'subtitle': 'View transactions',
    },
    {
      'title': 'Laporan',
      'icon': Icons.analytics,
      'color': Colors.purple,
      'subtitle': 'View reports',
    },
    {
      'title': 'Pengaturan',
      'icon': Icons.settings,
      'color': Colors.grey,
      'subtitle': 'System settings',
    },
  ];

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.yellow.shade800,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tidak ada notifikasi baru')),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 59, 11, 171),
              const Color.fromARGB(255, 24, 129, 195),
              const Color.fromARGB(255, 122, 156, 211),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.brown[700],
                      child: Text(
                        widget.username[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang, Admin',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.username,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ADMIN',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: adminMenus.length,
                    itemBuilder: (context, index) {
                      final menu = adminMenus[index];
                      return InkWell(
                        onTap: () {
                          // Handle menu clicks
                          switch (menu['title']) {
                            case 'Kelola Kota':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CityManagementPage(),
                                ),
                              );
                              break;
                            default:
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Menu ${menu['title']} diklik'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: menu['color'].withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  menu['icon'],
                                  size: 40,
                                  color: menu['color'],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                menu['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                menu['subtitle'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
