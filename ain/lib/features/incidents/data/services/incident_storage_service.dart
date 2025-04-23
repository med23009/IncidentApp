import 'package:get_storage/get_storage.dart';
import 'package:incident_report_app/core/models/incident_model.dart';

class IncidentStorageService {
  final GetStorage _storage = GetStorage();
  final String _incidentsKey = 'incidents';
  final String _pendingIncidentsKey = 'pending_incidents';

  Future<List<Incident>> getIncidents() async {
    try {
      final incidentsJson = _storage.read<List<dynamic>>(_incidentsKey) ?? [];
      return incidentsJson.map((json) => Incident.fromJson(json)).toList();
    } catch (e) {
      print('Error getting incidents from storage: $e');
      return [];
    }
  }

  Future<void> saveIncidents(List<Incident> incidents) async {
    try {
      final incidentsJson = incidents.map((incident) => incident.toJson()).toList();
      await _storage.write(_incidentsKey, incidentsJson);
    } catch (e) {
      print('Error saving incidents to storage: $e');
    }
  }

  Future<List<Incident>> getPendingIncidents() async {
    try {
      final pendingIncidentsJson = _storage.read<List<dynamic>>(_pendingIncidentsKey) ?? [];
      return pendingIncidentsJson.map((json) => Incident.fromJson(json)).toList();
    } catch (e) {
      print('Error getting pending incidents from storage: $e');
      return [];
    }
  }

  Future<void> savePendingIncident(Incident incident) async {
    try {
      final pendingIncidents = await getPendingIncidents();
      pendingIncidents.add(incident);
      final pendingIncidentsJson = pendingIncidents.map((incident) => incident.toJson()).toList();
      await _storage.write(_pendingIncidentsKey, pendingIncidentsJson);
    } catch (e) {
      print('Error saving pending incident to storage: $e');
    }
  }

  Future<void> removePendingIncident(int incidentId) async {
    try {
      final pendingIncidents = await getPendingIncidents();
      pendingIncidents.removeWhere((incident) => incident.id == incidentId);
      final pendingIncidentsJson = pendingIncidents.map((incident) => incident.toJson()).toList();
      await _storage.write(_pendingIncidentsKey, pendingIncidentsJson);
    } catch (e) {
      print('Error removing pending incident from storage: $e');
    }
  }

  Future<void> clearStorage() async {
    try {
      await _storage.remove(_incidentsKey);
      await _storage.remove(_pendingIncidentsKey);
    } catch (e) {
      print('Error clearing storage: $e');
    }
  }
} 