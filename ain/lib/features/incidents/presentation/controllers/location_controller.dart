import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationController extends GetxController {
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final Rx<LatLng> mapPosition = Rx<LatLng>(const LatLng(0, 0));
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  GoogleMapController? mapController;

  Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      errorMessage.value = 'Erreur lors de la demande de permission de localisation';
      return false;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        errorMessage.value = 'Permission de localisation refusée';
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentPosition.value = position;
      mapPosition.value = LatLng(position.latitude, position.longitude);
      
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(mapPosition.value),
        );
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors de la récupération de la position';
    } finally {
      isLoading.value = false;
    }
  }

  void setInitialPosition(LatLng position) {
    mapPosition.value = position;
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(position),
      );
    }
  }

  Future<double> calculateDistance(double lat1, double lon1, double lat2, double lon2) async {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }
}