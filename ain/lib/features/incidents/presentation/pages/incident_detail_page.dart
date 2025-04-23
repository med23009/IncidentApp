import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:incident_report_app/core/constants/constants.dart';
import 'package:incident_report_app/core/models/incident_model.dart';
import 'package:incident_report_app/features/incidents/presentation/controllers/incident_controller.dart';
import 'package:incident_report_app/features/incidents/presentation/controllers/location_controller.dart';
import 'package:intl/intl.dart';

class IncidentDetailPage extends StatelessWidget {
  final Incident incident;

  const IncidentDetailPage({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    final incidentController = Get.find<IncidentController>();
    final locationController = Get.find<LocationController>();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Initialiser la position de la carte
    locationController.setInitialPosition(
      LatLng(incident.latitude, incident.longitude),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'incident'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed(
              Routes.REPORT_INCIDENT,
              arguments: {'incident': incident},
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmer la suppression'),
                  content: const Text('Êtes-vous sûr de vouloir supprimer cet incident ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && incident.id != null) {
                final success = await incidentController.deleteIncident(incident.id!);
                if (success) {
                  Get.back();
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo de l'incident
            if (incident.images != null && incident.images!.isNotEmpty)
              Image.network(
                incident.images!.first['image'],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et statut
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          incident.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(incident.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          incident.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    incident.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // Informations détaillées
                  _buildInfoRow(
                    context,
                    Icons.category,
                    'Catégorie',
                    incident.category,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.person,
                    'Signalé par',
                    incident.user.fullName,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.calendar_today,
                    'Date de signalement',
                    dateFormat.format(incident.createdAt),
                  ),
                  _buildInfoRow(
                    context,
                    Icons.update,
                    'Dernière mise à jour',
                    dateFormat.format(incident.updatedAt),
                  ),

                  // Carte
                  const SizedBox(height: 24),
                  const Text(
                    'Localisation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: Obx(() => GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: locationController.mapPosition.value,
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId(incident.id.toString()),
                          position: locationController.mapPosition.value,
                          infoWindow: InfoWindow(
                            title: incident.title,
                            snippet: incident.description,
                          ),
                        ),
                      },
                      onMapCreated: (GoogleMapController controller) {
                        locationController.mapController = controller;
                      },
                    )),
                  ),

                  // Enregistrement vocal
                  if (incident.audios != null && incident.audios!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Enregistrement vocal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implémenter la lecture de l'enregistrement
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Écouter l\'enregistrement'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implémenter la mise à jour du statut
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'nouveau':
        return Colors.blue;
      case 'en cours':
        return Colors.orange;
      case 'résolu':
        return Colors.green;
      case 'fermé':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
} 