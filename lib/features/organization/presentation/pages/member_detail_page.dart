import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cocina360/features/organization/domain/model/member_role.dart';
import 'package:cocina360/features/organization/domain/model/organization_member.dart';
import 'package:cocina360/features/organization/presentation/widgets/member_role_badge.dart';
import 'package:cocina360/shared/presentation/router/app_router.dart';
import 'package:cocina360/shared/presentation/theme/theme.dart';

class MemberDetailPage extends StatefulWidget {
  final OrganizationMember member;

  const MemberDetailPage({super.key, required this.member});

  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  late OrganizationMember _member;

  @override
  void initState() {
    super.initState();
    _member = widget.member;
  }

  Future<void> _editPermissions() async {
    final updated = await context.push<OrganizationMember>(
      AppRoutes.editMemberPermissions,
      extra: _member,
    );
    if (updated != null && mounted) {
      setState(() => _member = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Member Details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Center(child: _Avatar(member: _member)),
          const SizedBox(height: 16),
          Text(
            _member.fullName,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _member.email,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _editPermissions,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit Permissions'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.seedColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.apartment_outlined, size: 18),
            label: const Text('Back to Organization'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'PERMISOS DE ACCESO',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _PermissionCard(
            icon: Icons.shield_outlined,
            label: 'Seguridad',
            role: _member.security,
          ),
          const SizedBox(height: 12),
          _PermissionCard(
            icon: Icons.sensors,
            label: 'Organizaciones',
            role: _member.organization,
          ),
          const SizedBox(height: 12),
          _PermissionCard(
            icon: Icons.checklist_outlined,
            label: 'Control interno',
            role: _member.internalControl,
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final OrganizationMember member;

  const _Avatar({required this.member});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = member.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(radius: 44, backgroundImage: NetworkImage(avatarUrl));
    }
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: const Color(0xFFE7ECF5),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        member.initials,
        style: const TextStyle(
          color: Color(0xFF0E3B63),
          fontWeight: FontWeight.w700,
          fontSize: 28,
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final MemberRole role;

  const _PermissionCard({
    required this.icon,
    required this.label,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE7ECF5),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: const Color(0xFF0E3B63)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            MemberRoleBadge(role: role),
          ],
        ),
      ),
    );
  }
}
