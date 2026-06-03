import 'package:flutter/material.dart';
import '../models/video_info.dart';
import '../services/downloader_service.dart';
import '../services/file_download_service.dart';
import '../services/hive_service.dart';
import '../theme/app_colors.dart';
import '../widgets/insta_logo.dart';
import 'downloads_screen.dart';

enum _Phase { fetching, ready, downloading, done, error }

class DownloadProgressScreen extends StatefulWidget {
  final String url;
  const DownloadProgressScreen({super.key, required this.url});
  @override
  State<DownloadProgressScreen> createState() =>
      _DownloadProgressScreenState();
}

class _DownloadProgressScreenState
    extends State<DownloadProgressScreen> {
  final _api   = DownloaderService();
  final _dl    = FileDownloadService();
  final _hive  = HiveService();

  _Phase       _phase    = _Phase.fetching;
  VideoInfo?   _info;
  MediaOption? _sel;
  double       _progress = 0;
  String       _error    = '';

  @override
  void initState() { super.initState(); _fetch(); }
  @override
  void dispose()   { _dl.cancel(); super.dispose(); }

  Future<void> _fetch() async {
    setState(() => _phase = _Phase.fetching);
    try {
      final info = await _api.getVideoInfo(widget.url);
      if (!mounted) return;
      setState(() { _info = info; _sel = info.defaultOption; _phase = _Phase.ready; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _phase = _Phase.error; });
    }
  }

  Future<void> _startDownload() async {
    if (_sel == null || _info == null) return;
    setState(() { _phase = _Phase.downloading; _progress = 0; });
    try {
      final fname = _dl.buildFilename(_info!.title, _platform, _sel!.extension);
      final path  = await _dl.downloadVideo(
        url:        _sel!.url,
        filename:   fname,
        onProgress: (rx, total) {
          if (!mounted || total <= 0) return;
          setState(() => _progress = rx / total);
        },
      );
      await _hive.save(
        id:           DateTime.now().millisecondsSinceEpoch.toString(),
        title:        _info!.title.isEmpty ? _platform : _info!.title,
        source:       _platform,
        date:         _today,
        thumbnailUrl: _info!.thumbnailUrl,
        filePath:     path,
      );
      if (!mounted) return;
      setState(() => _phase = _Phase.done);
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _phase = _Phase.error; });
    }
  }

  String get _platform {
    final u = widget.url.toLowerCase();
    if (u.contains('instagram') || u.contains('instagr.am')) return 'Instagram';
    if (u.contains('tiktok'))                                 return 'TikTok';
    if (u.contains('youtube')   || u.contains('youtu.be'))   return 'YouTube';
    if (u.contains('facebook')  || u.contains('fb.watch'))   return 'Facebook';
    if (u.contains('twitter')   || u.contains('x.com'))      return 'Twitter/X';
    if (u.contains('pinterest'))                              return 'Pinterest';
    return 'Video';
  }

  String get _today {
    final n = DateTime.now();
    return '${n.day}-${n.month}-${(n.year % 100).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PeachBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NavBar(platform: _platform,
                  onBookmark: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const DownloadsScreen()))),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _body(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    switch (_phase) {
      case _Phase.fetching:
        return _FetchingView(platform: _platform);
      case _Phase.ready:
        return _ReadyView(
          info: _info!, platform: _platform, url: widget.url,
          selected: _sel,
          onSelect: (o) => setState(() => _sel = o),
          onDownload: _startDownload,
        );
      case _Phase.downloading:
        return _DownloadingView(
            info: _info!, platform: _platform, url: widget.url, progress: _progress);
      case _Phase.done:
        return _DoneView(
          onView: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const DownloadsScreen())),
        );
      case _Phase.error:
        return _ErrorView(message: _error, onRetry: _fetch);
    }
  }
}

// ─── Nav bar ──────────────────────────────────────────────────────────────────
class _NavBar extends StatelessWidget {
  final String platform;
  final VoidCallback onBookmark;
  const _NavBar({required this.platform, required this.onBookmark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back,
                color: AppColors.textDark, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.bookmark,
                color: AppColors.primaryDark, size: 26),
            onPressed: onBookmark,
          ),
        ],
      ),
    );
  }
}

