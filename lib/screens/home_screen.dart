import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_notifier.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userNotifier = context.watch<UserNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // Latihan 1: Tombol Toggle Tema
          IconButton(
            icon: Icon(userNotifier.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => context.read<UserNotifier>().toggleTheme(),
            tooltip: 'Ubah Tema',
          ),
        ],
      ),
      body: userNotifier.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.home, size: 80, color: Colors.deepPurple),
                    const SizedBox(height: 16),
                    
                    // Latihan 2: Menampilkan Jumlah Kunjungan
                    Card(
                      elevation: 2,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text(
                          'Aplikasi telah dibuka: ${userNotifier.visitCount} kali',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      userNotifier.user.isLoggedIn
                          ? 'Selamat datang, ${userNotifier.user.name}!'
                          : 'Selamat datang, Tamu!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (userNotifier.user.isLoggedIn) ...[
                      Text(
                        'Email: ${userNotifier.user.email}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
                        },
                        icon: const Icon(Icons.person),
                        label: const Text('Lihat Profil'),
                      ),
                    ] else ...[
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('Login / Daftar'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}