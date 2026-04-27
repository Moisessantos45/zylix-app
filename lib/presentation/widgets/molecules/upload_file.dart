import 'package:flutter/material.dart';
import 'package:zylix/presentation/shared/color.dart';
import 'package:zylix/presentation/widgets/atoms/custom_outlined_button.dart';

class UploadFile extends StatelessWidget {
  final String subtitle;
  final VoidCallback onPressed;
  const UploadFile({
    super.key,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: AppColor.primaryColor.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.upload_file_outlined,
              size: 28,
              color: AppColor.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Upload Files",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: CustomOutlinedButton(
              getDirectoryPath: onPressed,
              title: "Select Files",
              icon: Icons.upload_file,
            ),
          ),
        ],
      ),
    );
  }
}
