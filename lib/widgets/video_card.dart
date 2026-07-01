import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

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
                    : const Container(
                        color: Colors.grey,
                        child: Icon(Icons.videocam, size: 50, color: Colors.white),
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
