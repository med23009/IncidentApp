import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incident_report_app/features/incidents/presentation/controllers/incident_controller.dart';

class IncidentFilter extends StatefulWidget {
  const IncidentFilter({super.key});

  @override
  State<IncidentFilter> createState() => _IncidentFilterState();
}

class _IncidentFilterState extends State<IncidentFilter> {
  final List<String> categories = [
    'Tous',
    'Route',
    'Électricité',
    'Eau',
    'Déchets',
    'Autre',
  ];

  final List<String> statuses = [
    'Tous',
    'Nouveau',
    'En cours',
    'Résolu',
    'Fermé',
  ];

  String selectedCategory = 'Tous';
  String selectedStatus = 'Tous';
  String? _selectedPriority;
  DateTime? _startDate;
  DateTime? _endDate;
  bool showOnlyNearby = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrer les incidents',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Catégorie'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedCategory,
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          const Text('Statut'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedStatus,
            items: statuses.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedStatus = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: showOnlyNearby,
                onChanged: (value) {
                  setState(() {
                    showOnlyNearby = value!;
                  });
                },
              ),
              const Text('Afficher uniquement les incidents à proximité'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final controller = Get.find<IncidentController>();
                controller.filterIncidents(
                  status: selectedStatus == 'Tous' ? null : selectedStatus,
                  priority: _selectedPriority,
                  startDate: _startDate,
                  endDate: _endDate,
                );
                Navigator.pop(context);
              },
              child: const Text('Appliquer'),
            ),
          ),
        ],
      ),
    );
  }
} 