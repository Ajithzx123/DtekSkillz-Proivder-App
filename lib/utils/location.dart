// ignore_for_file: unused_local_variable

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GetLocation {
  //if permission is allowed recently then onGranted method will invoke,
  //if permission is allowed already then allowed method will invoke,
  //if permission is rejected  then onRejected method will invoke,
  Future<void> requestPermission(
      {Function(Position position)? onGranted,
      Function()? onRejected,
      Function(Position position)? allowed,
      bool wantsToOpenAppSetting = false,}) async {
    //
    final LocationPermission checkPermission = await Geolocator.checkPermission();
    //
    if (checkPermission == LocationPermission.denied) {
      //
      final LocationPermission permission = await Geolocator.requestPermission();
      //

      if (permission == LocationPermission.deniedForever && wantsToOpenAppSetting) {
        //open app setting for permission
        //await AppSettings.openAppSettings();
      } else if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        //

        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );

        //
        final List<Placemark> placeMark = await GeocodingPlatform.instance
            .placemarkFromCoordinates(position.latitude, position.longitude);

        //get name from mark
        final String? name = placeMark[0].name;
        final String? subLocality = placeMark[0].subLocality;

        onGranted?.call(position);
      } else {
        onRejected?.call();
      }
    } else if (checkPermission == LocationPermission.always ||
        checkPermission == LocationPermission.whileInUse) {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      allowed?.call(position);
    }
  }

/*  Future<List<Placemark>> getCuttrentLocation() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final double latitude = position.latitude;
      final double longitude = position.longitude;

      List<Placemark> placeMark = await placemarkFromCoordinates(latitude, longitude);

      return placeMark;
    }
  }*/

  Future<Position?> getPosition() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    }
    return null;
  }
}
