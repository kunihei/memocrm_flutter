import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginView extends HookConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'メールアドレス',
            ),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: 'パスワード',
            ),
            obscureText: true,
          ),
        ],
      ),
    );
  }
}