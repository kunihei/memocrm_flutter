import 'package:flutter/material.dart';

class DummyView extends StatelessWidget {
  const DummyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ダミー')),
      body: const Center(child: Text('ダミー画面')),
    );
  }
}
