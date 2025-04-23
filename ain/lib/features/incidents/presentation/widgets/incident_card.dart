import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incident_report_app/core/constants/constants.dart';
import 'package:incident_report_app/core/models/incident_model.dart';
import 'package:incident_report_app/features/incidents/presentation/controllers/location_controller.dart';
import 'package:intl/intl.dart';

class IncidentCard extends StatelessWidget {
  final Incident incident;

  const IncidentCard({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => Get.toNamed(
          Routes.INCIDENT_DETAIL,
          arguments: incident,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      incident.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
              const SizedBox(height: 8),
              Text(
                incident.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.category, size: 16),
                  const SizedBox(width: 4),
                  Text(incident.category),
                  const Spacer(),
                  const Icon(Icons.person, size: 16),
                  const SizedBox(width: 4),
                  Text(incident.user.fullName),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(dateFormat.format(incident.createdAt)),
                  const Spacer(),
                  if (incident.images != null && incident.images!.isNotEmpty) ...[
                    const Icon(Icons.photo, size: 16),
                    const SizedBox(width: 4),
                  ],
                  if (incident.audios != null && incident.audios!.isNotEmpty) ...[
                    const Icon(Icons.mic, size: 16),
                    const SizedBox(width: 4),
                  ],
                ],
              ),
              if (locationController.currentPosition.value != null) ...[
                const SizedBox(height: 8),
                FutureBuilder<double>(
                  future: locationController.calculateDistance(
                    locationController.currentPosition.value!.latitude,
                    locationController.currentPosition.value!.longitude,
                    incident.latitude,
                    incident.longitude,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final distance = snapshot.data!;
                      return Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${(distance / 1000).toStringAsFixed(1)} km',
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ],
          ),
        ),
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