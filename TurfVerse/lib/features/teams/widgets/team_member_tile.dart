import 'package:flutter/material.dart';
import 'package:turfverse/core/constants/app_colors.dart';
import 'package:turfverse/features/player/models/player_profile.dart';
import 'package:turfverse/features/teams/models/team_member.dart';

class TeamMemberTile extends StatelessWidget {
  const TeamMemberTile({required this.member, super.key});

  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    final isCaptain = member.memberRole == 'captain';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.accent,
        child: Text(member.fullName.isEmpty ? '?' : member.fullName[0]),
      ),
      title: Text(
        member.fullName,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${formatProfileValue(member.playerRole)} • '
        '${formatProfileValue(member.skillLevel)}',
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: (isCaptain ? AppColors.accent : AppColors.primary).withValues(
            alpha: 0.14,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          formatProfileValue(member.memberRole),
          style: TextStyle(
            color: isCaptain ? AppColors.accent : AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
