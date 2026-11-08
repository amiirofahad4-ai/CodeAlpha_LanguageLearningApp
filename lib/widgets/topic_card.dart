import 'package:flutter/material.dart';

import '../core/utils/context_ext.dart';
import '../models/topic.dart';
import 'app_card.dart';
import 'app_progress_bar.dart';

/// A vocabulary topic tile with icon, name and % completed.
///
/// Use [compact] for the horizontal "Continue learning" list.
class TopicCard extends StatelessWidget {
  const TopicCard({
    super.key,
    required this.topic,
    required this.progress,
    this.onTap,
    this.compact = false,
  });

  final Topic topic;

  /// 0.0 – 1.0
  final double progress;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(compact ? 14 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 40 : 48,
                height: compact ? 40 : 48,
                decoration: BoxDecoration(
                  color: topic.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  topic.icon,
                  color: topic.color,
                  size: compact ? 22 : 26,
                ),
              ),
              const Spacer(),
              if (percent == 100)
                Icon(Icons.verified_rounded, color: topic.color, size: 22),
            ],
          ),
          SizedBox(height: compact ? 10 : 14),
          Text(
            topic.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            topic.somaliTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: compact ? 10 : 14),
          AppProgressBar(value: progress, color: topic.color, height: 8),
          const SizedBox(height: 6),
          Text(
            '$percent% · ${topic.wordCount} words',
            style: context.text.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
