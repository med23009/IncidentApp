import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incident_report_app/core/constants/constants.dart';
import 'package:incident_report_app/features/incidents/presentation/controllers/incident_controller.dart';
import 'package:incident_report_app/features/incidents/presentation/controllers/location_controller.dart';
import 'package:incident_report_app/features/incidents/presentation/widgets/incident_card.dart';
import 'package:incident_report_app/features/incidents/presentation/widgets/incident_filter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final incidentController = Get.find<IncidentController>();
    final locationController = Get.find<LocationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) => const IncidentFilter(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.toNamed(Routes.REPORT_INCIDENT);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await incidentController.fetchIncidents();
          await locationController.getCurrentLocation();
        },
        child: Obx(() {
          if (incidentController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (incidentController.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(incidentController.errorMessage.value),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => incidentController.fetchIncidents(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (incidentController.incidents.isEmpty) {
            return const Center(
              child: Text('Aucun incident signalé'),
            );
          }

          return ListView.builder(
            itemCount: incidentController.incidents.length,
            itemBuilder: (context, index) {
              final incident = incidentController.incidents[index];
              return IncidentCard(incident: incident);
            },
          );
        }),
      ),
    );
  }
} 