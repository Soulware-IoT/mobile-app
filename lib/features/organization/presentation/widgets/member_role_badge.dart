import 'package:flutter/material.dart';
import 'package:cocina360/features/organization/domain/model/member_role.dart';

/// Pill badge showing a member's role, color-coded like the mockup
/// (crimson LIEUTENANT, light-navy ASSIGNEE).
class MemberRoleBadge extends StatelessWidget {
  final MemberRole role;

  const MemberRoleBadge({super.key, required this.role});

  ({Color background, Color foreground}) _colors() {
    return switch (role) {
      MemberRole.admin => (
        background: const Color(0xFF0E3B63),
        foreground: Colors.white,
      ),
      MemberRole.lieutenant => (
        background: const Color(0xFFD61F4E),
        foreground: Colors.white,
      ),
      MemberRole.assignee => (
        background: const Color(0xFFE7ECF5),
        foreground: const Color(0xFF0E3B63),
      ),
      MemberRole.none => (
        background: const Color(0xFFEEEEEE),
        foreground: const Color(0xFF6B7280),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.label,
        style: TextStyle(
          color: colors.foreground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
