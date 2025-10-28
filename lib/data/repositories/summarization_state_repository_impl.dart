import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/summarization_state.dart';
import '../../domain/repositories/summarization_state_repository.dart';
import '../datasources/local/realm_datasource.dart';
import '../models/realm_models.dart';

class SummarizationStateRepositoryImpl implements SummarizationStateRepository {
  final RealmDataSource _realmDataSource;

  SummarizationStateRepositoryImpl({
    required RealmDataSource realmDataSource,
  }) : _realmDataSource = realmDataSource;

  @override
  Future<Either<Failure, SummarizationState?>> getSummarizationState(String recordingId) async {
    try {
      final realm = _realmDataSource.realm;
      final stateRealm = realm.find<SummarizationStateRealm>(recordingId);
      
      if (stateRealm == null) {
        return const Right(null);
      }
      
      return Right(stateRealm.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get summarization state: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSummarizationState(SummarizationState state) async {
    try {
      final realm = _realmDataSource.realm;
      final stateRealm = SummarizationStateRealmExtension.fromEntity(state);
      
      realm.write(() {
        realm.add(stateRealm, update: true);
      });
      
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save summarization state: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSummarizationState(String recordingId) async {
    try {
      final realm = _realmDataSource.realm;
      final stateRealm = realm.find<SummarizationStateRealm>(recordingId);
      
      if (stateRealm != null) {
        realm.write(() {
          realm.delete(stateRealm);
        });
      }
      
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete summarization state: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SummarizationState>>> getPendingStates() async {
    try {
      final realm = _realmDataSource.realm;
      final states = realm.query<SummarizationStateRealm>('status == "pending"');
      
      return Right(states.map((state) => state.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get pending states: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SummarizationState>>> getFailedStates() async {
    try {
      final realm = _realmDataSource.realm;
      final states = realm.query<SummarizationStateRealm>('status == "failed"');
      
      return Right(states.map((state) => state.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get failed states: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SummarizationState>>> getCompletedStates() async {
    try {
      final realm = _realmDataSource.realm;
      final states = realm.query<SummarizationStateRealm>('status == "completed"');
      
      return Right(states.map((state) => state.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get completed states: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SummarizationState>>> getStatesByStatus(SummarizationStatus status) async {
    try {
      final realm = _realmDataSource.realm;
      final states = realm.query<SummarizationStateRealm>('status == "${status.name}"');
      
      return Right(states.map((state) => state.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get states by status: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateStatus(String recordingId, SummarizationStatus status) async {
    try {
      final realm = _realmDataSource.realm;
      final stateRealm = realm.find<SummarizationStateRealm>(recordingId);
      
      if (stateRealm != null) {
        realm.write(() {
          stateRealm.summarizationStatus = status;
          stateRealm.updatedAt = DateTime.now();
        });
      }
      
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update status: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementRetryAttempts(String recordingId) async {
    try {
      final realm = _realmDataSource.realm;
      final stateRealm = realm.find<SummarizationStateRealm>(recordingId);
      
      if (stateRealm != null) {
        realm.write(() {
          stateRealm.retryAttempts++;
          stateRealm.lastAttempt = DateTime.now();
          stateRealm.updatedAt = DateTime.now();
        });
      }
      
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to increment retry attempts: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllStates() async {
    try {
      final realm = _realmDataSource.realm;
      final states = realm.all<SummarizationStateRealm>();
      
      realm.write(() {
        realm.deleteMany(states);
      });
      
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to clear all states: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getStatistics() async {
    try {
      final realm = _realmDataSource.realm;
      final allStates = realm.all<SummarizationStateRealm>();
      
      final stats = <String, int>{
        'total': allStates.length,
        'pending': 0,
        'generating': 0,
        'completed': 0,
        'failed': 0,
      };
      
      for (final state in allStates) {
        stats[state.status] = (stats[state.status] ?? 0) + 1;
      }
      
      return Right(stats);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get statistics: $e'));
    }
  }
}
