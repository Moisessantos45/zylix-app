import 'package:flutter/material.dart';
import 'package:zylix/presentation/screens/screens.dart';
import 'package:zylix/presentation/shared/color.dart';
import 'package:zylix/presentation/widgets/organisms/tool_grid_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Zylix",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primaryColor,
                      AppColor.primaryColor.withAlpha(200),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor.withAlpha(30),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double horizontalPadding = constraints.maxWidth > 800 
                ? (constraints.maxWidth - 800) / 2 
                : constraints.maxWidth * 0.05;
            if (horizontalPadding < 24) horizontalPadding = 24.0;
            int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    const Text(
                      "All Your Productivity Tools in One Place",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Easily convert, merge, and optimize your files with our suite of powerful tools.",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 32),
                    const SectionHeader(
                      icon: Icons.picture_as_pdf,
                      title: "PDF Tools",
                      color: AppColor.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                      children: [
                        ToolGridCard(
                          icon: Icons.merge_type,
                          title: "Merge PDFs",
                          description:
                              "Combine multiple files into one seamless document",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MergePdfScreen(),
                              ),
                            );
                          },
                        ),
                        ToolGridCard(
                          icon: Icons.splitscreen,
                          title: "Split PDFs",
                          description:
                              "Divide your PDFs into individual pages or custom ranges",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SplitPdfScreen(),
                              ),
                            );
                          },
                        ),
                        ToolGridCard(
                          icon: Icons.compress,
                          title: "Compress PDFs",
                          description:
                              "Reduce file size significantly without losing quality",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OptimizePdfScreen(),
                              ),
                            );
                          },
                        ),
                        ToolGridCard(
                          icon: Icons.transform,
                          title: "PDF To Image",
                          description:
                              "Transform your PDF pages into high-quality images",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PdfToImageScreen(),
                              ),
                            );
                          },
                        ),
                        ToolGridCard(
                          icon: Icons.text_snippet,
                          title: "Extract Text",
                          description:
                              "Extract text easily from your PDF documents",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ExtractTextPdfScreen(),
                              ),
                            );
                          },
                        ),
                        ToolGridCard(
                          icon: Icons.water_drop_outlined,
                          title: "Watermark",
                          description:
                              "Add a custom text watermark to every PDF page",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const WatermarkPdfScreen(),
                              ),
                            );
                          },
                        ),
                        ToolGridCard(
                          icon: Icons.rotate_right_outlined,
                          title: "Rotate PDF",
                          description:
                              "Rotate all or specific pages of a PDF",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RotatePdfScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const SectionHeader(
                      icon: Icons.image,
                      title: "Image Tools",
                      color: AppColor.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                      children: [
                        ToolGridCard(
                          icon: Icons.photo_library,
                          title: "Images To PDF",
                          description:
                              "Convert multiple images into one seamless document",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ImageToPdfScreen(),
                              ),
                            );
                          },
                        ),
                        ToolGridCard(
                          icon: Icons.compress,
                          title: "Compress Image",
                          description:
                              "Reduce file size significantly without losing quality",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const OptimizeImageScreen(),
                              ),
                            );
                          },
                        ),
                        ToolGridCard(
                          icon: Icons.transform_outlined,
                          title: "Image Convert",
                          description:
                              "Switch between JPG, PNG and WebP formats",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ImageToFormatConverterScreen(),
                              ),
                            );
                          },
                        ),
                        ToolGridCard(
                          icon: Icons.person_remove_alt_1_outlined,
                          title: "Remove Bg",
                          description:
                              "Delete backgrounds from selfies seamlessly",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RemoveBgImageScreen(),
                              ),
                            );
                          },
                        ),
                        ToolGridCard(
                          icon: Icons.crop_rotate,
                          title: "Crop & Rotate",
                          description:
                              "Crop and rotate images with precision",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CropRotateImageScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const SectionHeader(
                      icon: Icons.build_outlined,
                      title: "Utilities",
                      color: AppColor.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                      children: [
                        ToolGridCard(
                          icon: Icons.document_scanner_outlined,
                          title: "Doc Scanner",
                          description:
                              "Scan physical documents and save as PDF or JPG",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DocumentScannerScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

}

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withAlpha(30)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(30),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
