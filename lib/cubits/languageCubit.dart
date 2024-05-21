import '../../app/generalImports.dart';

class LanguageState {}

class LanguageInitial extends LanguageState {}

class LanguageLoader extends LanguageState {

  LanguageLoader(this.languageCode);
  final dynamic languageCode;
}

class LanguageLoadFail extends LanguageState {}

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageInitial());

  void loadCurrentLanguage() {
    final language = Hive.box(HiveKeys.languageBox).get(HiveKeys.currentLanguageKey);
    if (language != null) {
      emit(LanguageLoader(language));
    } else {
      emit(LanguageLoadFail());
    }
  }

  Future<void> changeLanguage(String code) async {
    await Hive.box(HiveKeys.languageBox).put(HiveKeys.currentLanguageKey, code);
    emit(LanguageLoader(code));
  }

  dynamic currentLanguageCode() {
    return Hive.box(HiveKeys.languageBox).get(HiveKeys.currentLanguageKey);
  }
}
