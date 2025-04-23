import 'package:get/get.dart';
import 'package:incident_report_app/core/services/api_service.dart';
import 'package:incident_report_app/core/models/incident_model.dart';

class IncidentService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<Incident>> getIncidents() async {
    try {
      final response = await _apiService.get('/incidents/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Incident.fromJson(json)).toList();
      }
      throw Exception('Failed to load incidents: ${response.statusCode}');
    } catch (e) {
      print('Error in getIncidents: $e');
      rethrow;
    }
  }

  Future<Incident> createIncident(Incident incident) async {
    try {
      final response = await _apiService.post('/incidents/', incident.toJson());
      if (response.statusCode == 201) {
        return Incident.fromJson(response.data);
      }
      throw Exception('Failed to create incident: ${response.statusCode}');
    } catch (e) {
      print('Error in createIncident: $e');
      rethrow;
    }
  }

  Future<Incident> updateIncident(Incident incident) async {
    try {
      final response = await _apiService.put(
        '/incidents/${incident.id}/',
        incident.toJson(),
      );
      if (response.statusCode == 200) {
        return Incident.fromJson(response.data);
      }
      throw Exception('Failed to update incident: ${response.statusCode}');
    } catch (e) {
      print('Error in updateIncident: $e');
      rethrow;
    }
  }

  Future<void> deleteIncident(int id) async {
    try {
      final response = await _apiService.delete('/incidents/$id/');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete incident: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in deleteIncident: $e');
      rethrow;
    }
  }

  Future<List<Incident>> filterIncidents({
    String? status,
    String? priority,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      if (status != null) queryParams['status'] = status;
      if (priority != null) queryParams['priority'] = priority;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _apiService.get('/incidents/', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Incident.fromJson(json)).toList();
      }
      throw Exception('Failed to filter incidents: ${response.statusCode}');
    } catch (e) {
      print('Error in filterIncidents: $e');
      rethrow;
    }
  }
} 