// ─── Phase views ─────────────────────────────────────────────────────────────
class _FetchingView extends StatelessWidget {
  final String platform;
  const _FetchingView({required this.platform});
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 360,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Fetching video info…',
                style: TextStyle(fontSize: 14, color: AppColors.textGray)),
          ]),
        ),
      );
}

class _ReadyView extends StatelessWidget {
  final VideoInfo info;
  final String platform, url;
  final MediaOption? selected;
  final ValueChanged<MediaOption> onSelect;
  final VoidCallback onDownload;
  const _ReadyView({
    required this.info, required this.platform, required this.url,
    required this.selected, required this.onSelect, required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(platform,
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
      const SizedBox(height: 14),
      _UrlChip(url: url),
      const SizedBox(height: 18),
      _Thumb(url: info.thumbnailUrl),
      const SizedBox(height: 14),
      if (info.title.isNotEmpty)
        Text(info.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
      const SizedBox(height: 16),
      if (info.hasOptions) ...[
        const Text('Select quality',
            style: TextStyle(fontSize: 13, color: AppColors.textGray)),
        const SizedBox(height: 8),
        _QualityPicker(options: info.mediaOptions, selected: selected, onSelect: onSelect),
        const SizedBox(height: 20),
      ],
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: onDownload,
          icon: const Icon(Icons.download_rounded),
          label: const Text('Download',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
      const SizedBox(height: 24),
    ]);
  }
}

class _DownloadingView extends StatelessWidget {
  final VideoInfo info;
  final String platform, url;
  final double progress;
  const _DownloadingView({
    required this.info, required this.platform,
    required this.url, required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(platform,
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
      const SizedBox(height: 14),
      _UrlChip(url: url),
      const SizedBox(height: 18),
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(alignment: Alignment.center, children: [
          _Thumb(url: info.thumbnailUrl),
          Container(width: double.infinity, height: 220, color: AppColors.overlayDark),
          SizedBox(
            width: 76, height: 76,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                value: progress, strokeWidth: 4.5,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
              Text('${(progress * 100).toInt()}%',
                  style: const TextStyle(
                      color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.black12,
          color: AppColors.primary,
          minHeight: 4,
        ),
      ),
      const SizedBox(height: 8),
      Text('Downloading… ${(progress * 100).toInt()}%',
          style: const TextStyle(fontSize: 13, color: AppColors.textGray)),
    ]);
  }
}

class _DoneView extends StatelessWidget {
  final VoidCallback onView;
  const _DoneView({required this.onView});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded,
                color: AppColors.white, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Download complete!',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text('Saved to Your Downloads',
              style: TextStyle(fontSize: 13, color: AppColors.textGray)),
          const SizedBox(height: 28),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onView,
            child: const Text('View Downloads', style: TextStyle(fontSize: 15)),
          ),
        ]),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text('Something went wrong',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textGray, height: 1.5)),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
            ),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ]),
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────
class _UrlChip extends StatelessWidget {
  final String url;
  const _UrlChip({required this.url});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
        ),
        child: Text(url,
            overflow: TextOverflow.ellipsis, maxLines: 1,
            style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
      );
}

class _Thumb extends StatelessWidget {
  final String url;
  const _Thumb({required this.url});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: url.isNotEmpty
            ? Image.network(url,
                width: double.infinity, height: 220, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PlaceholderBox())
            : _PlaceholderBox(),
      );
}

class _PlaceholderBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity, height: 220,
        color: const Color(0xFF263550),
        child: const Center(
            child: Icon(Icons.image_outlined, color: Colors.white38, size: 48)),
      );
}

class _QualityPicker extends StatelessWidget {
  final List<MediaOption> options;
  final MediaOption? selected;
  final ValueChanged<MediaOption> onSelect;
  const _QualityPicker(
      {required this.options, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: options.map((opt) {
        final on = opt == selected;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: on ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: on ? AppColors.primary : AppColors.divider),
            ),
            child: Text(opt.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: on ? FontWeight.w600 : FontWeight.normal,
                  color: on ? AppColors.white : AppColors.textDark,
                )),
          ),
        );
      }).toList(),
    );
  }
}
