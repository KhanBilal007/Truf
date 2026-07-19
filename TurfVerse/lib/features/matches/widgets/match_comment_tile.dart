import 'package:flutter/material.dart';
import 'package:turfverse/core/constants/app_colors.dart';
import 'package:turfverse/features/matches/models/match_comment.dart';
import 'package:turfverse/features/turf/models/turf_slot.dart';

class MatchCommentTile extends StatelessWidget {
  const MatchCommentTile({required this.comment, super.key});

  final MatchComment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.accent,
            child: Text(
              comment.playerName.isEmpty ? '?' : comment.playerName[0],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.playerName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      formatTime(
                        '${comment.createdAt.hour.toString().padLeft(2, '0')}:'
                        '${comment.createdAt.minute.toString().padLeft(2, '0')}',
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(comment.comment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
