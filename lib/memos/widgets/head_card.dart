import 'package:flutter/material.dart';

class HeadCard extends StatelessWidget {
  const HeadCard({
    super.key,
    required this.title,
    required this.count,
    this.width = 140.0,
    this.fontColor = const Color(0xFF205CC0),
  });

  final String title;
  final int count;
  final double width;
  final Color fontColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFE0E2ED),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title),
            Text(
              '$count',
              style: TextStyle(
                color: fontColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
