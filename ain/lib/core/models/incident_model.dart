import 'package:incident_report_app/core/models/user_model.dart';

class Incident {
  final int? id;
  final String title;
  final String description;
  final String status;
  final String category;
  final String address;
  final User user;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Map<String, dynamic>>? images;
  final List<Map<String, dynamic>>? audios;
  final List<Map<String, dynamic>>? comments;
  final double latitude;
  final double longitude;
  bool isOffline;

  Incident({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.address,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
    this.images,
    this.audios,
    this.comments,
    required this.latitude,
    required this.longitude,
    this.isOffline = false,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      category: json['category'],
      address: json['address'],
      user: User.fromJson(json['user']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      images: json['images'] != null ? List<Map<String, dynamic>>.from(json['images']) : null,
      audios: json['audios'] != null ? List<Map<String, dynamic>>.from(json['audios']) : null,
      comments: json['comments'] != null ? List<Map<String, dynamic>>.from(json['comments']) : null,
      latitude: json['latitude'],
      longitude: json['longitude'],
      isOffline: json['is_offline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'category': category,
      'address': address,
      'user': user.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'images': images,
      'audios': audios,
      'comments': comments,
      'latitude': latitude,
      'longitude': longitude,
      'is_offline': isOffline,
    };
  }

  Incident copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    String? category,
    String? address,
    User? user,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? images,
    List<Map<String, dynamic>>? audios,
    List<Map<String, dynamic>>? comments,
    double? latitude,
    double? longitude,
    bool? isOffline,
  }) {
    return Incident(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      category: category ?? this.category,
      address: address ?? this.address,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
      audios: audios ?? this.audios,
      comments: comments ?? this.comments,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isOffline: isOffline ?? this.isOffline,
    );
  }
} 