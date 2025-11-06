import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_services.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  bool _isObscure = true;
  bool _isLoading = false;

  OutlineInputBorder _customBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black54, width: 2),
    );
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _register() async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Validasi field kosong
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Semua field harus diisi!", Colors.red);
      return;
    }

    // Validasi email
    if (!isValidEmail(email)) {
      _showSnackBar("Format email tidak valid!", Colors.red);
      return;
    }

    // Validasi password
    if (password.length < 6) {
      _showSnackBar("Password minimal 6 karakter!", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil API Register
      final result = await _apiService.register(
        username: username,
        email: email,
        password: password,
      );

      setState(() => _isLoading = false);

      if (result['success']) {
        _showSnackBar(result['message'], Colors.green);
        
        // Pindah ke halaman login
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double formWidth = width > 600 ? 400 : width * 0.9;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: formWidth),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.brown[900],
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
                            children: [
                              const CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage(
                                  'assets/images/people.png',
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
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: "Masukkan email",
                                  border: _customBorder(),
                                  focusedBorder: _customBorder(),
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: passwordController,
                                obscureText: _isObscure,
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
                              ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text("Register"),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Sudah punya akun? Login di sini",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}