import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'downloads_screen.dart';
import 'how_to_download_screen.dart';

class AppMenuScreen extends StatelessWidget {
  const AppMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.textDark, size: 26),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Item(icon: const Icon(Icons.share_outlined, size: 28, color: AppColors.textDark), label: 'App share', onTap: () {}),
                  const _Div(),
                  _Item(label: 'How to download ?', onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HowToDownloadScreen()))),
                  const _Div(),
                  _Item(label: 'visit website', onTap: () {}),
                  const _Div(),
                  _Item(
                    icon: Container(width: 64, height: 64, decoration: const BoxDecoration(color: Color(0xFFDDE4EF), shape: BoxShape.circle), child: const Icon(Icons.bookmark, color: AppColors.textDark, size: 28)),
                    label: 'Your download',
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DownloadsScreen())),
                  ),
                  const _Div(),
                  _Item(icon: const Icon(Icons.star, size: 32, color: AppColors.textDark), label: 'Rate Us', onTap: () {}),
                ],
              ),
            ),
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final Widget? icon; final String label; final VoidCallback? onTap;
  const _Item({required this.label, this.icon, this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: SizedBox(width: double.infinity, child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[icon!, const SizedBox(height: 8)],
        Text(label, style: const TextStyle(fontSize: 15, color: AppColors.textDark)),
      ]),
    )),
  );
}

class _Div extends StatelessWidget {
  const _Div();
  @override
  Widget build(BuildContext context) => const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0));
}

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20, top: 8),
    child: Column(children: [
      const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(onTap: (){}, child: const Text('Privacy.', style: TextStyle(fontSize: 11, color: AppColors.textGray))),
        const Text(' | ', style: TextStyle(fontSize: 11, color: AppColors.textGray)),
        GestureDetector(onTap: (){}, child: const Text('General Terms of use.', style: TextStyle(fontSize: 11, color: AppColors.textGray))),
        const Text(' | ', style: TextStyle(fontSize: 11, color: AppColors.textGray)),
        GestureDetector(onTap: (){}, child: const Text('Help.', style: TextStyle(fontSize: 11, color: AppColors.textGray))),
      ]),
      const SizedBox(height: 8),
      const Text('© 2025 Monarch Inc. All rights reserved.', style: TextStyle(fontSize: 11, color: AppColors.textGray)),
    ]),
  );
}
