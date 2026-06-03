import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/insta_logo.dart';

class HowToDownloadScreen extends StatelessWidget {
  const HowToDownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PeachBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Column(children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      color: AppColors.primary,
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        SizedBox(width: 22, height: 22, child: CustomPaint(painter: _Tri())),
                        const SizedBox(width: 12),
                        const Text('How to download?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white)),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                      child: Column(children: const [
                        _Step('Step 1', 'Copy link from Instagram, Facebook or YouTube shorts'),
                        SizedBox(height: 24),
                        _Step('Step 2', 'Paste link in the Instant Save app'),
                        SizedBox(height: 24),
                        _Step('Step 3', 'Click on the download button and enjoy'),
                      ]),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String step, desc;
  const _Step(this.step, this.desc);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(step, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
    const SizedBox(height: 6),
    Text(desc, style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.5)),
  ]);
}

class _Tri extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(Path()..moveTo(size.width/2, size.height)..lineTo(0,0)..lineTo(size.width,0)..close(),
        Paint()..color = AppColors.yellowAccent..style = PaintingStyle.fill);
  }
  @override bool shouldRepaint(_) => false;
}
