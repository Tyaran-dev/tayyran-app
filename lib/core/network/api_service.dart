// // lib/core/network/api_service.dart
// import 'dio_client.dart';

// class ApiService {
//   final DioClient _dioClient;

//   ApiService(this._dioClient);

//   // User endpoints
//   Future<dynamic> getUsers() async {
//     return await _dioClient.get('/users');
//   }

//   Future<dynamic> getUserById(int id) async {
//     return await _dioClient.get('/users/$id');
//   }

//   Future<dynamic> createUser(Map<String, dynamic> userData) async {
//     return await _dioClient.post('/users', data: userData);
//   }

//   Future<dynamic> updateUser(int id, Map<String, dynamic> userData) async {
//     return await _dioClient.put('/users/$id', data: userData);
//   }

//   Future<dynamic> deleteUser(int id) async {
//     return await _dioClient.delete('/users/$id');
//   }

//   // Add more API methods as needed
// }
