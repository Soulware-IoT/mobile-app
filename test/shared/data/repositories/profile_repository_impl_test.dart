import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cocina360/shared/data/repositories/profile_repository_impl.dart';
import 'package:cocina360/shared/data/services/profile_local_service.dart';
import 'package:cocina360/shared/data/services/profile_service.dart';
import 'package:cocina360/shared/data/services/dto/profile_dto.dart';
import 'package:cocina360/shared/domain/exception/profile_not_found_exception.dart';
import 'package:cocina360/shared/domain/model/profile.dart';
import 'package:cocina360/shared/infrastructure/network/network_checker.dart';

class MockProfileService extends Mock implements ProfileService {}

class MockProfileLocalService extends Mock implements ProfileLocalService {}

class MockNetworkChecker extends Mock implements NetworkChecker {}

class MockProfileDto extends Mock implements ProfileDto {}

void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileService mockRemoteService;
  late MockProfileLocalService mockLocalService;
  late MockNetworkChecker mockNetworkChecker;

  setUpAll(() {
    registerFallbackValue(
      const Profile(id: 'dummy', fullName: 'dummy', email: 'dummy'),
    );
  });

  setUp(() {
    mockRemoteService = MockProfileService();
    mockLocalService = MockProfileLocalService();
    mockNetworkChecker = MockNetworkChecker();

    repository = ProfileRepositoryImpl(
      mockRemoteService,
      mockLocalService,
      mockNetworkChecker,
    );
  });

  group('getCurrentProfile', () {
    const userId = 'user-123';
    const mockProfile = Profile(
      id: userId,
      fullName: 'John Doe',
      email: 'john@doe.com',
    );

    test(
      'retorna el perfil remoto y lo guarda localmente cuando está conectado y la llamada remota tiene éxito',
      () async {
        // Arrange
        final mockDto = MockProfileDto();
        when(() => mockDto.toDomain()).thenReturn(mockProfile);

        when(
          () => mockNetworkChecker.isConnected,
        ).thenAnswer((_) async => true);
        when(
          () => mockLocalService.getById(userId),
        ).thenAnswer((_) async => null);
        when(
          () => mockRemoteService.getProfileById(userId),
        ).thenAnswer((_) async => mockDto);
        when(() => mockLocalService.save(any())).thenAnswer((_) async {});

        // Act
        final result = await repository.getCurrentProfile(userId);

        // Assert
        expect(result, mockProfile);
        verify(() => mockRemoteService.getProfileById(userId)).called(1);
        verify(() => mockLocalService.save(mockProfile)).called(1);
      },
    );

    test(
      'retorna el perfil local cuando está conectado pero la llamada remota falla',
      () async {
        // Arrange
        when(
          () => mockNetworkChecker.isConnected,
        ).thenAnswer((_) async => true);
        when(
          () => mockLocalService.getById(userId),
        ).thenAnswer((_) async => mockProfile);
        when(
          () => mockRemoteService.getProfileById(userId),
        ).thenThrow(Exception('Network Error'));

        // Act
        final result = await repository.getCurrentProfile(userId);

        // Assert
        expect(result, mockProfile);
        verify(() => mockRemoteService.getProfileById(userId)).called(1);
        verifyNever(() => mockLocalService.save(any()));
      },
    );

    test(
      'retorna el perfil local cuando está conectado pero la llamada remota retorna nulo',
      () async {
        // Arrange
        when(
          () => mockNetworkChecker.isConnected,
        ).thenAnswer((_) async => true);
        when(
          () => mockLocalService.getById(userId),
        ).thenAnswer((_) async => mockProfile);
        when(
          () => mockRemoteService.getProfileById(userId),
        ).thenAnswer((_) async => null);

        // Act
        final result = await repository.getCurrentProfile(userId);

        // Assert
        expect(result, mockProfile);
        verify(() => mockRemoteService.getProfileById(userId)).called(1);
        verifyNever(() => mockLocalService.save(any()));
      },
    );

    test('retorna el perfil local cuando está desconectado', () async {
      // Arrange
      when(() => mockNetworkChecker.isConnected).thenAnswer((_) async => false);
      when(
        () => mockLocalService.getById(userId),
      ).thenAnswer((_) async => mockProfile);

      // Act
      final result = await repository.getCurrentProfile(userId);

      // Assert
      expect(result, mockProfile);
      verifyNever(() => mockRemoteService.getProfileById(any()));
    });

    test(
      'lanza ProfileNotFoundException cuando está desconectado y no hay perfil local',
      () async {
        // Arrange
        when(
          () => mockNetworkChecker.isConnected,
        ).thenAnswer((_) async => false);
        when(
          () => mockLocalService.getById(userId),
        ).thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => repository.getCurrentProfile(userId),
          throwsA(isA<ProfileNotFoundException>()),
        );
      },
    );

    test(
      'lanza ProfileNotFoundException cuando está conectado, la llamada remota falla y no hay perfil local',
      () async {
        // Arrange
        when(
          () => mockNetworkChecker.isConnected,
        ).thenAnswer((_) async => true);
        when(
          () => mockLocalService.getById(userId),
        ).thenAnswer((_) async => null);
        when(
          () => mockRemoteService.getProfileById(userId),
        ).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.getCurrentProfile(userId),
          throwsA(isA<ProfileNotFoundException>()),
        );
      },
    );
  });
}
