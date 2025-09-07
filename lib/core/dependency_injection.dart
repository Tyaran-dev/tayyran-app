// lib/core/dependency_injection.dart
import 'package:get_it/get_it.dart';
import 'package:tayyran_app/core/network/api_endpoints.dart';
import 'package:tayyran_app/core/network/dio_client.dart';
import 'package:tayyran_app/core/services/app_service.dart';
import 'package:tayyran_app/data/api/airport_api_service.dart';
import 'package:tayyran_app/data/repositories/airport_repository.dart';
import 'package:tayyran_app/presentation/airport_search/cubit/airport_search_cubit.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Replace with your actual API base URL
  final dioClient = DioClient(baseUrl: ApiEndpoints.baseUrl);
  getIt.registerLazySingleton(() => AppService());

  // Create API services with context
  final airportApiService = AirportApiService(dioClient);

  // Create repositories
  final airportRepository = AirportRepository(airportApiService);

  // Register providers
  getIt.registerLazySingleton(() => dioClient);
  getIt.registerLazySingleton(() => airportApiService);
  getIt.registerLazySingleton(() => airportRepository);
  getIt.registerFactory(() => AirportSearchCubit(getIt<AirportRepository>()));
}
