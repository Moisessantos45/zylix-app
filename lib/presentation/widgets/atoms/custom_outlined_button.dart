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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        side: BorderSide(color: AppColor.primaryColor.withAlpha(80), width: 1.0),
        elevation: 0,
      ),
    );
  }
}
