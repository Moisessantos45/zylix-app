import 'package:flutter/material.dart';
import 'package:zylix/presentation/screens/screens.dart';
import 'package:zylix/presentation/shared/color.dart';
import 'package:zylix/presentation/widgets/tool_grid_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor.withAlpha(77),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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
            double horizontalPadding = constraints.maxWidth * 0.05;
            int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      "All Your Productivity Tools in One Place",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Easily convert, merge, and optimize your files with our suite of powerful tools.",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader(
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
                      ],
                    ),

                    const SizedBox(height: 32),
                    _buildSectionHeader(
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
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
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
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(75),
                blurRadius: 6,
                offset: const Offset(0, 2),
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
