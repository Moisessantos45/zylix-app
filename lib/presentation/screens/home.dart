import 'package:flutter/material.dart';
import 'package:zylix/presentation/screens/about.dart';
import 'package:zylix/presentation/screens/screens.dart';
import 'package:zylix/presentation/shared/color.dart';
import 'package:zylix/presentation/widgets/tool.dart';

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
        title: Text(
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
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double horizontalPadding = constraints.maxWidth * 0.05;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
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
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Explore Our Tools",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            ToolCard(
                              icon: Icons.picture_as_pdf,
                              title: "Marge PDFs",
                              description:
                                  "Combine multiple files into one seamless document",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MergePdfScreen(),
                                  ),
                                );
                              },
                            ),
                            ToolCard(
                              icon: Icons.compress,
                              title: "Compress PDFs",
                              description:
                                  "Reduce file size significantly without losing quality",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const OptimizePdfScreen(),
                                  ),
                                );
                              },
                            ),
                            ToolCard(
                              icon: Icons.transform,
                              title: "Convert PDF To Image",
                              description: "Convert pdf to image",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PdfToImageScreen(),
                                  ),
                                );
                              },
                            ),
                            ToolCard(
                              icon: Icons.broken_image,
                              title: "Images To PDF",
                              description:
                                  "Convert multiple images into one seamless document",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ImageToPdfScreen(),
                                  ),
                                );
                              },
                            ),
                            ToolCard(
                              icon: Icons.image_outlined,
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
                            ToolCard(
                              icon: Icons.imagesearch_roller,
                              title: "Image Convert",
                              description:
                                  "Switch between JPG,PNG and WebP formats",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ImageToFormantScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
