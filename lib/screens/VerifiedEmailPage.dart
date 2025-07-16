import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'HomePage.dart';

class VerifiedEmailPage extends StatefulWidget {
  const VerifiedEmailPage({super.key});

  @override
  State<VerifiedEmailPage> createState() => _VerifiedEmailPageState();
}

class _VerifiedEmailPageState extends State<VerifiedEmailPage> {
  bool _checking = false;
  bool _cooldownActive = true;
  int _cooldown = 60;
  Timer? _timer;
  Timer? _deleteTimer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
    _startDeleteTimer();
    _sendVerificationEmail();
  }

  void _startCooldown() {
    setState(() {
      _cooldownActive = true;
      _cooldown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldown == 0) {
        setState(() {
          _cooldownActive = false;
        });
        _timer?.cancel();
      } else {
        setState(() {
          _cooldown--;
        });
      }
    });
  }

  void _startDeleteTimer() {
    _deleteTimer = Timer(const Duration(minutes: 5), () async {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      if (user != null && !user.emailVerified) {
        await user.delete();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      }
    });
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
    } catch (e) {
      print('Gagal kirim ulang email: $e');
    }
  }

  Future<void> _checkEmailVerified() async {
    setState(() {
      _checking = true;
    });

    try {
      print("🔄 Reloading user...");
      User? user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      user = FirebaseAuth.instance.currentUser;
      print("✅ Reload selesai. Email verified: ${user?.emailVerified}");

      if (user != null && user.emailVerified) {
        print("🎉 Email sudah terverifikasi. Menyimpan ke Firestore...");
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _deleteTimer?.cancel();

        if (mounted) {
          print("➡️ Navigasi ke HomePage...");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }

        return;
      }

      print("❌ Email belum terverifikasi.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email kamu belum terverifikasi.")),
        );
      }
    } catch (e) {
      print("🔥 Terjadi error saat cek verifikasi: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
      }
    }

    setState(() {
      _checking = false;
    });
  }


  @override
  void dispose() {
    _timer?.cancel();
    _deleteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Verifikasi Email")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Kami telah mengirim email verifikasi ke ${user?.email}. "
              "Silakan buka email tersebut dan klik link yang diberikan.",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _checking ? null : _checkEmailVerified,
              child: _checking
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Saya sudah verifikasi"),
            ),
            const SizedBox(height: 20),
            if (_cooldownActive)
              Text("Kirim ulang dalam $_cooldown detik...")
            else
              TextButton(
                onPressed: () {
                  _sendVerificationEmail();
                  _startCooldown();
                },
                child: const Text("Kirim ulang email verifikasi"),
              ),
          ],
        ),
      ),
    );
  }
}
