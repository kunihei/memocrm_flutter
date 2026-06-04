import 'package:flutter/material.dart';
import 'package:memocrm/memos/models/memo_model.dart';

class MemoCard extends StatelessWidget {
  const MemoCard({super.key, required this.memo});

  final MemoData memo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.fromLTRB(22, 20, 22, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                memo.tantoName,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Text(
                memo.time,
                style: TextStyle(fontSize: 14, color: Color(0xFF8A8C92)),
              ),
              SizedBox(height: 15),
              Text(
                memo.title,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(height: 5),
              Text(
                memo.content,
                style: TextStyle(color: Color(0xFF8A8C92)),
                ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: memo.tags.map((tag) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(206, 241, 242, 246),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tag.tagName,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF555555),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
