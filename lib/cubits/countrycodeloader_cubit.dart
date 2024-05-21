import '../../app/generalImports.dart';

abstract class CountryCodeState {}

class CountryCodeInitial extends CountryCodeState {}

class CountryCodeLoadingInProgress extends CountryCodeState {}

class CountryCodeFetchSuccess extends CountryCodeState {

  CountryCodeFetchSuccess({
    this.selectedCountry,
    this.countryList,
    this.temporaryCountryList,
  });
  final Country? selectedCountry;
  final List<Country>? countryList;
  final List<Country>? temporaryCountryList;
}

class CountryCodeFetchFail extends CountryCodeState {

  CountryCodeFetchFail(this.error);
  final dynamic error;
}

class CountryCodeCubit extends Cubit<CountryCodeState> {
  CountryCodeCubit() : super(CountryCodeInitial());

  Future<void>loadAllCountryCode(BuildContext context) async {
    try {
      emit(CountryCodeLoadingInProgress());
      final Country country = await getDefaultCountry(context);
      // ignore: use_build_context_synchronously
      final List<Country> countriesList = await getCountries(context);
      emit(CountryCodeFetchSuccess(
          selectedCountry: country,
          countryList: countriesList,
          temporaryCountryList: countriesList,),);
    } catch (e) {
      emit(CountryCodeFetchFail(e));
    }
  }

  void selectCountryCode(Country country) {
    if (state is CountryCodeFetchSuccess) {
      emit(CountryCodeFetchSuccess(
          selectedCountry: country,
          countryList: (state as CountryCodeFetchSuccess).countryList,
          temporaryCountryList: (state as CountryCodeFetchSuccess).temporaryCountryList,),);
    }
  }

  void filterCountryCodeList(String content) {
    if (state is CountryCodeFetchSuccess) {
      final List<Country>? mainList = (state as CountryCodeFetchSuccess).countryList;
      // ignore: prefer_final_locals
      List<Country>? tempList = [];

      final Country? selectedCountry = (state as CountryCodeFetchSuccess).selectedCountry;

      for (int i = 0; i < mainList!.length; i++) {
        final Country country = mainList[i];

        if (country.name.toLowerCase().contains(content.toLowerCase()) ||
            country.callingCode.toLowerCase().contains(content.toLowerCase())) {
          if (!tempList.contains(country)) {
            tempList.add(country);
          }
        }
      }

      emit(CountryCodeFetchSuccess(
          temporaryCountryList: tempList, countryList: mainList, selectedCountry: selectedCountry,),);
    }
  }

  void clearTemporaryList() {
    if (state is CountryCodeFetchSuccess) {
      final List<Country>? mainList = (state as CountryCodeFetchSuccess).countryList;
      final Country? selectedCountry = (state as CountryCodeFetchSuccess).selectedCountry;
      emit(CountryCodeFetchSuccess(
          temporaryCountryList: [], countryList: mainList, selectedCountry: selectedCountry,),);
    }
  }

  void fillTemporaryList() {
    if (state is CountryCodeFetchSuccess) {
      final List<Country>? mainList = (state as CountryCodeFetchSuccess).countryList;
      final Country? selectedCountry = (state as CountryCodeFetchSuccess).selectedCountry;
      emit(CountryCodeFetchSuccess(
          temporaryCountryList: mainList, countryList: mainList, selectedCountry: selectedCountry,),);
    }
  }

  String getSelectedCountryCode() {
    return (state as CountryCodeFetchSuccess).selectedCountry!.callingCode;
  }
}
