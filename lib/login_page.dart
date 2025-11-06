import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:getwidget/getwidget.dart';
import '../services/api_services.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'admin_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isObscure = true;
  bool _isLoading = false;

  Future<void> _login() async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Semua field harus diisi!", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil API Login
      final result = await _apiService.login(
        username: username,
        email: email,
        password: password,
      );

      setState(() => _isLoading = false);

      if (result['success']) {
        // Debug print untuk melihat response lengkap
        print('🔍 DEBUG - Full Response: $result');

        // Validasi data
        final userData = result['data'];
        if (userData == null) {
          _showSnackBar("Data user tidak ditemukan", Colors.red);
          return;
        }

        // Debug print untuk data spesifik dan tipe data
        print(
          '🔍 DEBUG - Username: ${userData['username']} (${userData['username'].runtimeType})',
        );
        print(
          '🔍 DEBUG - Email: ${userData['email']} (${userData['email'].runtimeType})',
        );
        print(
          '🔍 DEBUG - ID: ${userData['id']} (${userData['id'].runtimeType})',
        );
        print(
          '🔍 DEBUG - Role: ${userData['role']} (${userData['role'].runtimeType})',
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        // Simpan data dengan null check
        await prefs.setString(
          'username',
          userData['username']?.toString() ?? '',
        );
        await prefs.setString('email', userData['email']?.toString() ?? '');
        await prefs.setString('userId', userData['id']?.toString() ?? '');
        await prefs.setString('role', userData['role']?.toString() ?? 'user');
        await prefs.setString('token', result['token']?.toString() ?? '');

        _showSnackBar(result['message'] ?? "Login berhasil", Colors.green);

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          // Get and process role data with detailed logging
          print('🔍 DEBUG - Full userData: $userData');
          print('🔍 DEBUG - userData type: ${userData.runtimeType}');

          // Debug print untuk melihat seluruh data user
          print('🔍 DEBUG - Seluruh data user: $userData');

          final rawRole = userData['role'];
          print('🔍 DEBUG - Role dari server: "$rawRole"');

          // Pengecekan dan normalisasi role
          String role = 'user'; // default role
          if (rawRole != null && rawRole.toString().trim().isNotEmpty) {
            role = rawRole.toString().trim().toLowerCase();
          }

          print('🔍 DEBUG - Role setelah normalisasi: "$role"');

          // Pengecekan admin yang lebih ketat
          final isAdmin = role == 'admin';
          print('🔍 DEBUG - Apakah role admin? $isAdmin');

          if (isAdmin) {
            print('➡️  Redirecting to Admin Dashboard');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => AdminDashboardPage(
                  username: userData['username']?.toString() ?? 'Admin',
                ),
              ),
            );
          } else {
            print('➡️  Redirecting to Home Page');
            print('🔍 DEBUG - Role tidak cocok dengan admin: role="$role"');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(
                  username: userData['username']?.toString() ?? 'User',
                  isAdmin: role == 'admin',
                ),
              ),
            );
          }
        }
      } else {
        _showSnackBar(result['message'], Colors.red);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Terjadi kesalahan: ${e.toString()}", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  OutlineInputBorder _customBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black54, width: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double formWidth = width > 600 ? 400 : width * 0.9;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: formWidth,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.yellowAccent.shade400,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const CircleAvatar(
                                        radius: 40,
                                        backgroundImage: AssetImage(
                                          'assets/images/1.png',
                                        ),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      const SizedBox(height: 20),
                                      TextField(
                                        controller: usernameController,
                                        decoration: InputDecoration(
                                          labelText: "Masukkan username",
                                          border: _customBorder(),
                                          focusedBorder: _customBorder(),
                                          fillColor: Colors.white,
                                          filled: true,
                                        ),
                                        autofillHints: const ['username'],
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: InputDecoration(
                                          labelText: "Masukkan email",
                                          border: _customBorder(),
                                          focusedBorder: _customBorder(),
                                          fillColor: Colors.white,
                                          filled: true,
                                        ),
                                        autofillHints: const ['email'],
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: passwordController,
                                        obscureText: _isObscure,
                                        autofillHints: const ['password'],
                                        decoration: InputDecoration(
                                          labelText: "Masukkan password",
                                          border: _customBorder(),
                                          focusedBorder: _customBorder(),
                                          fillColor: Colors.white,
                                          filled: true,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isObscure
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isObscure = !_isObscure;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      GFButton(
                                        onPressed: _isLoading ? null : _login,
                                        text: _isLoading
                                            ? "Loading..."
                                            : "Login",
                                        icon: _isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Icon(
                                                Icons.login,
                                                color: Colors.white,
                                              ),
                                        fullWidthButton: true,
                                        size: GFSize.LARGE,
                                        color: Colors.deepPurple,
                                        shape: GFButtonShape.pills,
                                        blockButton: true,
                                        type: GFButtonType.solid,
                                      ),
                                      const SizedBox(height: 16),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const RegisterPage(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Belum punya akun? Daftar di sini",
                                          style: TextStyle(
                                            color: Colors.black,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
