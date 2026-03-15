import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_client.dart';

class AuthService {
  final _client = SupabaseConfig.client;
  bool isLoading = false;

  Future<bool> register(
    String email,
    String password,
    Function setState,
  ) async {
    setState(() => isLoading = true);
    try {
      await _client.auth.signUp(email: email, password: password);
      // Logout setelah register agar session tidak aktif
      // User harus login manual setelah register
      await _client.auth.signOut();
      setState(() => isLoading = false);
      Get.snackbar(
        'Sukses',
        'Akun berhasil dibuat! Silakan login.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on AuthException catch (e) {
      setState(() => isLoading = false);
      Get.snackbar(
        'Gagal Register',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar(
        'Gagal Register',
        'Terjadi kesalahan, coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<void> login(String email, String password, Function setState) async {
    try {
      setState(() => isLoading = true);
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      Get.snackbar(
        'Gagal Login',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
