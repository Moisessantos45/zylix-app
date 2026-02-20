import 'package:flutter/material.dart';
import 'package:zylix/presentation/shared/color.dart';
import 'package:zylix/presentation/widgets/custom_outlined_button.dart';

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
    final double width = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 2, color: AppColor.primaryColor.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_outlined,
            size: 32,
            color: AppColor.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            "Upload Files",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: width * 0.5,
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
