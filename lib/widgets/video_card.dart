import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shimmer/shimmer.dart';

class VideoCard extends StatelessWidget {
  final String thumbnailUrl;
  final String name;
  final String nickname;
  final List<String> techInterests;
  final DateTime uploadedAt;
  final VoidCallback onTap;

  const VideoCard({
    super.key,
    required this.thumbnailUrl,
    required this.name,
    required this.nickname,
    required this.techInterests,
    required this.uploadedAt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Hero(
                tag: thumbnailUrl,
                child: thumbnailUrl.isNotEmpty
                    ? Image.network(thumbnailUrl, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey,
                        child: const Icon(Icons.videocam, size: 50, color: Colors.white),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleSmall),
                  Text('@$nickname', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  if (techInterests.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: techInterests
                          .take(2)
                          .map((t) => Chip(
                                label: Text(t, style: const TextStyle(fontSize: 10)),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 4),
                  Text(timeago.format(uploadedAt),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoCardShimmer extends StatelessWidget {
  const VideoCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 4),
                  Container(height: 12, width: 80, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 50, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
