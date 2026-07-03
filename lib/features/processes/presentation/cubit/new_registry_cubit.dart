import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/processes/domain/repositories/internal_control_repository.dart';
import 'package:cocina360/features/processes/presentation/cubit/new_registry_state.dart';

/// Files a new registry (a filled control format).
class NewRegistryCubit extends Cubit<NewRegistryState> {
  final InternalControlRepository repository;

  NewRegistryCubit(this.repository) : super(const NewRegistryIdle());

  Future<void> submit(String formatId, Map<String, Object?> data) async {
    emit(const NewRegistrySubmitting());
    try {
      final registry = await repository.createRegistry(formatId, data);
      emit(NewRegistrySuccess(registry));
    } catch (e) {
      emit(NewRegistryFailure(e));
    }
  }
}
