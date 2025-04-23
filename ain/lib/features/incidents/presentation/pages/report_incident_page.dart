import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:incident_report_app/core/models/incident_model.dart';
import 'package:incident_report_app/core/services/api_service.dart';
import 'package:incident_report_app/features/auth/data/services/auth_service.dart';
import 'package:incident_report_app/features/incidents/presentation/controllers/incident_controller.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';

class ReportIncidentPage extends StatefulWidget {
  const ReportIncidentPage({super.key});

  @override
  State<ReportIncidentPage> createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _incidentController = Get.find<IncidentController>();
  final _authService = Get.find<AuthService>();
  final _apiService = Get.find<ApiService>();
  final _imagePicker = ImagePicker();
  final _audioRecorder = AudioRecorder();
  late final AudioPlayer _audioPlayer;
  final _isRecording = false.obs;
  final _isPlaying = false.obs;
  final _audioPath = RxnString();
  final _imagePaths = <String>[].obs;
  final _isLoading = false.obs;
  final _locationText = ''.obs;
  final _recordingDuration = Duration.zero.obs;
  final _playerDuration = Duration.zero.obs;
  final _playerPosition = Duration.zero.obs;
  double? _latitude;
  double? _longitude;
  Timer? _recordingTimer;
  Timer? _playerTimer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _getCurrentLocation();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _isPlaying.value = false;
        _playerPosition.value = Duration.zero;
      }
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _playerDuration.value = duration;
      }
    });

    _audioPlayer.positionStream.listen((position) {
      _playerPosition.value = position;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _recordingTimer?.cancel();
    _playerTimer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _isLoading.value = true;
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Error', 'Location services are disabled');
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Error', 'Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Error', 'Location permissions are permanently denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationText.value = '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to get location: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _pickImage() async {
    final result = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final pickedFile = await _imagePicker.pickImage(source: result);
      if (pickedFile != null) {
        _imagePaths.add(pickedFile.path);
      }
    }
  }

  void _removeImage(int index) {
    _imagePaths.removeAt(index);
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );

        _isRecording.value = true;
        _recordingDuration.value = Duration.zero;
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _recordingDuration.value += const Duration(seconds: 1);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _isRecording.value = false;
      _audioPath.value = path;
      _recordingTimer?.cancel();
    } catch (e) {
      Get.snackbar('Error', 'Failed to stop recording');
    }
  }

  Future<void> _playAudio() async {
    if (_audioPath.value != null) {
      try {
        _isPlaying.value = true;
        await _audioPlayer.setFilePath(_audioPath.value!);
        await _audioPlayer.play();
      } catch (e) {
        Get.snackbar('Error', 'Failed to play audio: $e');
        _isPlaying.value = false;
      }
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
    _isPlaying.value = false;
  }

  void _removeAudio() {
    _audioPath.value = null;
    _recordingDuration.value = Duration.zero;
    _playerPosition.value = Duration.zero;
    _playerDuration.value = Duration.zero;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      // Vérifier qu'au moins une description ou un audio est fourni
      if (_descriptionController.text.isEmpty && _audioPath.value == null) {
        Get.snackbar(
          'Erreur',
          'Veuillez fournir une description ou un enregistrement audio',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      try {
        _isLoading.value = true;
        var incident = Incident(
          title: _titleController.text,
          description: _descriptionController.text,
          status: 'pending',
          category: 'other',
          address: _locationText.value,
          user: _authService.currentUser.value!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          latitude: _latitude ?? 0.0,
          longitude: _longitude ?? 0.0,
        );

        // Créer l'incident d'abord pour obtenir son ID
        final success = await _incidentController.createIncident(incident);
        if (success) {
          // Récupérer l'ID de l'incident créé
          final incidentId = _incidentController.incidents.last.id;

          // Upload des fichiers si présents
          if (_imagePaths.isNotEmpty || _audioPath.value != null) {
            try {
              final response = await _apiService.uploadFiles(
                imagePaths: _imagePaths,
                audioPath: _audioPath.value ?? '',
                incidentId: incidentId.toString(),
              );

              // Mettre à jour l'incident avec les URLs des fichiers
              if (response['images'] != null) {
                incident = incident.copyWith(
                  images: (response['images'] as List)
                      .map((image) => {'image': image['url']})
                      .toList(),
                );
              }
              if (response['audio'] != null) {
                incident = incident.copyWith(
                  audios: [
                    {'audio': response['audio']['url']}
                  ],
                );
              }

              // Mettre à jour l'incident avec les URLs des fichiers
              await _incidentController.updateIncident(incident);
            } catch (e) {
              Get.snackbar('Warning', 'Files upload failed: $e');
            }
          }

          Get.back();
          Get.snackbar('Success', 'Incident reported successfully');
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to report incident: $e');
      } finally {
        _isLoading.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (requis si pas d\'audio)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Obx(() => Text(
                'Location: ${_locationText.value.isNotEmpty ? _locationText.value : 'Loading...'}',
                style: const TextStyle(fontSize: 16),
              )),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Add Image'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => ElevatedButton.icon(
                          onPressed: _isRecording.value ? _stopRecording : _startRecording,
                          icon: Icon(_isRecording.value ? Icons.stop : Icons.mic),
                          label: Text(_isRecording.value ? 'Stop Recording' : 'Record Audio'),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (_imagePaths.isNotEmpty) {
                  return Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: _imagePaths.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_imagePaths[index]),
                                  fit: BoxFit.cover,
                                  height: 200,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.white),
                                    onPressed: () => _removeImage(index),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_imagePaths.length} image${_imagePaths.length > 1 ? 's' : ''} added',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 16),
              Obx(() {
                if (_audioPath.value != null) {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.audio_file,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Audio Recording',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDuration(_isRecording.value ? _recordingDuration.value : _playerDuration.value),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Obx(() => IconButton(
                                        icon: Icon(
                                          _isPlaying.value ? Icons.pause_circle : Icons.play_circle,
                                          size: 32,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        onPressed: _isPlaying.value ? _pauseAudio : _playAudio,
                                      )),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    color: Colors.red,
                                    onPressed: _removeAudio,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (!_isRecording.value)
                            Obx(() => LinearProgressIndicator(
                                  value: _playerDuration.value.inMilliseconds > 0
                                      ? _playerPosition.value.inMilliseconds / _playerDuration.value.inMilliseconds
                                      : 0,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                )),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitReport,
                child: const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 