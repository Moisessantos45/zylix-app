import 'package:flutter/material.dart';
import 'package:zylix/presentation/shared/color.dart';

class CustomOutlinedButton extends StatelessWidget {
  final VoidCallback getDirectoryPath;
  final String title;
  final IconData icon;

  const CustomOutlinedButton({
    super.key,
    required this.getDirectoryPath,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: getDirectoryPath,
      icon: Icon(icon),
      label: Text(title),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: AppColor.primaryColor, width: 1.5),
      ),
    );
  }
}
