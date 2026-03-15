import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final AuthService auth;
  const RegisterPage({super.key, required this.auth});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true, _obscureC = true;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _doRegister() async {
    if (_pass.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password tidak sama'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final success = await widget.auth.register(
      _email.text.trim(),
      _pass.text.trim(),
      setState,
    );
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Buat Akun',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _field(
                          _email,
                          'Email',
                          Icons.email_outlined,
                          TextInputType.emailAddress,
                          false,
                          null,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          _pass,
                          'Password',
                          Icons.lock_outline,
                          TextInputType.text,
                          _obscure,
                          () => setState(() => _obscure = !_obscure),
                        ),
                        const SizedBox(height: 12),
                        _field(
                          _confirm,
                          'Konfirmasi Password',
                          Icons.lock_outline,
                          TextInputType.text,
                          _obscureC,
                          () => setState(() => _obscureC = !_obscureC),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: widget.auth.isLoading
                                ? null
                                : _doRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: widget.auth.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Daftar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon,
    TextInputType type,
    bool? obscure,
    VoidCallback? onToggle,
  ) => TextField(
    controller: ctrl,
    keyboardType: type,
    obscureText: obscure ?? false,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      suffixIcon: onToggle != null
          ? IconButton(
              icon: Icon(
                obscure! ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              onPressed: onToggle,
            )
          : null,
    ),
  );
}
