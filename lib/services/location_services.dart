import 'package:geolocator/geolocator.dart';

class LocationServices {

  static Future<Position> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return Future.error('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied.');
      }

      // You can specify the accuracy of the location here
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, // You can set this to medium or low if you want to save battery
      );

    } catch (e) {
      return Future.error('Error fetching location: $e');
    }
  }
}
