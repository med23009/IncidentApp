import 'package:get/get.dart';
import 'package:incident_report_app/core/models/incident_model.dart';
import 'package:incident_report_app/features/incidents/data/services/incident_storage_service.dart';
import 'package:incident_report_app/features/incidents/data/services/incident_service.dart';

class IncidentController extends GetxController {
  final IncidentService _incidentService = Get.find<IncidentService>();
  final IncidentStorageService _storageService = IncidentStorageService();
  
  final RxList<Incident> incidents = <Incident>[].obs;
  final RxList<Incident> pendingIncidents = <Incident>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString errorMessage = ''.obs;
  final selectedIncident = Rxn<Incident>();

  @override
  void onInit() {
    super.onInit();
    loadIncidents();
  }

  Future<void> loadIncidents() async {
    try {
      isLoading.value = true;
      error.value = '';
      errorMessage.value = '';
      
      // Charger les incidents du stockage local
      final localIncidents = await _storageService.getIncidents();
      incidents.assignAll(localIncidents);
      
      // Charger les incidents en attente
      final pending = await _storageService.getPendingIncidents();
      pendingIncidents.assignAll(pending);
      
      // Tenter de synchroniser avec le backend
      await syncPendingIncidents();
      
    } catch (e) {
      error.value = 'Erreur lors du chargement des incidents: $e';
      errorMessage.value = error.value;
    } finally {
      isLoading.value = false;
    }
  }

  // Alias pour loadIncidents pour la compatibilité avec l'interface existante
  Future<void> fetchIncidents() async {
    await loadIncidents();
  }

  Future<void> syncPendingIncidents() async {
    if (pendingIncidents.isEmpty) return;
    
    try {
      for (final incident in pendingIncidents) {
        await _incidentService.createIncident(incident);
        await _storageService.removePendingIncident(incident.id!);
      }
      
      // Recharger les incidents après la synchronisation
      await loadIncidents();
      
    } catch (e) {
      error.value = 'Erreur lors de la synchronisation: $e';
      errorMessage.value = error.value;
    }
  }

  Future<bool> createIncident(Incident incident) async {
    try {
      isLoading.value = true;
      error.value = '';
      errorMessage.value = '';
      
      // Créer une copie de l'incident avec isOffline = true
      final offlineIncident = incident.copyWith(isOffline: true);
      
      // Sauvegarder localement
      await _storageService.savePendingIncident(offlineIncident);
      pendingIncidents.add(offlineIncident);
      
      // Tenter de synchroniser immédiatement
      await syncPendingIncidents();
      
      return true;
    } catch (e) {
      error.value = 'Erreur lors de la création de l\'incident: $e';
      errorMessage.value = error.value;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateIncident(Incident incident) async {
    try {
      isLoading.value = true;
      error.value = '';
      errorMessage.value = '';
      
      if (incident.isOffline) {
        // Mettre à jour dans le stockage local
        final pending = await _storageService.getPendingIncidents();
        final index = pending.indexWhere((i) => i.id == incident.id);
        if (index != -1) {
          pending[index] = incident;
          await _storageService.savePendingIncident(incident);
          return true;
        }
        return false;
      } else {
        // Mettre à jour sur le backend
        await _incidentService.updateIncident(incident);
        await loadIncidents();
        return true;
      }
      
    } catch (e) {
      error.value = 'Erreur lors de la mise à jour de l\'incident: $e';
      errorMessage.value = error.value;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteIncident(int id) async {
    try {
      isLoading.value = true;
      error.value = '';
      errorMessage.value = '';
      
      // Vérifier si l'incident est en attente
      final pendingIndex = pendingIncidents.indexWhere((i) => i.id == id);
      if (pendingIndex != -1) {
        await _storageService.removePendingIncident(id);
        pendingIncidents.removeAt(pendingIndex);
        return true;
      } else {
        // Supprimer du backend
        await _incidentService.deleteIncident(id);
        await loadIncidents();
        return true;
      }
      
    } catch (e) {
      error.value = 'Erreur lors de la suppression de l\'incident: $e';
      errorMessage.value = error.value;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> filterIncidents({
    String? status,
    String? priority,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      errorMessage.value = '';
      
      // Filtrer les incidents via l'API
      final filteredIncidents = await _incidentService.filterIncidents(
        status: status,
        priority: priority,
        startDate: startDate,
        endDate: endDate,
      );
      
      // Mettre à jour la liste des incidents
      incidents.assignAll(filteredIncidents);
      
    } catch (e) {
      error.value = 'Erreur lors du filtrage des incidents: $e';
      errorMessage.value = error.value;
    } finally {
      isLoading.value = false;
    }
  }

  void selectIncident(Incident? incident) {
    selectedIncident.value = incident;
  }
} 