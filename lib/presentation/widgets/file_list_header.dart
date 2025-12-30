import 'package:flutter/material.dart';
import 'package:zylix/presentation/shared/color.dart';

class FileListHeader extends StatelessWidget {
  final String title;
  final int amount;
  final VoidCallback onPressed;
  const FileListHeader({
    super.key,
    required this.title,
    required this.amount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "List $title ($amount)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const Spacer(),
        TextButton(
          onPressed: onPressed,
          child: Text(
            "Clean All",
            style: TextStyle(
              color: AppColor.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
