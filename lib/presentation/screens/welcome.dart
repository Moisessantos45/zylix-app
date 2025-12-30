import 'package:flutter/material.dart';
import 'package:zylix/config/service/native_bridge.dart';
import 'package:zylix/presentation/screens/home.dart';
import 'package:zylix/presentation/shared/color.dart';
import 'package:zylix/presentation/widgets/custom_elevated_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  Future<void> saveInitialData() async {
    await NativeBridge.saveKeyValue("firstInit", true);
  }

  Future<void> checkFirstInit() async {
    setState(() {
      isLoading = true;
    });
    bool firstInit = await NativeBridge.getKeyValue("firstInit");
    if (mounted) {
      setState(() {
        isLoading = false;
      });
      if (firstInit) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      checkFirstInit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColor.backgroundLight,
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double horizontalPadding = constraints.maxWidth * 0.08;

              return isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColor.primaryColor,
                      ),
                    )
                  : SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Spacer(flex: 2),
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColor.primaryColor,
                                    AppColor.primaryColor.withAlpha(180),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(35),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.primaryColor.withAlpha(100),
                                    blurRadius: 24,
                                    spreadRadius: 4,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.rocket_launch,
                                size: 70,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 40),
                            const Text(
                              "Zylix",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 42,
                                letterSpacing: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Welcome! 👋",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColor.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Your All-in-One File Toolkit",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Convert, merge, and optimize your files in seconds with powerful tools.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 48),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(13),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildFeatureRow(
                                    Icons.picture_as_pdf,
                                    "PDF Tools",
                                    "Merge, compress & convert",
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFeatureRow(
                                    Icons.image_outlined,
                                    "Image Tools",
                                    "Compress & format conversion",
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFeatureRow(
                                    Icons.flash_on,
                                    "Fast & Easy",
                                    "Process files in seconds",
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              child: CustomElevatedButton(
                                title: "Get Started",
                                onPressed: () async {
                                  try {
                                    await saveInitialData();
                                    if (!mounted) return;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen(),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          e.toString(),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: AppColor.primaryColor,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),

                            const Spacer(flex: 3),
                          ],
                        ),
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColor.primaryColor.withAlpha(51),
                AppColor.primaryColor.withAlpha(26),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColor.primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
