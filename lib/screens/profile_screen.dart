import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../providers/user_notifier.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _favController = TextEditingController();
  bool _controllersInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controllersInitialized) {
      final user = context.read<UserNotifier>().user;
      _nameController = TextEditingController(text: user.name);
      _emailController = TextEditingController(text: user.email);
      _controllersInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _favController.dispose();
    super.dispose();
  }

  // Latihan 5: Menambahkan Validasi Keamanan
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final nameInput = _nameController.text.trim();
      final emailInput = _emailController.text.trim();

      // Validasi 1: Cegah Karakter Berbahaya (script injection / XSS)
      final scriptRegex = RegExp(r'<[^>]*script', caseSensitive: false);
      if (scriptRegex.hasMatch(nameInput) || scriptRegex.hasMatch(emailInput)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terdeteksi input karakter berbahaya (<script>)!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validasi 2: Cek ketersediaan email via SharedPreferences (Simulasi)
      final prefs = await SharedPreferences.getInstance();

      // Ambil daftar email terdaftar (jika tidak ada, buat list kosong)
      final List<String> registeredEmails =
          prefs.getStringList('registered_emails') ?? [];

      if (!mounted) return;
      final currentEmail = context.read<UserNotifier>().user.email;

      // Tolak jika email sudah terdaftar DAN email tersebut bukan milik profil pengguna saat ini
      if (registeredEmails.contains(emailInput) && emailInput != currentEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email sudah digunakan oleh pengguna lain!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Tambahkan email baru ke daftar terdaftar jika belum ada
      if (!registeredEmails.contains(emailInput)) {
        registeredEmails.add(emailInput);
        await prefs.setStringList('registered_emails', registeredEmails);
      }

      // Simpan pembaruan data pengguna
      if (!mounted) return;
      final updatedUser = context.read<UserNotifier>().user.copyWith(
        name: nameInput,
        email: emailInput,
        isLoggedIn: true,
      );

      await context.read<UserNotifier>().updateUser(updatedUser);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<UserNotifier>().logout();
              Navigator.pop(context);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = context.watch<UserNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (userNotifier.user.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
        ],
      ),
      body: userNotifier.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Profil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Latihan 3: UI Daftar Favorit
                    const Text(
                      'Daftar Favorit / Hobi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _favController,
                            decoration: const InputDecoration(
                              hintText: 'Tambah Favorit Baru',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.add_box,
                            size: 36,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () {
                            final text = _favController.text.trim();
                            if (text.isNotEmpty) {
                              context.read<UserNotifier>().addFavorite(text);
                              _favController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: userNotifier.favorites.length,
                      itemBuilder: (context, index) {
                        final item = userNotifier.favorites[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(item),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                context.read<UserNotifier>().removeFavorite(
                                  item,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    Card(
                      color: Colors.amber[50],
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, color: Colors.amber),
                                SizedBox(width: 8),
                                Text(
                                  'Catatan Keamanan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Data disimpan di SharedPreferences (plaintext). Jangan simpan password atau data sensitif di sini. Gunakan secure storage untuk data sensitif.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
