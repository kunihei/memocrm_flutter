import 'package:flutter/material.dart';
import 'package:memocrm/company/models/co_models.dart';

class CoCard extends StatelessWidget {
  const CoCard({
    super.key,
    required this.co,
    required this.index,
    required this.onTap,
  });

  final CoData co;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(co.coName),
              SizedBox(height: 20),
              Text(co.coTantoName),
            ],
          ),
        ),
      ),
    );
  }
}
