class MediaOption {
  final String url;
  final String quality;
  final String extension;
  final bool hasAudio;

  const MediaOption({
    required this.url,
    required this.quality,
    required this.extension,
    this.hasAudio = true,
  });

  factory MediaOption.fromJson(Map<String, dynamic> j) => MediaOption(
        url:       (j['url']        as String?)?.trim() ?? '',
        quality:   (j['quality']    as String?)?.trim() ??
                   (j['resolution'] as String?)?.trim() ?? 'Standard',
        extension: (j['extension']  as String?)?.trim() ?? 'mp4',
        hasAudio:  j['hasAudio'] as bool? ?? true,
      );

  String get label {
    if (quality.toLowerCase() == 'audio') return 'Audio only';
    return quality.isEmpty ? extension.toUpperCase() : quality;
  }

  bool get isAudioOnly =>
      extension == 'mp3' || quality.toLowerCase() == 'audio';
}

class VideoInfo {
  final String title;
  final String thumbnailUrl;
  final List<MediaOption> mediaOptions;

  const VideoInfo({
    required this.title,
    required this.thumbnailUrl,
    required this.mediaOptions,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> j) {
    final thumb = (j['picture']   as String?)?.trim() ??
                  (j['thumbnail'] as String?)?.trim() ?? '';
    final options = ((j['medias'] as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map(MediaOption.fromJson)
        .where((m) => m.url.isNotEmpty)
        .toList();
    return VideoInfo(
      title:        (j['title'] as String?)?.trim() ?? 'Downloaded Video',
      thumbnailUrl: thumb,
      mediaOptions: options,
    );
  }

  bool get hasOptions => mediaOptions.isNotEmpty;

  MediaOption? get defaultOption => mediaOptions.isNotEmpty
      ? mediaOptions.firstWhere((m) => !m.isAudioOnly,
          orElse: () => mediaOptions.first)
      : null;
}
