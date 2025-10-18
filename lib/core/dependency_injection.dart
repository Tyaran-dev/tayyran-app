// lib/core/dependency_injection.dart - UPDATED
import 'package:get_it/get_it.dart';
import 'package:tayyran_app/core/network/api_endpoints.dart';
import 'package:tayyran_app/core/network/dio_client.dart';
import 'package:tayyran_app/data/api/airport_api_service.dart';
import 'package:tayyran_app/data/api/flight_pricing_api_service.dart';
import 'package:tayyran_app/data/api/flight_search_api_service.dart';
import 'package:tayyran_app/data/api/payment_api_service.dart';
import 'package:tayyran_app/data/repositories/airport_repository.dart';
import 'package:tayyran_app/data/repositories/flight_pricing_repository.dart';
import 'package:tayyran_app/data/repositories/flight_search_repository.dart';
import 'package:tayyran_app/data/repositories/payment_repository.dart';
import 'package:tayyran_app/presentation/airport_search/cubit/airport_search_cubit.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_cubit.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // 1. Register DioClient first as LazySingleton (not Singleton)
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(baseUrl: ApiEndpoints.baseUrl),
  );

  // 2. Register API Services
  getIt.registerLazySingleton(() => AirportApiService(getIt<DioClient>()));
  getIt.registerLazySingleton(() => FlightSearchApiService(getIt<DioClient>()));
  getIt.registerLazySingleton(
    () => FlightPricingApiService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton(() => PaymentApiService(getIt<DioClient>()));

  // 3. Register Repositories
  getIt.registerLazySingleton(
    () => AirportRepository(getIt<AirportApiService>()),
  );
  getIt.registerLazySingleton(
    () => FlightSearchRepository(getIt<FlightSearchApiService>()),
  );
  getIt.registerLazySingleton(
    () => FlightPricingRepository(getIt<FlightPricingApiService>()),
  );
  getIt.registerLazySingleton(
    () => PaymentRepository(getIt<PaymentApiService>()),
  );

  // 4. Register Cubits/Blocs
  getIt.registerFactory(() => AirportSearchCubit(getIt<AirportRepository>()));
  getIt.registerFactory(
    () => FlightSearchCubit(getIt<FlightSearchRepository>()),
  );
}

// Helper method to update DioClient language from anywhere
void updateDioClientLanguage(String languageCode) {
  try {
    final dioClient = getIt<DioClient>();
    dioClient.setLanguage(languageCode);
  } catch (e) {
    print('Error updating DioClient language: $e');
  }
}
