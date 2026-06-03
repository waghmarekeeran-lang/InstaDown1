import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/insta_logo.dart';
import 'app_menu_screen.dart';
import 'download_progress_screen.dart';
import 'downloads_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _download() {
    final url = _ctrl.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please paste a video link first')));
      return;
    }
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => DownloadProgressScreen(url: url)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PeachBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Nav bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu,
                          color: AppColors.textDark, size: 26),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AppMenuScreen(),
                            fullscreenDialog: true),
                      ),
                    ),
                    const Expanded(
                        child: Center(child: InstaDownLogo(fontSize: 26))),
                    IconButton(
                      icon: const Icon(Icons.bookmark,
                          color: AppColors.primaryDark, size: 26),
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const DownloadsScreen())),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      const Text('Fun Extended!',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textGray)),
                      const SizedBox(height: 36),
                      const Text(
                        'Paste link below and click on download',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark),
                      ),
                      const SizedBox(height: 18),

                      // Input row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2))
                                ],
                              ),
                              child: TextField(
                                controller: _ctrl,
                                style: const TextStyle(
                                    fontSize: 14, color: AppColors.textDark),
                                decoration: const InputDecoration(
                                  hintText: 'paste link',
                                  hintStyle: TextStyle(
                                      color: AppColors.textLight, fontSize: 14),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _download,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.download_rounded,
                                  color: AppColors.white, size: 26),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Copy and paste link of YouTube shorts, Insta reels,"
                        " Facebook reels, Pintrest video's; download and enjoy!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textGray,
                            height: 1.55),
                      ),
                      const SizedBox(height: 220),
                      const Text(
                        'Go to our website and check\nyour download on big screen as well.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textGray,
                            height: 1.55),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
