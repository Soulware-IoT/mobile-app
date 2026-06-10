import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tcompro/shared/data/repositories/auth_repository_impl.dart';
import 'package:tcompro/shared/data/services/auth_local_service.dart';
import 'package:tcompro/shared/data/services/auth_remote_service.dart';
import 'package:tcompro/shared/domain/model/auth_session.dart';
import 'package:tcompro/shared/infrastructure/network/network_checker.dart';

class MockAuthRemoteService extends Mock implements AuthRemoteService {}
class MockAuthLocalService extends Mock implements AuthLocalService {}
class MockNetworkChecker extends Mock implements NetworkChecker {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockSession extends Mock implements Session {}
class MockUser extends Mock implements User {}

void main() {
  late AuthRepositoryImpl authRepository;
  late MockAuthRemoteService mockRemoteService;
  late MockAuthLocalService mockLocalService;
  late MockNetworkChecker mockNetworkChecker;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;

  setUp(() {
    mockRemoteService = MockAuthRemoteService();
    mockLocalService = MockAuthLocalService();
    mockNetworkChecker = MockNetworkChecker();
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();

    when(() => mockRemoteService.supabase).thenReturn(mockSupabaseClient);
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);

    authRepository = AuthRepositoryImpl(
      mockRemoteService,
      mockLocalService,
      mockNetworkChecker,
    );
  });

  group('currentSession', () {
    test('retorna ActiveSession y cachea el id de usuario cuando existe una sesión remota', () async {
      // Arrange
      final mockSession = MockSession();
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockSession.user).thenReturn(mockUser);
      when(() => mockGoTrueClient.currentSession).thenReturn(mockSession);
      when(() => mockLocalService.cacheUserId('user-123')).thenAnswer((_) async {});

      // Act
      final result = await authRepository.currentSession();

      // Assert
      expect(result, isA<ActiveSession>());
      expect((result as ActiveSession).userId, 'user-123');
      verify(() => mockLocalService.cacheUserId('user-123')).called(1);
    });

    test('retorna OfflineSession cuando no hay sesión remota, existe usuario en caché y el dispositivo está desconectado', () async {
      // Arrange
      when(() => mockGoTrueClient.currentSession).thenReturn(null);
      when(() => mockLocalService.getCachedUserId()).thenAnswer((_) async => 'cached-user-123');
      when(() => mockNetworkChecker.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await authRepository.currentSession();

      // Assert
      expect(result, isA<OfflineSession>());
      expect((result as OfflineSession).userId, 'cached-user-123');
    });

    test('retorna NoSession cuando no hay sesión remota, existe usuario en caché y el dispositivo está conectado', () async {
      // Arrange
      when(() => mockGoTrueClient.currentSession).thenReturn(null);
      when(() => mockLocalService.getCachedUserId()).thenAnswer((_) async => 'cached-user-123');
      when(() => mockNetworkChecker.isConnected).thenAnswer((_) async => true);

      // Act
      final result = await authRepository.currentSession();

      // Assert
      expect(result, isA<NoSession>());
    });

    test('retorna NoSession cuando no hay sesión remota ni usuario en caché', () async {
      // Arrange
      when(() => mockGoTrueClient.currentSession).thenReturn(null);
      when(() => mockLocalService.getCachedUserId()).thenAnswer((_) async => null);

      // Act
      final result = await authRepository.currentSession();

      // Assert
      expect(result, isA<NoSession>());
    });
  });

  group('authStateChanges', () {
    test('emite ActiveSession y cachea el id de usuario cuando la sesión está presente', () async {
      // Arrange
      final mockSession = MockSession();
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockSession.user).thenReturn(mockUser);
      
      final authState = AuthState(AuthChangeEvent.signedIn, mockSession);
      when(() => mockGoTrueClient.onAuthStateChange).thenAnswer((_) => Stream.value(authState));
      when(() => mockLocalService.cacheUserId('user-123')).thenAnswer((_) async {});

      // Act
      final stream = authRepository.authStateChanges;

      // Assert
      await expectLater(
        stream,
        emitsInOrder([
          isA<ActiveSession>().having((s) => s.userId, 'userId', 'user-123'),
        ]),
      );
      verify(() => mockLocalService.cacheUserId('user-123')).called(1);
    });

    test('emite NoSession y limpia el caché en el evento signedOut', () async {
      // Arrange
      final authState = AuthState(AuthChangeEvent.signedOut, null);
      when(() => mockGoTrueClient.onAuthStateChange).thenAnswer((_) => Stream.value(authState));
      when(() => mockLocalService.clearCachedUserId()).thenAnswer((_) async {});

      // Act
      final stream = authRepository.authStateChanges;

      // Assert
      await expectLater(
        stream,
        emitsInOrder([
          isA<NoSession>(),
        ]),
      );
      verify(() => mockLocalService.clearCachedUserId()).called(1);
    });
  });

  group('Métodos de autenticación', () {
    test('login delega a remoteService.regularLogin', () async {
      // Arrange
      when(() => mockRemoteService.regularLogin(email: 'test@test.com', password: 'password'))
          .thenAnswer((_) async => AuthResponse(session: null, user: null));

      // Act
      await authRepository.login(email: 'test@test.com', password: 'password');

      // Assert
      verify(() => mockRemoteService.regularLogin(email: 'test@test.com', password: 'password')).called(1);
    });

    test('logout delega a remoteService y limpia el caché local', () async {
      // Arrange
      when(() => mockLocalService.clearCachedUserId()).thenAnswer((_) async {});
      when(() => mockRemoteService.logout()).thenAnswer((_) async {});

      // Act
      await authRepository.logout();

      // Assert
      verify(() => mockLocalService.clearCachedUserId()).called(1);
      verify(() => mockRemoteService.logout()).called(1);
    });
  });
}
