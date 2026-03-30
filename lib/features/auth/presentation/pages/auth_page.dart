import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Trang Đăng nhập',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Tạm thời điều hướng tới Main
                Navigator.pushReplacementNamed(context, AppRouter.main);
              },
              child: const Text('Bỏ qua đăng nhập -> Vào App'),
            ),
          ],
        ),
      ),
    );
  }
}
