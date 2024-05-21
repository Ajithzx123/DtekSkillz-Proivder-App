
import 'dart:async';

import 'package:edemand_partner/app/appTheme.dart';
import 'package:edemand_partner/cubits/appThemeCubit.dart';
import 'package:edemand_partner/cubits/google_place_cubit.dart';
import 'package:edemand_partner/data/model/google_place_model.dart';
import 'package:edemand_partner/ui/screens/auth/searchPlacesWidegt.dart';
import 'package:edemand_partner/ui/widgets/customRoundButton.dart';
import 'package:edemand_partner/utils/colors.dart';
import 'package:edemand_partner/utils/location.dart';
import 'package:edemand_partner/utils/responsiveSize.dart';
import 'package:edemand_partner/utils/stringExtension.dart';
import 'package:edemand_partner/utils/uiUtils.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreen extends StatefulWidget {

  const GoogleMapScreen({super.key, this.longitude, this.latitude});
  final String? latitude;
  final String? longitude;

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  //
  StreamController markerController = StreamController();
  final Completer<GoogleMapController> _controller = Completer();

  //
  String? selectedLatitude;
  String? selectedLongitude;
  late CameraPosition initialCameraPosition =
  const CameraPosition(zoom: 1, target: LatLng(0.00, 0.00));
  String lineOneAddress = '';
  String lineTwoAddress = '';
  String? locality;
  List<Placemark> placeMark = [];

  //
  @override
  void initState() {
    super.initState();

    if (widget.latitude != '' && widget.longitude != '') {
      //
      selectedLongitude = widget.longitude;
      selectedLatitude = widget.latitude;
      final LatLng latLong = LatLng(double.parse(widget.latitude != '' ? widget.latitude! : '22.00'),
          double.parse(widget.longitude != '' ? widget.longitude! : '92.00'),);
      markerController.sink.add({
        Marker(
          markerId: const MarkerId('1'),
          position: latLong,
        )
      });

      initialCameraPosition = CameraPosition(zoom: 16, target: latLong);

      createAddressFromCoordinates(
          latitude: double.parse(widget.latitude != '' ? widget.latitude! : '90.00'),
          longitude: double.parse(widget.longitude != '' ? widget.longitude! : '180.00'),);
    }

    //
  }

  @override
  void dispose() {
    markerController.close();
    super.dispose();
  }

  Future<void> _onTapGoogleMap(LatLng position) async {
    markerController.sink.add({
      Marker(
        markerId: const MarkerId('1'),
        position: position,
      )
    });

    _placeMarkerOnLatitudeAndLongitude(latitude: position.latitude, longitude: position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .secondaryColor,
          leading: UiUtils.setBackArrow(context),
          title: Text('selectLocation'.translate(context: context),
            style: TextStyle(color: Theme
                .of(context)
                .colorScheme
                .blackColor, fontWeight: FontWeight.bold,),
          ),
          centerTitle: true,
        ),
        body: WillPopScope(
          onWillPop: () async =>
              Future.delayed(const Duration(milliseconds: 1000)).then((value) => true),
          child: StreamBuilder(
              stream: markerController.stream,

              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return Stack(
                  children: [
                    GoogleMap(
                      zoomControlsEnabled: false,
                      markers: snapshot.data != null ? Set.of(snapshot.data) : {},
                      onTap: (LatLng position) async {
                        _onTapGoogleMap(position);
                      },
                      initialCameraPosition: initialCameraPosition,
                      onMapCreated: (GoogleMapController controller) async {
                        _controller.complete(controller);
//
                        if (context
                            .read<AppThemeCubit>()
                            .state
                            .appTheme == AppTheme.dark) {
                          controller.setMapStyle(
                              await rootBundle.loadString('assets/mapTheme/darkMap.json'),);
                          setState(() {});
                        }
                      },
                      minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                    ),
                    Align(
                        alignment: Alignment.topCenter,

                        child: BlocProvider(
                          create: (BuildContext context) => GooglePlaceAutocompleteCubit(),
                          child: SearchPlaces(
                            onPlaceSelected: (GooglePlaceModel selectedPlaceData) {
                              //
                              _placeMarkerOnLatitudeAndLongitude(
                                  latitude: double.parse(selectedPlaceData.latitude),
                                  longitude: double.parse(selectedPlaceData.longitude),);
                            },
                          ),
                        ),
                    ),
                    Positioned.fill(
                        bottom: 160,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: AlignmentDirectional.bottomEnd,
                                child: Container(
                                  margin: const EdgeInsets.all(20.0),
                                  decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                                    BoxShadow(
                                        blurRadius: 5,
                                        color:
                                        Theme
                                            .of(context)
                                            .colorScheme
                                            .blackColor
                                            .withOpacity(0.2),)
                                  ],),
                                  child: Material(
                                    type: MaterialType.circle,
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .secondaryColor,
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: _onMyCurrentLocationClicked,
                                      child: SizedBox(
                                        width: 60.rw(context),
                                        height: 60.rh(context),
                                        child: Icon(
                                          Icons.my_location_outlined,
                                          size: 35,
                                          color: Theme
                                              .of(context)
                                              .colorScheme
                                              .blackColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),),
                    if (lineOneAddress.isNotEmpty)
                      Align(
                        alignment: AlignmentDirectional.bottomEnd,
                        child: Container(
                          height: 150,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          decoration: BoxDecoration(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .secondaryColor,
                              boxShadow: [
                                BoxShadow(
                                    offset: const Offset(0, -5),
                                    blurRadius: 4,
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .blackColor
                                        .withOpacity(0.2),)
                              ],
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20), topRight: Radius.circular(20),),),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(
                                          width: 10.rw(context),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                lineOneAddress,
                                                maxLines: 1,
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme
                                                        .of(context)
                                                        .colorScheme
                                                        .blackColor,),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                lineTwoAddress,
                                                maxLines: 1,
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                    Theme
                                                        .of(context)
                                                        .colorScheme
                                                        .lightGreyColor,),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                    padding:
                                    const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12),
                                    child: CustomRoundedButton(
                                      backgroundColor: Theme
                                          .of(context)
                                          .colorScheme
                                          .accentColor,
                                      widthPercentage: 0.9,
                                      showBorder: false,
                                      height: 43,
                                      buttonTitle: 'confirmAddress'.translate(context: context),
                                      onTap: () {
                                        Future.delayed(
                                          const Duration(milliseconds: 500),
                                              () {
                                            Navigator.pop(context, {
                                              'selectedLatitude': selectedLatitude!.trimLatLong(),
                                              'selectedLongitude': selectedLongitude!.trimLatLong(),
                                              'selectedAddress': '$lineOneAddress,$lineTwoAddress',
                                              'selectedCity': '$locality',
                                            });
                                          },
                                        );
                                      },
                                    ),),
                              ],
                            ),
                          ),
                        ),
                      )
                  ],
                );
              },),
        ),
      ),
    );
  }

  Future<void> _placeMarkerOnLatitudeAndLongitude({required double latitude, required double longitude}) async {
    //
    selectedLatitude = latitude.toString();
    selectedLongitude = longitude.toString();
    //

    final LatLng latLong = LatLng(latitude, longitude);
    //
    final Marker marker = Marker(
      markerId: const MarkerId('1'),
      position: latLong,
    );
    markerController.sink.add({marker});

    final GoogleMapController controller = await _controller.future;
    final CameraUpdate newCameraPosition =
    CameraUpdate.newCameraPosition(CameraPosition(zoom: 15, target: latLong));
    controller.animateCamera(newCameraPosition);
    //
    createAddressFromCoordinates(latitude: latitude, longitude: longitude);
  }

  Future<void> createAddressFromCoordinates({required double latitude, required double longitude}) async {
    placeMark = await GeocodingPlatform.instance.placemarkFromCoordinates(latitude, longitude);
    final String? name = placeMark[0].name;
    final String? subLocality = placeMark[0].subLocality;
    locality = placeMark[0].locality;
    final String? administrativeArea = placeMark[0].administrativeArea;
    final String? postalCode = placeMark[0].postalCode;
    final String? country = placeMark[0].country;
    final List temp = [];
    final List addressList = [];
    temp..add(name ?? '')..add(subLocality ?? '')..add(locality ?? '')..add(
        administrativeArea ?? '',)..add(postalCode ?? '')..add(country ?? '');
    for (final elem in temp) {
      if (elem != '') {
        addressList.add(elem);
      }
    }
    lineOneAddress =
        '$name,$subLocality,${placeMark[0].locality},${placeMark[0].country}'.removeExtraComma();
    lineTwoAddress = '$postalCode'.removeExtraComma();
    //
    setState(() {});
  }

  void _onMyCurrentLocationClicked() {
    //
    GetLocation().getPosition().then((Position? value) async {
      if (value == null) {
        await GetLocation().requestPermission(
            allowed: (Position position) {
              _placeMarkerOnLatitudeAndLongitude(
                  latitude: position.latitude, longitude: position.longitude,);
            },
            onGranted: (Position position) {
              _placeMarkerOnLatitudeAndLongitude(
                  latitude: position.latitude, longitude: position.longitude,);
            },
            onRejected: () {},);
      } else {
        _placeMarkerOnLatitudeAndLongitude(latitude: value.latitude, longitude: value.longitude);
      }
    });
  }
}
