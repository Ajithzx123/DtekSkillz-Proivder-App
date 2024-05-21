
import 'package:flutter/material.dart';
import '../../../app/generalImports.dart';

class SearchPlaces extends StatefulWidget {

  const SearchPlaces({super.key, required this.onPlaceSelected});
  final Function(GooglePlaceModel) onPlaceSelected;

  @override
  State<SearchPlaces> createState() => SearchPlacesState();
}

class SearchPlacesState extends State<SearchPlaces> {
  final TextEditingController _searchLocation = TextEditingController();
  FocusNode searchLocationFocusNode = FocusNode();
  Timer? delayTimer;
  GooglePlaceAutocompleteCubit? cubitReferance;
  int previouseLength = 0;

  @override
  void initState() {
    super.initState();
    _searchLocation.addListener(() {
      if (_searchLocation.text.isEmpty) {
        delayTimer?.cancel();
        cubitReferance?.clearCubit();
        previouseLength = 0;
      }

      if (delayTimer?.isActive ?? false) delayTimer?.cancel();

      delayTimer = Timer(const Duration(milliseconds: 500), () {
        if (_searchLocation.text.isNotEmpty) {
          if (_searchLocation.text.length != previouseLength) {
            context
                .read<GooglePlaceAutocompleteCubit>()
                .searchLocationFromPlacesAPI(text: _searchLocation.text);
            previouseLength = _searchLocation.text.length;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _searchLocation.dispose();
    delayTimer?.cancel();
    cubitReferance?.clearCubit();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    cubitReferance = context.read<GooglePlaceAutocompleteCubit>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height * 0.4,
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,),
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchLocation,
            onChanged: (String e) {},
            focusNode: searchLocationFocusNode,
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.blackColor),
            cursorColor: Theme.of(context).colorScheme.accentColor,
            decoration: InputDecoration(
                contentPadding: const EdgeInsetsDirectional.only(bottom: 2, start: 15),
                filled: true,
                fillColor: Theme.of(context).colorScheme.secondaryColor,
                hintText: 'enterLocationAreaCity'.translate(context: context),
                hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.blackColor),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.accentColor),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.accentColor),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.accentColor),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),),
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  child: UiUtils.setSVGImage('search',
                      height: 12, width: 12, imgColor: Theme.of(context).colorScheme.blackColor,),
                ),),
          ),
          Container(
            color: Theme.of(context).colorScheme.secondaryColor,
            child: BlocBuilder<GooglePlaceAutocompleteCubit, GooglePlaceAutocompleteState>(
              builder: (BuildContext context, GooglePlaceAutocompleteState googlePlaceState) {
                if (googlePlaceState is GooglePlaceAutocompleteSuccess) {
                  if (googlePlaceState.autocompleteResult.predictions != null &&
                      googlePlaceState.autocompleteResult.predictions!.isNotEmpty) {
                    return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                        separatorBuilder: (BuildContext context, int index) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Divider(
                              thickness: 0.9,
                            ),
                          );
                        },
                        itemCount: googlePlaceState.autocompleteResult.predictions!.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int i) {
                          return InkWell(
                            onTap: () async {
                              final Prediction placeData =
                                  googlePlaceState.autocompleteResult.predictions![i];

                              final cordinates = await GooglePlaceRepository()
                                  .getPlaceDetailsFromPlaceId(placeData.placeId!);

                              final GooglePlaceModel placeModel = GooglePlaceModel(
                                  placeId: placeData.placeId!,
                                  cityName: placeData.description!,
                                  name: placeData.description!,
                                  latitude: cordinates['lat'].toString(),
                                  longitude: cordinates['lng'].toString(),);
                              //
                              _searchLocation.clear();
                              searchLocationFocusNode.unfocus();
                              cubitReferance?.clearCubit();
                              //
                              Future.delayed(Duration.zero, () {
                                widget.onPlaceSelected(
                                  placeModel,
                                );
                              });
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 35,
                                  height: 25,
                                  child: Icon(Icons.location_city,
                                      color: Theme.of(context).colorScheme.accentColor,),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                    child: Text(
                                        googlePlaceState
                                            .autocompleteResult.predictions![i].description
                                            .toString(),
                                        style: TextStyle(
                                            color: Theme.of(context).colorScheme.blackColor,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            fontSize: 14.0,),
                                        textAlign: TextAlign.start,),),
                              ],
                            ),
                          );
                        },);
                  } else if (_searchLocation.text.isEmpty) {
                    return Container();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(child: Text('noLocationFound'.translate(context: context))),
                  );
                }

                if (googlePlaceState is GooglePlaceAutocompleteInProgress) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return Container();
              },
            ),
          )
        ],
      ),
    );
  }
}
