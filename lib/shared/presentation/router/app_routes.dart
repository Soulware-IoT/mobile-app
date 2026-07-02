part of 'app_router.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const register = '/register';
  static const editOrganization = '/organizations/edit';
  static const memberDetail = '/organizations/members/detail';
  static const editMemberPermissions = '/organizations/members/permissions';
  static const myInvitations = '/invitations';
  static const deviceDetail = '/devices/detail';
  static const newRegistry = '/processes/registries/new';
}
