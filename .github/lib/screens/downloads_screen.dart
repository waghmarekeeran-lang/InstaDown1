import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../theme/app_colors.dart';
import 'video_player_screen.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});
  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final _hive = HiveService();
  late List<Map<String, dynamic>> _items;

  @override
  void initState() { super.initState(); _load(); }

  void _load() => setState(() => _items = _hive.all());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Your Downloads',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.textDark)),
      ),
      body: _items.isEmpty
          ? const _Empty()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _items.length,
              itemBuilder: (_, i) => _Tile(
                item: _items[i],
                onPlay: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerScreen(
                        filePath: _items[i]['filePath'] as String? ?? ''),
                  ),
                ),
                onOpenWith: () => _showOpenWith(context, _items[i]),
                onDelete: () async {
                  await _hive.delete(_items[i]['id'] as String);
                  _load();
                },
              ),
            ),
    );
  }

  void _showOpenWith(BuildContext ctx, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _OpenWithSheet(filePath: item['filePath'] as String? ?? ''),
    );
  }
}

class _Tile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onPlay, onOpenWith, onDelete;
  const _Tile(
      {required this.item,
      required this.onPlay,
      required this.onOpenWith,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final thumb = item['thumbnailUrl'] as String? ?? '';
    final label = '${item['source'] ?? 'Video'} - ${item['date'] ?? ''}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: onOpenWith,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(alignment: Alignment.center, children: [
              // Thumbnail
              thumb.isNotEmpty
                  ? Image.network(thumb,
                      width: double.infinity, height: 195, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _ThumbPlaceholder())
                  : _ThumbPlaceholder(),
              // Scrim
              Container(
                  width: double.infinity, height: 195,
                  color: Colors.black.withOpacity(0.35)),
              // Play button
              GestureDetector(
                onTap: onPlay,
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: AppColors.textDark, size: 32),
                ),
              ),
              // Delete
              Positioned(
                top: 8, right: 8,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.black45, shape: BoxShape.circle),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
        ]),
      ),
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity, height: 195, color: const Color(0xFF263550),
        child: const Center(
            child: Icon(Icons.image_outlined, color: Colors.white24, size: 40)),
      );
}

// ─── Open With sheet ──────────────────────────────────────────────────────────
class _OpenWithSheet extends StatelessWidget {
  final String filePath;
  const _OpenWithSheet({required this.filePath});

  static const _apps = [
    _App(Color(0xFFFF8C00), Icons.play_circle_outline, 'VLC'),
    _App(Color(0xFF7B2FBE), Icons.videocam_outlined,   'Recorder'),
    _App(Color(0xFF25D366), Icons.chat_bubble_outline, 'WhatsApp'),
    _App(Color(0xFF1E90FF), Icons.play_arrow_rounded,  'Player'),
    _App(Color(0xFF7C4DFF), null, ''),
    _App(Color(0xFFFF8A50), null, ''),
    _App(Color(0xFF78909C), null, ''),
    _App(Color(0xFFFF7043), null, ''),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Open with',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12),
          itemCount: _apps.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                  color: _apps[i].color, borderRadius: BorderRadius.circular(14)),
              child: _apps[i].icon != null
                  ? Icon(_apps[i].icon, color: Colors.white, size: 28)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Divider(height: 1, color: Color(0xFFE8E8E8)),
        IntrinsicHeight(
          child: Row(children: [
            Expanded(child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Just Once',
                    style: TextStyle(color: AppColors.textDark, fontSize: 14)))),
            const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE8E8E8)),
            Expanded(child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Always',
                    style: TextStyle(color: AppColors.textDark, fontSize: 14)))),
          ]),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}

class _App {
  final Color color;
  final IconData? icon;
  final String name;
  const _App(this.color, this.icon, this.name);
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.download_for_offline_outlined,
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No downloads yet',
              style: TextStyle(fontSize: 16, color: AppColors.textGray)),
        ]),
      );
}
